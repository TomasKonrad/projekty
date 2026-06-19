struct AppUser: Identifiable, Equatable {
    var id: String
    var email: String
    var displayName: String
    var avatarURL: String? 
    var location: String?
    var role: UserRole
    var isBanned: Bool
    var banReason: String?
    var itemsScanned: Int
    var votesGiven: Int
    var contributionIds: [String]

    static func getSample() -> AppUser {
        AppUser(
            id: "user_1",
            email: "user@gmail.com",
            displayName: "MilujiRecyklaci123",
            avatarURL: nil,
            location: "Park Lužánky, Brno-střed",
            role: .user,
            isBanned: false,
            banReason: nil,
            itemsScanned: 5,
            votesGiven: 3,
            contributionIds: ["sample_1", "sample_yard_1"]
        )
    }

    static func getSampleModerator() -> AppUser {
        AppUser(
            id: "mod_1",
            email: "mod@gmail.com",
            displayName: "Moderátor",
            avatarURL: nil,
            location: nil,
            role: .moderator,
            isBanned: false,
            banReason: nil,
            itemsScanned: 0,
            votesGiven: 0,
            contributionIds: []
        )
    }
}
