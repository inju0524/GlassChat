import Foundation
import Network
import Observation

/// 无网络监测（驱动"无网络连接"横幅）。NWPathMonitor 在后台线程回调，切回主线程更新。
@Observable
final class NetworkMonitor {
    private let monitor = NWPathMonitor()
    @ObservationIgnored private let queue = DispatchQueue(label: "com.glasschat.network")

    private(set) var isOnline: Bool = true

    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            Task { @MainActor in
                self?.isOnline = path.status == .satisfied
            }
        }
        monitor.start(queue: queue)
    }

    deinit { monitor.cancel() }
}
