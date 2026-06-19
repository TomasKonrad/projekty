import SwiftUI
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import GoogleSignIn

import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        FirebaseApp.configure()
        // nastaveni Google Sign-In — nacita CLIENT_ID z GoogleService-Info.plist pres Firebase options
        if let clientID = FirebaseApp.app()?.options.clientID {
            GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
        }
        // omezime disk cache na 10 MB — CoreData je nase primarna lokalni perzistence
        let fsSettings = FirestoreSettings()
        fsSettings.cacheSizeBytes = 10 * 1_048_576
        Firestore.firestore().settings = fsSettings
        // registrace sluzeb az po konfiguraci Firebase — cached instance potrebuji spravny Firestore host
        DIContainer.shared.registerDependencies()
        // nastaveni delegata notifikaci — zpracovani tapnuti a potlaceni notifikaci na popredi
        UNUserNotificationCenter.current().delegate = self
        return true
    }

    // zpracovani navratove URL po Google Sign-In OAuth flow
    func application(_ app: UIApplication, open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        GIDSignIn.sharedInstance.handle(url)
    }

    // tapnuti na notifikaci — mapa je vzdy viditelna jako root, zadna akce neni potreba
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        completionHandler()
    }

    // notifikaci nezobrazujeme kdyz je app na popredi — mame vlastni in-app banner
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([])
    }
}

@main
struct KosherApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
