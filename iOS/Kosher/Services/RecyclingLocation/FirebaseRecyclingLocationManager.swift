import FirebaseFirestore
import Foundation
import MapKit

final class FirebaseRecyclingLocationManager: RecyclingLocationManaging {
    private let db = Firestore.firestore() // vytvoreni instance Firebase databaze
    // lazy resolve — vyhne se deadlocku pri inicializaci DIContaineru
    private var dataManager: DataManaging { DIContainer.shared.resolve() }
    private let lastSyncKey = "lastLocationSyncedAt" // klic pro ulozeni do UserDefaults posledniho data syncu

    // Vraci vsechna lokalni data z CoreData — pouzito pro nacteni prispevku uzivatele
    func loadLocations() async -> [RecyclingLocation] {
        await dataManager.fetchLocations()
    }

    // Stahuje biny daneho uzivatele primo z Firestore — neni zavisle na lokalni cache
    func fetchLocations(byUser userId: String) async -> [RecyclingLocation] {
        guard let snapshot = try? await db.collection("bins")
            .whereField("addedBy", isEqualTo: userId)
            .getDocuments()
        else { return [] }
        let locations = snapshot.documents.compactMap { parse(from: $0.data(), id: $0.documentID) }
        if !locations.isEmpty { await dataManager.upsertLocations(locations) }
        return locations
    }

    // Vraci data z CoreData okamzite — bez sitoveho volani
    func loadLocations(in region: MKCoordinateRegion) async -> [RecyclingLocation] {
        await dataManager.fetchLocations(
            minLat: region.center.latitude  - region.span.latitudeDelta  / 2,
            maxLat: region.center.latitude  + region.span.latitudeDelta  / 2,
            minLon: region.center.longitude - region.span.longitudeDelta / 2,
            maxLon: region.center.longitude + region.span.longitudeDelta / 2
        )
    }

    // Stahuje kazdy tile z Firestore paralelne, uklada do CoreData
    // Uspesne stazene tiles take cistit od zaznamu smazanych ve Firestore
    func fetchTiles(_ tiles: Set<TileKey>) async {
        var all: [RecyclingLocation] = []
        var successfulTiles: Set<TileKey> = []

        await withTaskGroup(of: (TileKey, [RecyclingLocation]?).self) { group in
            for tile in tiles {
                // hodnoty zachycujeme pred vstupem do task closure — vyhyba se main-actor izolaci tile
                let (minLat, maxLat, minLon, maxLon) = (tile.minLat, tile.maxLat, tile.minLon, tile.maxLon)
                group.addTask {
                    // Firebase SDK 10.12+ podporuje vice range filtru — vyzaduje composite index
                    // V Firebase konzoli je potreba vytvorit index: bins -> latitude ASC, longitude ASC
                    do {
                        let snapshot = try await self.db.collection("bins")
                            .whereField("latitude", isGreaterThanOrEqualTo: minLat)
                            .whereField("latitude", isLessThan: maxLat)
                            .whereField("longitude", isGreaterThanOrEqualTo: minLon)
                            .whereField("longitude", isLessThan: maxLon)
                            .getDocuments()
                        let results = snapshot.documents.compactMap { self.parse(from: $0.data(), id: $0.documentID) }
                        return (tile, results)
                    } catch {
                        print("⚠️ fetchTile \(tile.storageKey) selhal: \(error)")
                        return (tile, nil)
                    }
                }
            }

            for await (tile, results) in group {
                if let results {
                    all.append(contentsOf: results)
                    successfulTiles.insert(tile)
                }
            }
        }

        // Pro uspesne stazene tiles smaz zaznamy v CoreData co uz nejsou ve Firestore
        let returnedIds = Set(all.map(\.id))
        for tile in successfulTiles {
            let existing = await dataManager.fetchLocations(
                minLat: tile.minLat, maxLat: tile.maxLat,
                minLon: tile.minLon, maxLon: tile.maxLon
            )
            let staleIds = Set(existing.map(\.id)).subtracting(returnedIds)
            if !staleIds.isEmpty {
                await dataManager.deleteLocations(withIds: staleIds)
            }
        }

        if !all.isEmpty { await dataManager.upsertLocations(all) }
    }

