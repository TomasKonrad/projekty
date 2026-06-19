import Foundation
import FirebaseAuth
import GoogleSignIn

final class FirebaseAuthManager: AuthManaging {
    private(set) var currentUser: AppUser?
    //proměnné pro udržení session
    private var authStateListener: AuthStateDidChangeListenerHandle?
    private var userManager: UserManaging { DIContainer.shared.resolve() }
    
    // registrace listener
    // weak self - kvůli potenciálnímu memory leaku
    init() {
        authStateListener = Auth.auth().addStateDidChangeListener { [weak self] _, firebaseUser in
            guard let self else { return }
            guard let firebaseUser else {
                self.currentUser = nil
                return
            }
            Task {
                // načteme plný AppUser z Firestore včetně role, isBanned atd.
                if let user = try? await self.userManager.fetchUser(id: firebaseUser.uid) {
                    self.currentUser = user
                }
            }
        }
    }
    
    // odregistrace listeneru, je potřebná, aby se přestal volat listener po ukončení aplikace
    deinit {
        if let listener = authStateListener {
            Auth.auth().removeStateDidChangeListener(listener)
        }
    }

    func signInWithGoogle() async throws -> AppUser {
        // potřebujeme obsah obrazovky (rootViewControler) pro zobrazení dialogu. Je možnost více oken, proto connectedScenes.first (v našem případě jen jedna)
        // mainActor.run je tu kvůli hlavnímu vláknu, je potřeba jen pro UIApplication
        let rootViewController = await MainActor.run { () -> UIViewController? in
            let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
            return windowScene?.windows.first?.rootViewController
        }

        guard let rootViewController else {
            throw AuthError.missingRootViewController
        }

        // Google Sign-In flow
        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
        let user = result.user

        guard let idToken = user.idToken?.tokenString else {
            throw AuthError.missingToken
        }

        // prihlaseni do Firebase Auth — Firestore fetch a vytvoreni uzivatele se deje az v ProfileViewModel.loadUser()
        let credential = GoogleAuthProvider.credential(
            withIDToken: idToken,
            accessToken: user.accessToken.tokenString
        )
        let authResult = try await Auth.auth().signIn(with: credential)

        // zakladni AppUser sestaveny z Auth a Google profilu, bez Firestore
        let appUser = AppUser(
            id: authResult.user.uid,
            email: authResult.user.email ?? "",
            displayName: user.profile?.name ?? "Uživatel",
            avatarURL: user.profile?.imageURL(withDimension: 200)?.absoluteString,
            location: nil,
            role: .user,
            isBanned: false,
            banReason: nil,
            itemsScanned: 0,
            votesGiven: 0,
            contributionIds: []
        )
        currentUser = appUser
        return appUser
    }

    func signOut() throws {
        try Auth.auth().signOut()
        GIDSignIn.sharedInstance.signOut()
        currentUser = nil
    }

    func updateCurrentUser(_ user: AppUser) {
        currentUser = user
    }
}
