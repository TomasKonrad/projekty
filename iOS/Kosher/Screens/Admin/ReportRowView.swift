import SwiftUI

struct ReportRowView: View {
    let report: Report
    let location: RecyclingLocation?
    let viewModel: AdminViewModel
    // singleton — navigace na mapu pri tapnuti na report
    private let coordinator: AppCoordinator = DIContainer.shared.resolve()

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            if let location {
                if let data = location.imageData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 80, height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                } else {
                    Image(systemName: location.category.mapIcon)
                        .font(.system(size: 32))
                        .foregroundStyle(.secondary)
                        .frame(width: 80, height: 80)
                        .background(Color(.systemGray5))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    // dovod reportu misto nazvu kategorie
                    Text(report.type.label)
                        .font(.headline)

                    Spacer()

                    // status badge
                    Text(report.status.label)
                        .font(.caption)
                        .fontWeight(.medium)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(report.status.color)
                        .foregroundStyle(LocationStatus.textColor)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                // adresa lokace
                if let location {
                    AddressLabel(location: location)
                } else {
                    Text(report.locationId)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer(minLength: 0)

                Text(report.date.formatted(.relative(presentation: .named).locale(Locale(identifier: "cs_CZ"))))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(minHeight: 72)
        }
        .padding()
        .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.07), radius: 12, x: 0, y: 2)
        // tap — otevre bin na mape
        .onTapGesture {
            guard let location else { return }
            coordinator.pendingMapLocation = location
        }
        // dlouhy stisk — zmena statusu reportu
        .contextMenu {
            Label("Označit jako", systemImage: "tag")
            Button {
                Task { await viewModel.updateReportStatus(reportId: report.id, status: .pending) }
            } label: {
                Label("K řešení", systemImage: "exclamationmark")
            }
            Button {
                Task { await viewModel.updateReportStatus(reportId: report.id, status: .dismissed) }
            } label: {
                Label("Řeší se", systemImage: "arrow.clockwise")
            }
            Button {
                Task { await viewModel.updateReportStatus(reportId: report.id, status: .resolved) }
            } label: {
                Label("Vyřešeno", systemImage: "checkmark")
            }
        }
    }
}

// MARK: - Preview

#Preview {
    ReportRowView(
        report: .getSample(),
        location: .getSample(),
        viewModel: AdminViewModel(
            reportManager: MockReportManager(),
            userManager: MockUserManager(),
            authManager: MockAuthManager(),
        )
    )
    .padding()
    .background(Color(.systemGroupedBackground))
}
