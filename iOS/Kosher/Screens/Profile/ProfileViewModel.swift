import Foundation

@Observable
final class ProfileViewModel {
    var state = ProfileViewState()

    private var authManager: AuthManaging
    private var userManager: UserManaging
    private var locationManager: RecyclingLocationManaging

    init() {
        authManager = DIContainer.shared.resolve()
        userManager = DIContainer.shared.resolve()
        locationManager = DIContainer.shared.resolve()
        state.user = authManager.currentUser
    }

    // pouze pro preview a testy
    init(authManager: AuthManaging, userManager: UserManaging, locationManager: RecyclingLocationManaging) {
        self.authManager = authManager
        self.userManager = userManager
        self.locationManager = locationManager
    }

    func loadUser() async {
        guard let current = authManager.currentUser else { return }
        state.isLoading = true

        do {
            let fetched: AppUser
            do {
                fetched = try await userManager.fetchUser(id: current.id)
            } catch UserError.notFound {
                // novy uzivatel — zalozime dokument ve Firestore
                try await userManager.updateUser(current)
                fetched = current
            }
            // zabanovanemu uzivateli nezobrazime profil
            if fetched.isBanned {
                signOut()
                state.error = "Váš účet byl zablokován\(fetched.banReason.map { ": \($0)" } ?? "")."
                state.isLoading = false
                return
            }
            state.user = fetched
            // aktualizujeme authManager aby ostatni viewmodely (napr. MapViewModel) videly spravnou roli
            authManager.updateCurrentUser(fetched)
            await loadContributions()
        } catch {
            state.error = "Nepodařilo se načíst profil."
        }

        state.isLoading = false
    }

    func signOut() {
        do {
            try authManager.signOut()
            state.user = nil
        } catch {
            state.error = "Odhlášení se nezdařilo."
        }
    }

    // MARK: - Private

    private func loadContributions() async {
        guard let user = state.user else { return }
        // dotaz primo do Firestore — neni zavisle na lokalni cache, funguje i po reinstalaci
        state.contributions = await locationManager.fetchLocations(byUser: user.id)
    }
}
