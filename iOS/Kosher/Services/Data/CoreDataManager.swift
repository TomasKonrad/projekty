import CoreData

final class CoreDataManager: DataManaging {
    private let container: NSPersistentContainer
    // jediny background context — databazove operace neblokuji main thread
    private lazy var context: NSManagedObjectContext = container.newBackgroundContext()

    // verze schematu — zvys kdyz se zmeni model, aby se cache automaticky smazala na existujicich instalacich
    private static let schemaVersion = 2
    private static let schemaVersionKey = "coredata_schema_version"

    init() {
        // pred nactenim zkontrolujeme verzi schematu — vrati 0 pokud klic neeixstuje (prvni spusteni)
        let storedVersion = UserDefaults.standard.integer(forKey: Self.schemaVersionKey)
        // pokud se nerovnaji, znamena to prvni spusteni nebo novy update aplikace
        if storedVersion != Self.schemaVersion {
            // CoreData je jen lokalni cache Firestore dat — muzeme ji bezpecne smazat
            let storeURL = NSPersistentContainer.defaultDirectoryURL()
            let base = storeURL.appendingPathComponent("Kosher")
            try? FileManager.default.removeItem(at: base.appendingPathExtension("sqlite"))
            try? FileManager.default.removeItem(at: base.appendingPathExtension("sqlite-wal"))
            try? FileManager.default.removeItem(at: base.appendingPathExtension("sqlite-shm"))
            // resetuj lastSync — jinak deltaSync preskoci bundle seed a nacte jen posledni zmeny; forcujeme tim cely refetch
            UserDefaults.standard.removeObject(forKey: "lastLocationSyncedAt")
            UserDefaults.standard.set(Self.schemaVersion, forKey: Self.schemaVersionKey)
        }
        container = NSPersistentContainer(name: "Kosher")
        container.loadPersistentStores { _, error in
            if let error { fatalError("CoreData store selhalo: \(error)") }
        }
    }

    func fetchLocations() async -> [RecyclingLocation] {
        await context.perform {
            let request = NSFetchRequest<RecyclingLocationEntity>(entityName: "RecyclingLocationEntity")
            let entities = (try? self.context.fetch(request)) ?? []
            return entities.compactMap { self.location(from: $0) }
        }
    }

    // vraci biny v zadanem bounding boxu — pouzito pro tile dotazy viewportu
    func fetchLocations(minLat: Double, maxLat: Double, minLon: Double, maxLon: Double) async -> [RecyclingLocation] {
        await context.perform {
            let request = NSFetchRequest<RecyclingLocationEntity>(entityName: "RecyclingLocationEntity")
            request.predicate = NSPredicate(
                format: "latitude >= %lf AND latitude <= %lf AND longitude >= %lf AND longitude <= %lf",
                minLat, maxLat, minLon, maxLon
            )
            let entities = (try? self.context.fetch(request)) ?? []
            return entities.compactMap { self.location(from: $0) }
        }
    }

    // smaze existujici zaznamy se stejnym ID a vlozi nove — zachovava ostatni zaznamy
    func upsertLocations(_ locations: [RecyclingLocation]) async {
        guard !locations.isEmpty else { return }
        await context.perform {
            let deleteReq = NSFetchRequest<NSFetchRequestResult>(entityName: "RecyclingLocationEntity")
            deleteReq.predicate = NSPredicate(format: "id IN %@", locations.map(\.id))
            _ = try? self.context.execute(NSBatchDeleteRequest(fetchRequest: deleteReq))

            guard let entityDesc = NSEntityDescription.entity(forEntityName: "RecyclingLocationEntity", in: self.context) else { return }
            let insert = NSBatchInsertRequest(entity: entityDesc, objects: locations.map { self.dictionary(from: $0) })
            _ = try? self.context.execute(insert)

            self.save()
        }
    }

