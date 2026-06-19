import Foundation

@Observable
final class AuthViewModel {
    var state = AuthViewState()

    private var authManager: AuthManaging

    init() {
        authManager = DIContainer.shared.resolve()
        // zkontroluje prihlaseni — po restartu zustane uzivatel prihlaseny
    }

    // pouze pro preview a testy
    init(authManager: AuthManaging) {
        self.authManager = authManager
    }
    
    func syncCurrentUser() {
        state.currentUser = authManager.currentUser
    }

    func signInWithGoogle() async {
        state.isLoading = true
        state.error = nil

        do {
            state.currentUser = try await authManager.signInWithGoogle()
        } catch let authError as AuthError {
            state.error = authError.errorDescription
        } catch {
            state.error = "Něco se pokazilo. Zkuste to znovu."
        }

        state.isLoading = false
    }

    func signOut() {
        do {
            try authManager.signOut()
            state.currentUser = nil
        } catch {
            state.error = "Odhlášení se nezdařilo."
        }
    }
}
