protocol UserManaging {
    func fetchUser(id: String) async throws -> AppUser
    func updateUser(_ user: AppUser) async throws
    func banUser(id: String, reason: String) async throws
    func unbanUser(id: String) async throws
    func fetchAllUsers() async throws -> [AppUser]
    func incrementVotesGiven(userId: String) async throws
}
