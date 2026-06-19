final class MockUserManager: UserManaging {
    private var users: [String: AppUser] = [
        "user_1": .getSample(),
        "mod_1": .getSampleModerator()
    ]

    func fetchUser(id: String) async throws -> AppUser {
        guard let user = users[id] else { throw UserError.notFound }
        return user
    }

    func updateUser(_ user: AppUser) async throws {
        users[user.id] = user
    }

    func banUser(id: String, reason: String) async throws {
        guard var user = users[id] else { throw UserError.notFound }
        user.isBanned = true
        user.banReason = reason
        users[id] = user
    }

    func unbanUser(id: String) async throws {
        guard var user = users[id] else { throw UserError.notFound }
        user.isBanned = false
        user.banReason = nil
        users[id] = user
    }

    func fetchAllUsers() async throws -> [AppUser] {
        Array(users.values)
    }

    func incrementVotesGiven(userId: String) async throws {
        guard var user = users[userId] else { throw UserError.notFound }
        user.votesGiven += 1
        users[userId] = user
    }
}
