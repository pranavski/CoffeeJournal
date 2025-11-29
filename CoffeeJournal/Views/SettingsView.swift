import SwiftUI
import SwiftData
import UserNotifications

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var entries: [DrinkEntry]

    @AppStorage("userName") private var userName = "Coffee Lover"
    @AppStorage("userHandle") private var userHandle = "@brewmaster"
    @AppStorage("darkMode") private var darkMode = false
    @AppStorage("dailyReminder") private var dailyReminder = true
    @AppStorage("reminderTime") private var reminderTime = Date()
    @AppStorage("defaultDrinkType") private var defaultDrinkType = "Coffee"

    @State private var showExportSheet = false
    @State private var showClearDataAlert = false
    @State private var exportData: String = ""
    @State private var showPrivacyPolicy = false
    @State private var showTermsOfService = false

    var body: some View {
        ZStack {
            AppGradients.meshBackground
                .ignoresSafeArea()

            List {
                // Profile Section
                Section {
                    HStack {
                        Text("Name")
                        Spacer()
                        TextField("Your name", text: $userName)
                            .multilineTextAlignment(.trailing)
                            .foregroundStyle(Color.secondaryText)
                    }

                    HStack {
                        Text("Handle")
                        Spacer()
                        TextField("@username", text: $userHandle)
                            .multilineTextAlignment(.trailing)
                            .foregroundStyle(Color.secondaryText)
                    }
                } header: {
                    Label("Profile", systemImage: "person.fill")
                        .foregroundStyle(Color.coffeeBrown)
                }
                .listRowBackground(Color.white.opacity(0.5))

                // Preferences Section
                Section {
                    Toggle(isOn: $darkMode) {
                        Label("Dark Mode", systemImage: "moon.fill")
                    }
                    .tint(Color.coffeeBrown)

                    Toggle(isOn: $dailyReminder) {
                        Label("Daily Reminder", systemImage: "bell.fill")
                    }
                    .tint(Color.coffeeBrown)

                    if dailyReminder {
                        DatePicker(
                            "Reminder Time",
                            selection: $reminderTime,
                            displayedComponents: .hourAndMinute
                        )
                        .tint(Color.coffeeBrown)
                    }

                    Picker(selection: $defaultDrinkType) {
                        ForEach(DrinkType.allCases, id: \.rawValue) { type in
                            Text(type.emoji + " " + type.rawValue).tag(type.rawValue)
                        }
                    } label: {
                        Label("Default Drink", systemImage: "cup.and.saucer")
                    }
                    .tint(Color.coffeeBrown)
                } header: {
                    Label("Preferences", systemImage: "gearshape.fill")
                        .foregroundStyle(Color.coffeeBrown)
                }
                .listRowBackground(Color.white.opacity(0.5))

                // Data Section
                Section {
                    Button(action: exportEntries) {
                        Label("Export Data (CSV)", systemImage: "arrow.up.doc")
                            .foregroundStyle(Color.coffeeBrown)
                    }

                    Button(role: .destructive, action: { showClearDataAlert = true }) {
                        Label("Clear All Data", systemImage: "trash")
                    }
                } header: {
                    Label("Data Management", systemImage: "externaldrive.fill")
                        .foregroundStyle(Color.coffeeBrown)
                } footer: {
                    Text("You have \(entries.count) drink entries saved.")
                }
                .listRowBackground(Color.white.opacity(0.5))

                // About Section
                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("2.0.0")
                            .foregroundStyle(Color.secondaryText)
                    }

                    HStack {
                        Text("Build")
                        Spacer()
                        Text("iOS 26")
                            .foregroundStyle(Color.secondaryText)
                    }

                    Button(action: { showPrivacyPolicy = true }) {
                        Label("Privacy Policy", systemImage: "hand.raised.fill")
                            .foregroundStyle(Color.coffeeBrown)
                    }

                    Button(action: { showTermsOfService = true }) {
                        Label("Terms of Service", systemImage: "doc.text.fill")
                            .foregroundStyle(Color.coffeeBrown)
                    }
                } header: {
                    Label("About", systemImage: "info.circle.fill")
                        .foregroundStyle(Color.coffeeBrown)
                }
                .listRowBackground(Color.white.opacity(0.5))
            }
            .scrollContentBackground(.hidden)
            .listStyle(.insetGrouped)
        }
        .navigationTitle("Settings")
        .toolbarBackgroundVisibility(.hidden, for: .navigationBar)
        .alert("Clear All Data?", isPresented: $showClearDataAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Clear All", role: .destructive) {
                clearAllData()
            }
        } message: {
            Text("This will permanently delete all \(entries.count) drink entries. This action cannot be undone.")
        }
        .sheet(isPresented: $showExportSheet) {
            ShareSheet(items: [exportData])
        }
        .sheet(isPresented: $showPrivacyPolicy) {
            PrivacyPolicyView()
        }
        .sheet(isPresented: $showTermsOfService) {
            TermsOfServiceView()
        }
        .onChange(of: dailyReminder) { _, isEnabled in
            if isEnabled {
                requestNotificationPermission()
                scheduleReminder()
            } else {
                cancelReminder()
            }
        }
        .onChange(of: reminderTime) { _, _ in
            if dailyReminder {
                scheduleReminder()
            }
        }
        .onAppear {
            if dailyReminder {
                scheduleReminder()
            }
        }
    }

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            if !granted {
                DispatchQueue.main.async {
                    dailyReminder = false
                }
            }
        }
    }

    private func scheduleReminder() {
        let center = UNUserNotificationCenter.current()

        // Remove existing notifications
        center.removePendingNotificationRequests(withIdentifiers: ["coffeeJournalReminder"])

        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = "Time for your coffee!"
        content.body = "Don't forget to log your drink in Brew Notes"
        content.sound = .default

        // Extract hour and minute from reminderTime
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: reminderTime)

        // Create trigger for daily notification
        var dateComponents = DateComponents()
        dateComponents.hour = components.hour
        dateComponents.minute = components.minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        // Create and add request
        let request = UNNotificationRequest(identifier: "coffeeJournalReminder", content: content, trigger: trigger)
        center.add(request)
    }

    private func cancelReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["coffeeJournalReminder"])
    }

    private func exportEntries() {
        var csv = "Date,Drink Type,Specific Drink,Location,Temperature,Milk,Price,Rating,Notes\n"

        for entry in entries {
            let date = entry.createdAt.formatted(date: .abbreviated, time: .shortened)
            let price = entry.price.map { String(format: "%.2f", $0) } ?? ""
            let notes = entry.notes.replacingOccurrences(of: "\"", with: "\"\"")

            csv += "\"\(date)\",\"\(entry.drinkType.rawValue)\",\"\(entry.specificDrink)\",\"\(entry.location)\",\"\(entry.temperature.rawValue)\",\"\(entry.milkType.rawValue)\",\"\(price)\",\"\(entry.rating)\",\"\(notes)\"\n"
        }

        exportData = csv
        showExportSheet = true
    }

    private func clearAllData() {
        for entry in entries {
            modelContext.delete(entry)
        }
    }
}

