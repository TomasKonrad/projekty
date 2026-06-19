import UIKit

// protokol pro identifikaci odpadu pomoci AI — vstup je fotka, vystup je pole rozpoznanych objektu
protocol ScannerManaging {
    func analyze(image: UIImage) async throws -> [ScannedItem]
}
