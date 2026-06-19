protocol AuthManaging {
    var currentUser: AppUser? { get }
    func signInWithGoogle() async throws -> AppUser
    func signOut() throws
    // synchronizuje currentUser po nacteni uplnych dat uzivatele z Firestore (role, ban, atd.)
    func updateCurrentUser(_ user: AppUser)
}
