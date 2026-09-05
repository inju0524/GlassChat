import SwiftUI
import SwiftData

@main
struct GlassChatApp: App {
    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environment(NetworkMonitor())
                .environment(SettingsStore())
                .preferredColorScheme(SettingsStore().preferredColorScheme)
        }
        .modelContainer(for: [Conversation.self, Message.self])
    }
}
