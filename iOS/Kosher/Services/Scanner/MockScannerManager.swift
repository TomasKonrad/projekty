import UIKit

// mock implementace pro preview a testy — vraci predpripravena data po kratke pauze
final class MockScannerManager: ScannerManaging {
    func analyze(image: UIImage) async throws -> [ScannedItem] {
        try? await Task.sleep(for: .seconds(1))
        return [
            ScannedItem(
                objectName:   "Plastová láhev",
                category:     .plastic,
                spotCategory: .recyclingSpot,
                isRecyclable: true,
                instruction:  "Sešlápněte a vhoďte do žlutého kontejneru na plast.",
                confidence:   0.96
            ),
            ScannedItem(
                objectName:   "Papírový obal",
                category:     .paper,
                spotCategory: .recyclingSpot,
                isRecyclable: true,
                instruction:  "Složte a vhoďte do modrého kontejneru na papír.",
                confidence:   0.81
            ),
        ]
    }
}
