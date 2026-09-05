import SwiftUI
import SwiftData

@main
struct GlassChatApp: App {
    @State private var settings = SettingsStore()
    @State private var providerStore = ProviderStore()
    @State private var network = NetworkMonitor()

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environment(settings)
                .environment(providerStore)
                .environment(network)
                .preferredColorScheme(settings.preferredColorScheme)
        }
        .modelContainer(for: [Conversation.self, Message.self])
    }
}
