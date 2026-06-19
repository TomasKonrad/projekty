import UIKit

// mozne stavy obrazovky skeneru
enum ScannerLoadingState {
    case idle        // zadna fotografie neni vybrana
    case analyzing   // AI analyza probiha
    case done        // vysledky jsou pripraveny
    case failed(String) // analyza selhala — obsahuje chybovou zpravu
}

@Observable
class ScannerViewState {
    // aktualni stav obrazovky — ridi co se zobrazi
    var loadingState: ScannerLoadingState = .idle
    // fotografie vybrana uzivatelem z galerie nebo fotoaparatu
    var selectedImage: UIImage? = nil
    // vysledky identifikace — az tri rozpoznane objekty
    var results: [ScannedItem] = []
}
