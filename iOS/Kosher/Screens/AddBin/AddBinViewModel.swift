import Foundation
import MapKit
import PhotosUI
import SwiftUI

@Observable
class AddBinViewModel {
    var state: AddBinViewState = AddBinViewState()
    let coordinate: CLLocationCoordinate2D

    private let existingLocation: RecyclingLocation?
    private var locationService: RecyclingLocationManaging
    private var authManager: AuthManaging
    private var geocodingService: GeocodingManaging

    // kategorie dostupne pri rucnim pridavani — sberny dvur se pridava jinym zpusobem
    static let availableCategories: [LocationCategory] = [.wasteBasket, .recyclingSpot]
    // typy odpadu relevantni pro kontejnery a kose
    static let recyclingWasteTypes: [WasteType] = [.mixed, .glass, .plastic, .paper, .bio, .eWaste, .metals, .cartons]

    var isEditing: Bool { existingLocation != nil }

    // pridani nove lokace — souradnice zadana uzivatelem z mapy
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
        self.existingLocation = nil
        locationService  = DIContainer.shared.resolve()
        authManager      = DIContainer.shared.resolve()
        geocodingService = DIContainer.shared.resolve()
    }

    // uprava existujici lokace — souradnice prevzata z lokace, stav predvyplnen
    init(existingLocation: RecyclingLocation) {
        self.coordinate = CLLocationCoordinate2D(
            latitude: existingLocation.latitude,
            longitude: existingLocation.longitude
        )
        self.existingLocation = existingLocation
        locationService  = DIContainer.shared.resolve()
        authManager      = DIContainer.shared.resolve()
        geocodingService = DIContainer.shared.resolve()

        state.selectedCategory   = existingLocation.category
        state.selectedWasteTypes = Set(existingLocation.types)
        // predvyplnime existujici fotku aby ji uzivatel videl a mohl nahradit
        if let data = existingLocation.imageData { state.selectedImage = UIImage(data: data) }
    }

    // reverzni geokodovani — nacte lidsky citelnou adresu pro zobrazeni pod mapou
    func loadAddress() async {
        state.isLoadingAddress = true
        state.address = try? await geocodingService.reverseGeocode(coordinate: coordinate)
        state.isLoadingAddress = false
    }

    // zmeni kategorii — prechod na kos automaticky nastavi typ na mixed a zamkne vyber
    func selectCategory(_ category: LocationCategory) {
        state.selectedCategory = category
        state.selectedWasteTypes = category == .wasteBasket ? [.mixed] : []
    }

    // prepne typ odpadu — ignorovano kdyz je kos (typy jsou zamcene)
    func toggleWasteType(_ type: WasteType) {
        guard state.selectedCategory != .wasteBasket else { return }
        if state.selectedWasteTypes.contains(type) {
            state.selectedWasteTypes.remove(type)
        } else {
            state.selectedWasteTypes.insert(type)
        }
    }

    // nacte UIImage z vybrane PhotosPickerItem
    func loadPhoto(from item: PhotosPickerItem?) async {
        guard let item else { state.selectedImage = nil; return }
        if let data = try? await item.loadTransferable(type: Data.self),
           let image = UIImage(data: data) {
            state.selectedImage = image
        }
    }

    // zkomprimuje fotku na maximalne 400px a kvalitu 0.3 — optimalizovano pro ulozeni v Firestore
    private func compressImage(_ image: UIImage?) -> Data? {
        guard let image else { return nil }
        let maxSide: CGFloat = 400
        let scale = min(maxSide / image.size.width, maxSide / image.size.height, 1)
        let newSize = CGSize(width: image.size.width * scale, height: image.size.height * scale)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        let resized = renderer.image { _ in image.draw(in: CGRect(origin: .zero, size: newSize)) }
        return resized.jpegData(compressionQuality: 0.3)
    }

    func submit() async {
        guard authManager.currentUser != nil else {
            state.error = "Pro přidání sběrného místa se musíte přihlásit."
            return
        }
        state.isSaving = true
        do {
            if let existing = existingLocation {
                // rezim upravy — zachovame id, souradnice, addedBy a addedAt
                var updated = existing
                updated.category  = state.selectedCategory
                updated.types     = Array(state.selectedWasteTypes)
                updated.updatedAt = Date()
                // aplikuj novou fotku jen kdyz uzivatel vybral jinou — jinak zachovame puvodni
                if let newImage = state.selectedImage {
                    updated.imageData = compressImage(newImage)
                }
                try await locationService.updateLocation(updated)
                state.savedLocation = updated
            } else {
                // rezim pridani — moderator ziska aktivni status okamzite, uzivatel ceka na schvaleni
                let isModerator = authManager.currentUser?.role == .moderator
                let now = Date()
                let locationId = UUID().uuidString
                // komprese fotky pred ulozenim do Firestore
                let imageData = compressImage(state.selectedImage)
                let location = RecyclingLocation(
                    id: locationId,
                    category: state.selectedCategory,
                    types: Array(state.selectedWasteTypes),
                    status: isModerator ? .active : .pending,
                    votes: [:],
                    imageData: imageData,
                    addedAt: now,
                    latitude: coordinate.latitude,
                    longitude: coordinate.longitude,
                    updatedAt: now,
                    addedBy: authManager.currentUser?.id
                )
                try await locationService.createLocation(location)
                state.savedLocation = location
            }
            state.didSave = true
        } catch {
            state.error = isEditing
                ? "Nepodařilo se upravit sběrné místo."
                : "Nepodařilo se přidat sběrné místo."
        }
        state.isSaving = false
    }
}
