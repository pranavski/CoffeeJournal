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
                AppGradients.meshBackground
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
                    .padding(.bottom, 32)
                }
            }
            .navigationTitle("Profile")
            .toolbarBackgroundVisibility(.hidden, for: .navigationBar)
        }
    }
}

// MARK: - Profile Header
struct ProfileHeader: View {
    let userName: String
    let userHandle: String

    var body: some View {
        VStack(spacing: 16) {
            // Avatar with glass effect
            ZStack {
                Circle()
                    .fill(AppGradients.warmGradient)
                    .frame(width: 100, height: 100)

                Text("☕")
                    .font(.system(size: 44))
            }
            .glassEffect(.regular.tint(Color.coffeeBrown.opacity(0.2)), in: .circle)
            .shadow(color: Color.coffeeBrown.opacity(0.2), radius: 16, y: 8)

            VStack(spacing: 4) {
                Text(userName)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(Color.primaryText)

                Text(userHandle)
                    .font(.subheadline)
                    .foregroundStyle(Color.secondaryText)
            }
        }
        .padding(.top, 16)
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
                StatRow(label: "Total Drinks", value: "\(totalDrinks)", icon: "cup.and.saucer.fill")
                StatRow(label: "Current Streak", value: "\(currentStreak) days", icon: "flame.fill")
                StatRow(label: "Favorite Drink", value: favoriteDrink, icon: "heart.fill")
                StatRow(label: "Average Rating", value: String(format: "%.1f ★", averageRating), icon: "star.fill")
            }
            .glassEffect(.regular.tint(Color.white.opacity(0.4)), in: .rect(cornerRadius: 20))
        }
        .padding(.horizontal, 16)
    }
}

struct StatRow: View {
    let label: String
    let value: String
    let icon: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(Color.coffeeBrown)
                .frame(width: 24)

            Text(label)
                .foregroundStyle(Color.primaryText)

            Spacer()

            Text(value)
                .fontWeight(.semibold)
                .foregroundStyle(Color.coffeeBrown)
                .lineLimit(1)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
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
                ToggleRow(label: "Daily Reminder", icon: "bell.fill", isOn: $dailyReminder)
            }
            .glassEffect(.regular.tint(Color.white.opacity(0.4)), in: .rect(cornerRadius: 20))
        }
        .padding(.horizontal, 16)
    }
}

struct ToggleRow: View {
    let label: String
    let icon: String
    @Binding var isOn: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(Color.coffeeBrown)
                .frame(width: 24)

            Text(label)
                .foregroundStyle(Color.primaryText)

            Spacer()

            Toggle("", isOn: $isOn)
                .tint(Color.coffeeBrown)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }
}

// MARK: - About Section
struct AboutSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "About", icon: "info.circle.fill")

            VStack(spacing: 0) {
                AboutRow(label: "Version", value: "2.0.0", icon: "number")
                AboutRow(label: "Built for", value: "iOS 26", icon: "apple.logo")
                AboutRow(label: "Made with", value: "☕ & ❤️", icon: "heart.fill")
            }
            .glassEffect(.regular.tint(Color.white.opacity(0.4)), in: .rect(cornerRadius: 20))
        }
        .padding(.horizontal, 16)
    }
}

struct AboutRow: View {
    let label: String
    let value: String
    let icon: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(Color.coffeeBrown)
                .frame(width: 24)

            Text(label)
                .foregroundStyle(Color.primaryText)

            Spacer()

            Text(value)
                .foregroundStyle(Color.secondaryText)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
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
