import SwiftUI

enum AdminTab: String, CaseIterable, Identifiable {
    case reports
    case users

    var id: String { rawValue }

    var label: String {
        switch self {
        case .reports: return "Reporty"
        case .users:   return "Uživatelé"
        }
    }
}

struct AdminView: View {
    @State private var viewModel: AdminViewModel
    @State private var selectedTab: AdminTab = .reports
    // vyhledavaci text — sdileny pro oba taby, cisteno pri prepinani
    @State private var searchText = ""
    private let coordinator: AppCoordinator = DIContainer.shared.resolve()
    @Environment(\.dismiss) private var dismiss

    init(viewModel: AdminViewModel = AdminViewModel()) {
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {

                // prepinac tabu
                Picker("", selection: $selectedTab) {
                    ForEach(AdminTab.allCases) { tab in
                        Text(tab.label).tag(tab)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                .onChange(of: selectedTab) { _, _ in searchText = "" }

                // obsah aktivniho tabu
                switch selectedTab {
                case .reports:
                    ReportsListView(viewModel: viewModel, searchText: searchText)
                case .users:
                    UsersListView(viewModel: viewModel, searchText: searchText, coordinator: coordinator)
                }
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("Administrace")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left")
                            .fontWeight(.semibold)
                    }
                }
            }
            // searchable na NavigationStack — vzdy viditelne na obou tabech, zabraanuje skakani UI
            .searchable(
                text: $searchText,
                prompt: selectedTab == .reports ? "Hledat reporty..." : "Hledat uzivatele..."
            )
            .task {
                await viewModel.loadReports()
                await viewModel.loadUsers()
            }
            .alert("Chyba", isPresented: Binding(
                get: { viewModel.state.error != nil },
                set: { if !$0 { viewModel.state.error = nil } }
            )) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.state.error ?? "")
            }
        }
    }
}

// MARK: - Preview

#Preview {
    AdminView(viewModel: AdminViewModel(
        reportManager: MockReportManager(),
        userManager: MockUserManager(),
        authManager: MockAuthManager(),
    ))
}
