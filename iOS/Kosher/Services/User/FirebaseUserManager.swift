import Foundation
import FirebaseFirestore

final class FirebaseUserManager: UserManaging {
    private let db = Firestore.firestore()
    private let collection = "users"

    // práce pouze s firebase databází
    func fetchUser(id: String) async throws -> AppUser {
        let snapshot = try await db
            .collection(collection)
            .document(id)
            .getDocument()

        guard let data = snapshot.data() else {
            throw UserError.notFound
        }

        return try parse(from: data, id: id)
    }

    func updateUser(_ user: AppUser) async throws {
        try await db.collection(collection)
            .document(user.id)
            .setData(dictionary(from: user))
    }

    func banUser(id: String, reason: String) async throws {
        try await db.collection(collection)
            .document(id)
            .updateData([
                "isBanned": true,
                "banReason": reason
        ])
    }

    func unbanUser(id: String) async throws {
        try await db.collection(collection)
            .document(id)
            .updateData([
                "isBanned": false,
                "banReason": NSNull() //duvod existuje, ale žádný není
        ])
    }

    func incrementVotesGiven(userId: String) async throws {
        try await db.collection(collection).document(userId).updateData([
            "votesGiven": FieldValue.increment(Int64(1))
        ])
    }

    func fetchAllUsers() async throws -> [AppUser] {
        let snapshot = try await db
            .collection(collection)
            .getDocuments()
        return snapshot.documents.compactMap { doc in
            try? parse(from: doc.data(), id: doc.documentID)
        }
    }

    // MARK: - Mapping

    //převedení AppUser na firebase strukturu
    private func dictionary(from user: AppUser) -> [String: Any] {
        var dict: [String: Any] = [
            "email":           user.email,
            "displayName":     user.displayName,
            "role":            user.role.rawValue,
            "isBanned":        user.isBanned,
            "itemsScanned":    user.itemsScanned,
            "votesGiven":      user.votesGiven,
            "contributionIds": user.contributionIds
        ]
        // volitelné atributy
        if let avatarURL = user.avatarURL  { dict["avatarURL"]  = avatarURL }
        if let location = user.location   { dict["location"]   = location }
        if let banReason = user.banReason  { dict["banReason"]  = banReason }
        return dict
    }

    //firestore struktura na AppUser datový typ
    private func parse(from data: [String: Any], id: String) throws -> AppUser {
        guard
            let email       = data["email"]       as? String,
            let displayName = data["displayName"] as? String,
            let roleRaw     = data["role"]        as? String,
            let role        = UserRole(rawValue: roleRaw)
        else { throw UserError.invalidData }

        return AppUser(
            id:              id,
            email:           email,
            displayName:     displayName,
            avatarURL:       data["avatarURL"]      as? String,
            location:        data["location"]       as? String,
            role:            role,
            isBanned:        data["isBanned"]        as? Bool ?? false,
            banReason:       data["banReason"]       as? String,
            itemsScanned:    data["itemsScanned"]    as? Int ?? 0,
            votesGiven:      data["votesGiven"]      as? Int ?? 0,
            contributionIds: data["contributionIds"] as? [String] ?? []
        )
    }
}
