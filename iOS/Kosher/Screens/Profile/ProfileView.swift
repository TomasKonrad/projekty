import SwiftUI

// obalova vrstva profil-tabu — resi NavigationStack a prehled prihlaseni/odhlaseni
struct ProfileView: View {
    var authViewModel: AuthViewModel
    @State private var viewModel: ProfileViewModel
    var onSignOut: (() -> Void)?
    // koordinator je singleton predany z ContentView — neresolvi se zde z DI
    var coordinator: AppCoordinator
    @Environment(\.dismiss) private var dismiss

    init(authViewModel: AuthViewModel,
         viewModel: ProfileViewModel = ProfileViewModel(),
         coordinator: AppCoordinator = AppCoordinator(),
         onSignOut: (() -> Void)? = nil) {
        self.authViewModel = authViewModel
        self.viewModel     = viewModel
        self.coordinator   = coordinator
        self.onSignOut     = onSignOut
    }

    var body: some View {
        NavigationStack {
            Group {
                if let user = viewModel.state.user {
                    UserProfileView(
                        user: user,
                        contributions: viewModel.state.contributions,
                        coordinator: coordinator,
                        mode: .ownProfile {
                            viewModel.signOut()
                            onSignOut?()
                        }
                    )
                    .task { await viewModel.loadUser() }
                } else {
                    AuthView(
                        viewModel: authViewModel,
                        onSignedIn: {
                            Task {
                                await viewModel.loadUser()
                                authViewModel.state.currentUser = viewModel.state.user
                                // loadUser odhlasi zabanovanho uzivatele a nastavi error — preneseme ho do AuthView
                                if viewModel.state.user == nil, let error = viewModel.state.error {
                                    authViewModel.state.error = error
                                    viewModel.state.error = nil
                                }
                            }
                        }
                    )
                }
            }
            // tlacitko zavreni sheetu — vzdy viditelne bez ohledu na stav prihlaseni
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
 
                    }
                }
            }
        }
        // prihlaseni dokonceno pred otevrenim sheetu — onChange by se nespustilo
        .task {
            // okamzite nastavime uzivatele ze auth stavu — predejdeme blikani odhlasene obrazovky
            if viewModel.state.user == nil {
                viewModel.state.user = authViewModel.state.currentUser
            }
            guard authViewModel.state.currentUser != nil else { return }
            await viewModel.loadUser()
        }
        // je potřeba, aby ProfileView zaregistrovala přihlášení odjinut (třeba scanner)
        // oldUser zahazujeme, newUser potřebujeme, pokud je uživatel nově přihlášen, zobrazá se mu jeho profil
        .onChange(of: authViewModel.state.currentUser) { _, newUser in
            guard newUser != nil else { return }
            Task {
                await viewModel.loadUser()
            }
        }
    }
}

// MARK: - Preview

#Preview("Přihlášený uživatel") {
    let viewModel = ProfileViewModel(
        authManager: MockAuthManager(),
        userManager: MockUserManager(),
        locationManager: MockRecyclingLocationManager()
    )
    viewModel.state.user = .getSample()
    viewModel.state.contributions = [.getSample(), .getSampleYard()]
    return ProfileView(authViewModel: AuthViewModel(authManager: MockAuthManager()), viewModel: viewModel)
}

#Preview("Nepřihlášený uživatel") {
    let viewModel = ProfileViewModel(
        authManager: MockAuthManager(),
        userManager: MockUserManager(),
        locationManager: MockRecyclingLocationManager()
    )
    return ProfileView(authViewModel: AuthViewModel(authManager: MockAuthManager()), viewModel: viewModel)
}
