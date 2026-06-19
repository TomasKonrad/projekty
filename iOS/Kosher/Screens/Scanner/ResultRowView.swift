import SwiftUI
import CoreLocation

// radek s vysledkem identifikace — lze rozbalit pro zobrazeni detailu
struct ResultRowView: View {
    let item: ScannedItem
    let isExpanded: Bool
    let onTap: () -> Void
    var onShowOnMap: ((RecyclingLocation) -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            headerRow
            if isExpanded { expandedContent }
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 28))
        .shadow(color: .black.opacity(0.07), radius: 12, x: 0, y: 2)
    }

    // MARK: - Zahlavi (vzdy viditelne)

    private var headerRow: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                // barevny kruh s ikonou kategorie
                Circle()
                    .fill(item.category.color.opacity(0.18))
                    .frame(width: 48, height: 48)
                    .overlay {
                        Image(systemName: item.category.systemImage)
                            .font(.system(size: 22, weight: .medium))
                            .foregroundStyle(item.category.color)
                    }

                // nazev objektu — vzdy cerne aby byl dobre citelny
                Text(item.objectName)
                    .font(.headline)
                    .foregroundStyle(Color(.label))

                Spacer()

                // chevron.right = zabaleno, chevron.down = rozbaleno
                Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.secondary)
            }
            .padding(16)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    // MARK: - Rozbaleny obsah

    private var expandedContent: some View {
        VStack(alignment: .leading, spacing: 14) {
            Divider()
                .padding(.horizontal, 16)

            VStack(alignment: .leading, spacing: 12) {
                // Gemini AI badge
                Label("Gemini AI rozbor • \(Int(item.confidence * 100))% jistota",
                      systemImage: "sparkles")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                // dve info karty vedle sebe — kategorie a recyklovatelnost
                HStack(spacing: 10) {
                    infoCard(
                        label: "Kategorie",
                        value: item.category.label,
                        valueColor: item.category.color
                    )
                    infoCard(
                        label: "Recyklovatelné",
                        value: item.isRecyclable ? "Ano" : "Ne",
                        valueColor: item.isRecyclable ? .green : .red
                    )
                }

                // instrukce co delat s odpadem
                Text(item.instruction)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                // karta nejblizsiho sberne mista — zobrazena jen kdyz je lokace k dispozici
                if let location = item.nearestLocation {
                    nearestLocationSection(location)
                        .padding(.top, 8)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
    }

    // MARK: - Nejblizsi sberne misto

    private func nearestLocationSection(_ location: RecyclingLocation) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            // sberny dvur ma specificky popisek — zduraznuje ze odpad nelze vyhodit do kontejneru
            Text(item.spotCategory == .collectionYard ? "Nejbližší sběrný dvůr" : "Nejbližší sběrné místo")
                .font(.caption)
                .foregroundStyle(.secondary)

            NearestLocationCard(location: location)

            // tlacitko pro zobrazeni detailu a prepnuti na mapu
            Button { onShowOnMap?(location) } label: {
                Label("Zobrazit na mapě", systemImage: "map")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.green, in: Capsule())
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Info karta

    // karta s malym sivym popiskem a tucnou hodnotou
    private func infoCard(label: String, value: String, valueColor: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.title3.weight(.bold))
                .foregroundStyle(valueColor)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Karta nejblizsiho sberne mista

// kompaktni karta s miniaturou, nazvem a vzdalenosti od uzivatele
private struct NearestLocationCard: View {
    let location: RecyclingLocation
    @State private var address: String?

    private let geocodingService: GeocodingManaging = DIContainer.shared.resolve()
    private let locationService:  LocationManaging  = DIContainer.shared.resolve()

    // vzdalenost od aktualni polohy — nil kdyz GPS neni k dispozici
    private var distance: String? {
        guard let userCoord = locationService.getCurrentLocation() else { return nil }
        let userLoc = CLLocation(latitude: userCoord.latitude, longitude: userCoord.longitude)
        let binLoc  = CLLocation(latitude: location.latitude,  longitude: location.longitude)
        let meters  = binLoc.distance(from: userLoc)
        return meters < 1000
            ? "\(Int(meters.rounded()))m"
            : String(format: "%.1fkm", meters / 1000)
    }

    var body: some View {
        HStack(spacing: 12) {
            // miniatura fotky lokace — fallback na ikonu kategorie
            Group {
                if let data = location.imageData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                } else {
                    Image(systemName: location.category.mapIcon)
                        .font(.system(size: 20))
                        .foregroundStyle(Color(.systemGray3))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color(.systemGray5))
                }
            }
            .frame(width: 64, height: 64)
            .clipShape(RoundedRectangle(cornerRadius: 14))

            VStack(alignment: .leading, spacing: 4) {
                Text(location.category.detailTitle)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color(.label))

                // adresa a vzdalenost oddelene teckou — zobrazime co mame k dispozici
                let subtitle = [address, distance].compactMap { $0 }.joined(separator: " • ")
                if !subtitle.isEmpty {
                    Label(subtitle, systemImage: "mappin")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
            }

            Spacer()
        }
        .padding(12)
        .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 1)
        .task(id: location.id) {
            let coord = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            address = try? await geocodingService.reverseGeocode(coordinate: coord)
        }
    }
}
