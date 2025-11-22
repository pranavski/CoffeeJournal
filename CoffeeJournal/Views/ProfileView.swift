import SwiftUI
import SwiftData

struct ProfileView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var entries: [DrinkEntry]
    @AppStorage("userName") private var userName = "Coffee Lover"
    @AppStorage("userHandle") private var userHandle = "@brewmaster"
    @AppStorage("darkMode") private var darkMode = false
    @AppStorage("dailyReminder") private var dailyReminder = true

    var body: some View {
        NavigationStack {
            ZStack {
                Color.creamBackground
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Profile Header
                        ProfileHeader(userName: userName, userHandle: userHandle)

                        // Statistics Section
                        StatisticsSection(entries: entries)

                        // Preferences Section
                        PreferencesSection(
                            darkMode: $darkMode,
                            dailyReminder: $dailyReminder
                        )

                        // About Section
                        AboutSection()
                    }
                    .padding(.bottom, 100)
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - Profile Header
struct ProfileHeader: View {
    let userName: String
    let userHandle: String

    var body: some View {
        VStack(spacing: 16) {
            // Avatar
            ZStack {
                Circle()
                    .fill(AppGradients.warmGradient)
                    .frame(width: 100, height: 100)

                Text("☕")
                    .font(.system(size: 40))
            }
            .shadow(color: Color.coffeeBrown.opacity(0.3), radius: 10, y: 5)

            VStack(spacing: 4) {
                Text(userName)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.primaryText)

                Text(userHandle)
                    .font(.subheadline)
                    .foregroundStyle(Color.secondaryText)
            }
        }
        .padding(.top, 24)
    }
}

// MARK: - Statistics Section
struct StatisticsSection: View {
    let entries: [DrinkEntry]

    var totalDrinks: Int { entries.count }

    var currentStreak: Int {
        guard !entries.isEmpty else { return 0 }
        let calendar = Calendar.current
        let sortedDates = entries.map { calendar.startOfDay(for: $0.createdAt) }
            .sorted(by: >)
            .uniqued()

        var streak = 0
        var currentDate = calendar.startOfDay(for: Date())

        for date in sortedDates {
            if date == currentDate {
                streak += 1
                currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate)!
            } else if date < currentDate {
                break
            }
        }

        return streak
    }

    var favoriteDrink: String {
        guard !entries.isEmpty else { return "None yet" }
        let grouped = Dictionary(grouping: entries) { $0.specificDrink.isEmpty ? $0.drinkType.rawValue : $0.specificDrink }
        return grouped.max(by: { $0.value.count < $1.value.count })?.key ?? "None"
    }

    var averageRating: Double {
        guard !entries.isEmpty else { return 0 }
        return Double(entries.reduce(0) { $0 + $1.rating }) / Double(entries.count)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Statistics", icon: "chart.bar.fill")

            VStack(spacing: 0) {
                StatRow(label: "Total Drinks", value: "\(totalDrinks)")
                Divider().padding(.horizontal, 16)
                StatRow(label: "Current Streak", value: "\(currentStreak) days")
                Divider().padding(.horizontal, 16)
                StatRow(label: "Favorite Drink", value: favoriteDrink)
                Divider().padding(.horizontal, 16)
                StatRow(label: "Average Rating", value: String(format: "%.1f ★", averageRating))
            }
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
        }
        .padding(.horizontal, 16)
    }
}

struct StatRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .foregroundStyle(Color.primaryText)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
                .foregroundStyle(Color.coffeeBrown)
        }
        .padding(16)
    }
}

// MARK: - Preferences Section
struct PreferencesSection: View {
    @Binding var darkMode: Bool
    @Binding var dailyReminder: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Preferences", icon: "gearshape.fill")

            VStack(spacing: 0) {
                ToggleRow(label: "Dark Mode", icon: "moon.fill", isOn: $darkMode)
                Divider().padding(.horizontal, 16)
                ToggleRow(label: "Daily Reminder", icon: "bell.fill", isOn: $dailyReminder)
            }
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
        }
        .padding(.horizontal, 16)
    }
}

struct ToggleRow: View {
    let label: String
    let icon: String
    @Binding var isOn: Bool

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(Color.coffeeBrown)
                .frame(width: 24)

            Text(label)
                .foregroundStyle(Color.primaryText)

            Spacer()

            Toggle("", isOn: $isOn)
                .tint(Color.coffeeBrown)
        }
        .padding(16)
    }
}

// MARK: - About Section
struct AboutSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "About", icon: "info.circle.fill")

            VStack(spacing: 0) {
                AboutRow(label: "Version", value: "1.0.0")
                Divider().padding(.horizontal, 16)
                AboutRow(label: "Made with", value: "☕ & ❤️")
            }
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
        }
        .padding(.horizontal, 16)
    }
}

struct AboutRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .foregroundStyle(Color.primaryText)
            Spacer()
            Text(value)
                .foregroundStyle(Color.secondaryText)
        }
        .padding(16)
    }
}

// MARK: - Section Header
struct SectionHeader: View {
    let title: String
    let icon: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(Color.coffeeBrown)
            Text(title)
                .font(.headline)
                .foregroundStyle(Color.primaryText)
        }
    }
}

// MARK: - Array Extension for unique elements
extension Array where Element: Hashable {
    func uniqued() -> [Element] {
        var seen = Set<Element>()
        return filter { seen.insert($0).inserted }
    }
}

#Preview {
    ProfileView()
        .modelContainer(for: DrinkEntry.self, inMemory: true)
}