    // Ulozi novou lokaci — CoreData okamzite, Firestore callback (neblokuje, SDK doruceni zajisti sam)
    func createLocation(_ location: RecyclingLocation) async throws {
        var data: [String: Any] = [
            "category":  location.category.rawValue,
            "types":     location.types.map { $0.rawValue },
            "status":    location.status.rawValue,
            "latitude":  location.latitude,
            "longitude": location.longitude,
            "updatedAt": location.updatedAt.timeIntervalSince1970 * 1000
        ]
        if let addedBy   = location.addedBy   { data["addedBy"]   = addedBy }
        if let addedAt   = location.addedAt   { data["addedAt"]   = addedAt.timeIntervalSince1970 * 1000 }
        if let imageData = location.imageData { data["imageData"] = imageData }

        // CoreData first — okamzita zpetna vazba, lokace se objevi na mape
        await dataManager.upsertLocations([location])
        // fire-and-forget — neblokujeme calera, SDK doruceni na server zajisti sam
        let ref = db.collection("bins").document(location.id)
        Task {
            do { try await ref.setData(data) }
            catch { print("⚠️ Firestore createLocation selhal: \(error)") }
        }
    }

    // pocet hlasu potrebnych ke zmene statusu binu
    private let votesRequired = 1

    // zaznamena hlas a vrati aktualizovanou lokaci — moderator meni status okamzite
    func vote(on locationId: String, userId: String, confirm: Bool, isModerator: Bool) async throws -> RecyclingLocation {
        let ref = db.collection("bins").document(locationId)
        let now = Date().timeIntervalSince1970 * 1000

        var updates: [String: Any] = [
            "votes.\(userId)": confirm,
            "updatedAt": now
        ]
        // moderator: okamzita zmena statusu bez pocitani hlasu
        if isModerator {
            updates["status"] = (confirm ? LocationStatus.active : LocationStatus.rejected).rawValue
        }
        try await ref.updateData(updates)

        // pro bezneho uzivatele: pocitame hlasy a aktualizujeme status pri dosazeni prahu
        if !isModerator {
            let snap = try await ref.getDocument()
            let votes = snap.data().flatMap { $0["votes"] as? [String: Bool] } ?? [:]
            let confirms = votes.values.filter { $0 }.count
            let denies   = votes.values.filter { !$0 }.count
            if confirms >= votesRequired {
                try await ref.updateData(["status": LocationStatus.active.rawValue])
            } else if denies >= votesRequired {
                try await ref.updateData(["status": LocationStatus.rejected.rawValue])
            }
        }

        // nacti finalni stav dokumentu
        let finalSnap = try await ref.getDocument()
        guard let data = finalSnap.data(), let location = parse(from: data, id: locationId) else {
            throw VoteError.notFound
        }
        await dataManager.upsertLocations([location])
        return location
    }

    // Smaze lokaci z Firestore a CoreData
    func deleteLocation(id: String) async throws {
        try await db.collection("bins").document(id).delete()
        await dataManager.deleteLocations(withIds: [id])
    }

    // Aktualizuje menitelna pole lokace — id, souradnice a addedBy se nemeni
    func updateLocation(_ location: RecyclingLocation) async throws {
        var data: [String: Any] = [
            "category":  location.category.rawValue,
            "types":     location.types.map { $0.rawValue },
            "updatedAt": location.updatedAt.timeIntervalSince1970 * 1000
        ]
        if let imageData = location.imageData { data["imageData"] = imageData }
        try await db.collection("bins").document(location.id).updateData(data)
        await dataManager.upsertLocations([location])
    }

