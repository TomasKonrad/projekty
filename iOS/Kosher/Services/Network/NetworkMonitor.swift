import Network
import Foundation

// sleduje dostupnost site — aktualizuje isConnected na hlavnim vlakne
@Observable
final class NetworkMonitor {
    private(set) var isConnected: Bool = true
    private let monitor = NWPathMonitor()
    private let queue   = DispatchQueue(label: "network.monitor")

    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
            }
        }
        monitor.start(queue: queue)
    }

    deinit {
        monitor.cancel()
    }
}