// MARK: - Share Sheet
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Privacy Policy View
struct PrivacyPolicyView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                AppGradients.meshBackground
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Last Updated: 2025")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        PolicySection(title: "Data Collection") {
                            Text("Brew Notes stores all your data locally on your device. We do not collect, transmit, or store any of your personal information on external servers.")
                        }

                        PolicySection(title: "Photos") {
                            Text("Photos you take within the app are stored locally on your device and are never uploaded to any server.")
                        }

                        PolicySection(title: "Analytics") {
                            Text("This app does not use any third-party analytics or tracking services.")
                        }

                        PolicySection(title: "Data Sharing") {
                            Text("Your data is yours. We do not share any information with third parties. When you export your data, it is shared only through your chosen method.")
                        }

                        PolicySection(title: "Contact") {
                            Text("If you have any questions about this privacy policy, please contact us through the App Store.")
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Privacy Policy")
            .toolbarBackgroundVisibility(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(Color.coffeeBrown)
                }
            }
        }
    }
}

// MARK: - Terms of Service View
struct TermsOfServiceView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                AppGradients.meshBackground
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Last Updated: 2025")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        PolicySection(title: "Acceptance of Terms") {
                            Text("By using Brew Notes, you agree to these terms of service. If you do not agree, please do not use the app.")
                        }

                        PolicySection(title: "Use of the App") {
                            Text("Brew Notes is provided for personal use to track and journal your coffee and drink experiences. You may not use the app for any illegal or unauthorized purpose.")
                        }

                        PolicySection(title: "User Content") {
                            Text("You retain all rights to the content you create within the app, including photos and notes. We do not claim any ownership over your content.")
                        }

                        PolicySection(title: "Disclaimer") {
                            Text("The app is provided \"as is\" without warranties of any kind. We are not responsible for any data loss that may occur.")
                        }

                        PolicySection(title: "Changes to Terms") {
                            Text("We may update these terms from time to time. Continued use of the app constitutes acceptance of any changes.")
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Terms of Service")
            .toolbarBackgroundVisibility(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(Color.coffeeBrown)
                }
            }
        }
    }
}

// MARK: - Policy Section
struct PolicySection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundStyle(Color.primaryText)
            content
                .foregroundStyle(Color.secondaryText)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassEffect(.regular.tint(Color.white.opacity(0.4)), in: .rect(cornerRadius: 16))
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
    .modelContainer(for: DrinkEntry.self, inMemory: true)
}
