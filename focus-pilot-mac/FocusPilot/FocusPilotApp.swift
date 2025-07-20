import SwiftUI

@main
struct FocusPilotApp: App {
    @StateObject private var taskManager = TaskManager()
    @StateObject private var focusTimer = FocusTimer()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(taskManager)
                .environmentObject(focusTimer)
                .frame(minWidth: 800, minHeight: 600)
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
    }
}
