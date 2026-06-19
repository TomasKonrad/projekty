import SwiftUI

struct UsersListView: View {
    var viewModel: AdminViewModel
    // vyhledavaci text predavany z AdminView — neni lokalni stav
    let searchText: String
    let coordinator: AppCoordinator

    var filteredUsers: [AppUser] {
        if searchText.isEmpty { return viewModel.filteredUsers }
        return viewModel.filteredUsers.filter {
            $0.displayName.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        VStack(spacing: 0) {

            // filtr podle stavu uctu
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(UserFilter.allCases) { filter in
                        FilterChip(
                            label: filter.label,
                            isSelected: viewModel.state.selectedUserFilter == filter
                        ) {
                            viewModel.state.selectedUserFilter = filter
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
            }

            // seznam uzivatelu
            if viewModel.state.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if filteredUsers.isEmpty {
                Text("Žádní uživatelé.")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(filteredUsers) { user in
                            NavigationLink {
                                UserDetailView(user: user, viewModel: viewModel, coordinator: coordinator)
                            } label: {
                                UserRowView(user: user)
                            }
                        }
                    }
                    .padding()
                }
            }
        }
    }
}
