import SwiftUI

// tenka obalova vrstva pro profil uzivatele v kontextu administrace
struct UserDetailView: View {
    let user: AppUser
    var viewModel: AdminViewModel
    let coordinator: AppCoordinator

    var body: some View {
        UserProfileView(
            user: user,
            contributions: viewModel.state.selectedUserContributions,
            isLoadingContributions: viewModel.state.isLoadingContributions,
            coordinator: coordinator,
            mode: .otherUser(
                currentUserId: viewModel.currentUserId,
                onBan:   { reason in await viewModel.banUser(id: user.id, reason: reason) },
                onUnban: { await viewModel.unbanUser(id: user.id) }
            )
        )
        // nacteni prispevku pri otevreni — cisteno pri kazdem otevreni aby se nezobrazovala stara data
        .task { await viewModel.loadContributions(for: user.id) }
    }
}

#Preview {
    NavigationStack {
        UserDetailView(
            user: .getSample(),
            viewModel: AdminViewModel(
                reportManager: MockReportManager(),
                userManager: MockUserManager(),
                authManager: MockAuthManager(),
            ),
            coordinator: AppCoordinator()
        )
    }
}
