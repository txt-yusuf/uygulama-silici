import SwiftUI

@main
struct UygulamaSiliciApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 980, minHeight: 640)
        }
        .windowStyle(.titleBar)
        .commands {
            SidebarCommands()
        }
    }
}
