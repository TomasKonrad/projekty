import Foundation

// sdileny koordinator navigace — umoznuje presunout se na mapu ze skeneru nebo profilu
@Observable
final class AppCoordinator {
    // lokace ke zobrazeni — nastavuje skener/profil, spotrebovava ContentView
    var pendingMapLocation: RecyclingLocation? = nil
}