    // smaze zaznamy podle ID — pouzivano pro cisteni binu smazanych z Firestore
    func deleteLocations(withIds ids: Set<String>) async {
        guard !ids.isEmpty else { return }
        await context.perform {
            let deleteReq = NSFetchRequest<NSFetchRequestResult>(entityName: "RecyclingLocationEntity")
            deleteReq.predicate = NSPredicate(format: "id IN %@", Array(ids))
            _ = try? self.context.execute(NSBatchDeleteRequest(fetchRequest: deleteReq))
            self.save()
        }
    }

    // MARK: - Mapping

    // prevedeni lokace na dict pro NSBatchInsertRequest
    private func dictionary(from location: RecyclingLocation) -> [String: Any] {
        var dict: [String: Any] = [
            "id":        location.id,
            "category":  location.category.rawValue,
            "types":     encodeTypes(location.types),
            "status":    location.status.rawValue,
            "latitude":  location.latitude,
            "longitude": location.longitude,
            "updatedAt": location.updatedAt,
        ]
        if let v = location.imageData    { dict["imagePath"]    = v.base64EncodedString() }
        if let v = location.addedAt      { dict["addedAt"]      = v }
        if let v = location.addedBy      { dict["addedBy"]      = v }
        if let v = location.isPublic     { dict["isPublic"]     = v }
        if let v = location.hasFee       { dict["hasFee"]       = v }
        if let v = location.operatorName { dict["operatorName"] = v }
        if let v = location.phone        { dict["phone"]        = v }
        if let v = location.openingHours { dict["openingHours"] = v }
        if !location.votes.isEmpty       { dict["votes"]        = encodeVotes(location.votes) }
        return dict
    }

    // konvertuje entity na model
    private func location(from entity: RecyclingLocationEntity) -> RecyclingLocation? {
        guard
            let id        = entity.id,
            let catRaw    = entity.category,
            let category  = LocationCategory(rawValue: catRaw),
            let statusRaw = entity.status,
            let status    = LocationStatus(rawValue: statusRaw),
            let types     = entity.types,
            let updatedAt = entity.updatedAt
        else { return nil }

        return RecyclingLocation(
            id:           id,
            category:     category,
            types:        decodeTypes(types),
            status:       status,
            votes:        decodeVotes(entity.votes ?? "{}"),
            imageData:    entity.imagePath.flatMap { Data(base64Encoded: $0) },
            addedAt:      entity.addedAt,
            latitude:     entity.latitude,
            longitude:    entity.longitude,
            updatedAt:    updatedAt,
            addedBy:      entity.addedBy,
            isPublic:     entity.isPublic,
            hasFee:       entity.hasFee,
            operatorName: entity.operatorName,
            phone:        entity.phone,
            openingHours: entity.openingHours
        )
    }

    // prevedeni arrayu do stringu pro ulozeni do CoreData a naopak
    private func encodeTypes(_ types: [WasteType]) -> String {
        let data = (try? JSONEncoder().encode(types.map(\.rawValue))) ?? Data()
        return String(data: data, encoding: .utf8) ?? "[]"
    }

    private func decodeTypes(_ string: String) -> [WasteType] {
        let data = string.data(using: .utf8) ?? Data()
        let rawValues = (try? JSONDecoder().decode([String].self, from: data)) ?? []
        return rawValues.compactMap { WasteType(rawValue: $0) }
    }

    // hlasy jsou ulozeny jako JSON string — [userId: Bool]
    private func encodeVotes(_ votes: [String: Bool]) -> String {
        let data = (try? JSONSerialization.data(withJSONObject: votes)) ?? Data()
        return String(data: data, encoding: .utf8) ?? "{}"
    }

    private func decodeVotes(_ string: String) -> [String: Bool] {
        let data = string.data(using: .utf8) ?? Data()
        return (try? JSONSerialization.jsonObject(with: data) as? [String: Bool]) ?? [:]
    }
}

// MARK: - Private methods
private extension CoreDataManager {
    func save() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("CoreDataManager save error: \(error.localizedDescription)")
            }
        }
    }
}
