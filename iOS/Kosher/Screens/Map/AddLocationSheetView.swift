import SwiftUI
import MapKit

struct AddLocationSheetView: View {
    let coordinate: CLLocationCoordinate2D
    let onContinue: (CLLocationCoordinate2D) -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        // spacing: 0 + padding na ZStacku — identicka struktura jako FilterSheetView
        VStack(alignment: .leading, spacing: 0) {
            ZStack {
                Text("Přidat sběrné místo")
                    .font(.headline)
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Color(.label))
                            .frame(width: 36, height: 36)
                            .glassEffect(in: Circle())
                    }
                    .buttonStyle(.plain)
                    Spacer()
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)

            VStack(alignment: .leading, spacing: 20) {
                Text("Posunutím špendlíku vyberte koordinace.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                HStack(spacing: 12) {
                    coordinateCard(label: "Latitude", value: coordinate.latitude)
                    coordinateCard(label: "Longitude", value: coordinate.longitude)
                }

                Button {
                    onContinue(coordinate)
                } label: {
                    Text("Pokračovat")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.primary, in: Capsule())
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }

    private func coordinateCard(label: String, value: Double) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(String(format: "%.6f", value))
                .font(.title3.weight(.semibold))
                .foregroundStyle(Color.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 20))
    }
}
