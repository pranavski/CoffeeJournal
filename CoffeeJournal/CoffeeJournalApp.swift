import SwiftUI
import SwiftData

@main
struct CoffeeJournalApp: App {
    @AppStorage("darkMode") private var darkMode = false

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(darkMode ? .dark : .light)
        }
        .modelContainer(for: DrinkEntry.self)
    }
}
