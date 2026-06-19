import SwiftUI

struct ReportsListView: View {
    @Bindable var viewModel: AdminViewModel
    let searchText: String

    // filtruje dle statusu a vyhledavaciho textu — typ reportu a ulice z geokodovani
    var displayedReports: [Report] {
        guard !searchText.isEmpty else { return viewModel.filteredReports }
        return viewModel.filteredReports.filter {
            $0.type.label.localizedCaseInsensitiveContains(searchText) ||
            (viewModel.state.addresses[$0.locationId] ?? "").localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        VStack(spacing: 0) {

            // filtry podle statusu
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    FilterChip(
                        label: "Všechny",
                        isSelected: viewModel.state.selectedReportFilter == nil
                    ) {
                        viewModel.state.selectedReportFilter = nil
                    }
                    ForEach([ReportStatus.pending, .resolved, .dismissed], id: \.self) { status in
                        FilterChip(
                            label: status.label,
                            isSelected: viewModel.state.selectedReportFilter == status
                        ) {
                            viewModel.state.selectedReportFilter = status
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
            }

            if viewModel.state.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if displayedReports.isEmpty {
                Text("Žádné reporty.")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(displayedReports) { report in
                            ReportRowView(
                                report: report,
                                location:viewModel.state.locations[report.locationId],
                                viewModel: viewModel)
                        }
                    }
                    .padding()
                }
            }
        }
    }
}