    // Prvni launch: nacte data z bundled JSON, uklada do CoreData a nastavi lastSync na ted
    // Dalsi launche: stahuje jen dokumenty zmenene od posledniho syncu
    func deltaSync() async {
        let lastSync = UserDefaults.standard.object(forKey: lastSyncKey) as? Date

        if lastSync == nil {
            // prvni launch — seed z bundledu misto stahovani vsech 36k zaznamu z Firestore
            let bundled = loadFromBundle()
            if !bundled.isEmpty {
                await dataManager.upsertLocations(bundled)
            }
            UserDefaults.standard.set(Date(), forKey: lastSyncKey)
            return
        }

        // dalsi launche — stahujeme jen zmenene dokumenty od posledniho syncu
        let lastSyncMs = lastSync!.timeIntervalSince1970 * 1000
        guard let snapshot = try? await db.collection("bins")
            .whereField("updatedAt", isGreaterThan: lastSyncMs)
            .getDocuments(),
            !snapshot.documents.isEmpty
        else { return }

        let updates = snapshot.documents.compactMap { parse(from: $0.data(), id: $0.documentID) }
        await dataManager.upsertLocations(updates)
        UserDefaults.standard.set(Date(), forKey: lastSyncKey)
    }

    // MARK: - Private

    private func loadFromBundle() -> [RecyclingLocation] {
        guard
            // najde locations.json
            let url = Bundle.main.url(forResource: "locations", withExtension: "json"),
            let data = try? Data(contentsOf: url),
            // parsne data na array dictu
            let raw = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]]
        else { return [] }

        // convertne kazdy dict na RecyclingLocation
        return raw.compactMap { parse(from: $0) }
    }

    // bere dict a prevadi na RecyclingLocation — nonisolated: cista funkce bez sdileneno stavu
    private nonisolated func parse(from data: [String: Any], id: String? = nil) -> RecyclingLocation? {
        guard
            let locationId = id ?? data["id"] as? String,
            let categoryRaw = data["category"] as? String,
            let category = LocationCategory(rawValue: categoryRaw),
            let typesRaw = data["types"] as? [String],
            let statusRaw = data["status"] as? String,
            let status = LocationStatus(rawValue: statusRaw),
            let latitude = data["latitude"] as? Double,
            let longitude = data["longitude"] as? Double
        else { return nil }

        // firestore muze vratit stejne cislo jako Double, Int64 nebo Int, podle jeho hodnoty
        // zkousime vsechny 3, pokud zadnej nesedi, defaultujeme na 0
        let updatedAtMs = (data["updatedAt"] as? Double)
            ?? (data["updatedAt"] as? Int64).map(Double.init)
            ?? (data["updatedAt"] as? Int).map(Double.init)
            ?? 0
        // konvertnuti na swift date
        let updatedAt = Date(timeIntervalSince1970: updatedAtMs / 1000)
        let types = typesRaw.compactMap { WasteType(rawValue: $0) }

        let votes = data["votes"] as? [String: Bool] ?? [:]

        let addedAtMs = (data["addedAt"] as? Double)
            ?? (data["addedAt"] as? Int64).map(Double.init)
            ?? (data["addedAt"] as? Int).map(Double.init)
        let addedAt = addedAtMs.map { Date(timeIntervalSince1970: $0 / 1000) }

        return RecyclingLocation(
            id: locationId,
            category: category,
            types: types,
            status: status,
            votes: votes,
            imageData: data["imageData"] as? Data,
            addedAt: addedAt,
            latitude: latitude,
            longitude: longitude,
            updatedAt: updatedAt,
            addedBy: data["addedBy"] as? String,
            isPublic: data["isPublic"] as? Bool,
            hasFee: data["hasFee"] as? Bool,
            operatorName: data["operator"] as? String,
            phone: data["phone"] as? String,
            openingHours: data["openingHours"] as? String
        )
    }
}

private enum VoteError: Error {
    case notFound
}
