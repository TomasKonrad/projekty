import Foundation

final class DIContainer {
    typealias Resolver = () -> Any

    private var resolvers = [String: Resolver]()
    private var cache = [String: Any]()

    static let shared = DIContainer()

    init() {
        registerDependencies()
    }

    func register<T, R>(_ type: T.Type, cached: Bool = false, service: @escaping () -> R) {
        let key = String(reflecting: type)
        resolvers[key] = service

        if cached {
            cache[key] = service()
        }
    }

    func resolve<T>() -> T {
        let key = String(reflecting: T.self)

        if let cachedService = cache[key] as? T {
            print("🥣 Resolving cached instance of \(T.self).")

            return cachedService
        }

        if let resolver = resolvers[key], let service = resolver() as? T {
            print("🥣 Resolving new instance of \(T.self).")

            return service
        }

        fatalError("🥣 \(key) has not been registered.")
    }
}

extension DIContainer {
    func registerDependencies() {
        register(AppCoordinator.self, cached: true) { AppCoordinator() }
        register(DataManaging.self, cached: true) { CoreDataManager() }
        register(RecyclingLocationManaging.self, cached: true) { FirebaseRecyclingLocationManager() }
        register(LocationManaging.self, cached: true) { CoreLocationManager() }
        register(UserManaging.self, cached: true) { FirebaseUserManager() }
        register(AuthManaging.self, cached: true) { FirebaseAuthManager() }
        register(ReportManaging.self, cached: true) { FirebaseReportManager() }
        register(GeocodingManaging.self, cached: true) { GeocodingManager() }
        register(OpeningHoursManaging.self, cached: true) { OpeningHoursParser() }
        register(ScannerManaging.self, cached: true) { FirebaseScannerManager() }
        register(PendingBinNotificationManaging.self, cached: true) { PendingBinNotificationManager() }
    }
}
