import SwiftUI
import PhotosUI

@Observable
class AddBinViewState {
    // vybranna kategorie — kos nebo kontejner
    var selectedCategory: LocationCategory = .wasteBasket
    // vybrane typy odpadu — pro kos je automaticky zamceno na mixed
    var selectedWasteTypes: Set<WasteType> = [.mixed]
    // fotografie vybrana z galerie
    var selectedPhotoItem: PhotosPickerItem? = nil
    var selectedImage: UIImage? = nil
    // adresa ziskana reverznim geokodovanim ze souradnic
    var address: String? = nil
    var isLoadingAddress: Bool = false
    // stav odesilani
    var isSaving: Bool = false
    var error: String? = nil
    var didSave: Bool = false
    // vyplneno po uspesnem ulozeni — pouzito pro okamzitou aktualizaci pinu na mape
    var savedLocation: RecyclingLocation? = nil
}
