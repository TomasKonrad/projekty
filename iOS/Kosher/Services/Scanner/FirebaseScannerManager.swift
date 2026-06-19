import UIKit
import FirebaseAI

// implementace skeneru pres Firebase AI (Gemini) — analyzuje fotografii a vraci strukturovana data
final class FirebaseScannerManager: ScannerManaging {

    private let model: GenerativeModel

    // prompt pro Gemini — strucny format snizuje pocet tokenu pri zachovani presnosti
    private let prompt = """
    Identify waste in the photo. Raw JSON only — no markdown, no text outside JSON.
    Return up to 3 objects:
    [{"object_name":"Czech name","category":"...","spot_type":"...","recyclable":true,"instruction":"Czech instruction","confidence":0.0}]

    category (pick one): mixed|plastic|glass|paper|bio|cartons|metals|clothes|e-waste|furniture|wood|tyres|paint|hazardous|rubble|oil|drugs
    spot_type (pick one): waste_basket|recycling_spot|collection_yard
      waste_basket = mixed only
      recycling_spot = plastic,glass,paper,bio,cartons,metals,clothes,oil,drugs
                       e-waste ONLY if small (phones,cables,batteries,small electronics)
      collection_yard = furniture,wood,tyres,paint,hazardous,rubble
                        e-waste if large appliance (fridge,washing machine,TV,dishwasher,oven,boiler…)
    recyclable = false if contaminated/broken/non-recyclable in current state
    instruction = short Czech action ("Vhoďte do žlutého kontejneru", "Odvezte do sběrného dvora" …)
    confidence = 0.0–1.0
    """

    init() {
        let ai = FirebaseAI.firebaseAI(backend: .googleAI())
        model = ai.generativeModel(modelName: "gemini-2.5-flash")
    }

    func analyze(image: UIImage) async throws -> [ScannedItem] {
        // odesleme obrazek spolu s promptem do Gemini — nejdriv zkomprimujeme
        let compressed = image.compressed(maxSide: 768, quality: 0.6)
        let response = try await model.generateContent(compressed, prompt)
        guard let text = response.text else { throw ScannerError.emptyResponse }

        // ocistime odpoved od pripadnych markdown bloku kdyby AI ignorovala instrukce
        var json = text
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        // extrahujeme jen JSON pole od prvni [ po posledni ]
        if let start = json.firstIndex(of: "["), let end = json.lastIndex(of: "]") {
            json = String(json[start...end])
        }

        guard let data = json.data(using: .utf8) else { throw ScannerError.parsingFailed }
        let decoded = try JSONDecoder().decode([ScannerItemResponse].self, from: data)
        return decoded.compactMap { ScannedItem(from: $0) }
    }
}

// MARK: - Decodable model pro odpoved AI

private struct ScannerItemResponse: Decodable {
    let objectName: String
    let category: String
    let spotType: String
    let recyclable: Bool
    let instruction: String
    let confidence: Double

    enum CodingKeys: String, CodingKey {
        case objectName  = "object_name"
        case category
        case spotType    = "spot_type"
        case recyclable
        case instruction
        case confidence
    }
}

// MARK: - Mapovani odpovedi na ScannedItem

private extension ScannedItem {
    // prevede odpoved AI na domenovy model — neznamy typ odpadu se mapuje na mixed
    init?(from response: ScannerItemResponse) {
        let wasteType    = WasteType(rawValue: response.category)          ?? .mixed
        let spotCategory = LocationCategory(rawValue: response.spotType)   ?? .recyclingSpot
        self.init(
            objectName:   response.objectName,
            category:     wasteType,
            spotCategory: spotCategory,
            isRecyclable: response.recyclable,
            instruction:  response.instruction,
            confidence:   response.confidence
        )
    }
}

// MARK: - Pomocna komprese obrazku

private extension UIImage {
    // zmenseni na maximalni rozmer a komprese JPEG — snizuje velikost requestu a zrychluje odpoved
    func compressed(maxSide: CGFloat, quality: CGFloat) -> UIImage {
        let scale = min(maxSide / size.width, maxSide / size.height, 1.0)
        guard scale < 1.0 else { return self }
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in draw(in: CGRect(origin: .zero, size: newSize)) }
    }
}

// MARK: - Chyby skeneru

enum ScannerError: LocalizedError {
    case emptyResponse
    case parsingFailed

    var errorDescription: String? {
        switch self {
        case .emptyResponse:  "Gemini nevrátil žádnou odpověď."
        case .parsingFailed:  "Odpověď AI se nepodařilo zpracovat."
        }
    }
}
