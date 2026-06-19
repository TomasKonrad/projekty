final class MockAuthManager: AuthManaging {
    private(set) var currentUser: AppUser? //čitelná kdykoly, zápis lze jen uvnitř třídy

    func signInWithGoogle() async throws -> AppUser {
        let user = AppUser.getSample()
        currentUser = user
        return user
    }

    func signOut() throws {
        currentUser = nil
    }

    func updateCurrentUser(_ user: AppUser) {
        currentUser = user
    }
}
