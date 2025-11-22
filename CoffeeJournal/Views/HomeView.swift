import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \DrinkEntry.createdAt, order: .reverse) private var entries: [DrinkEntry]
    @Binding var showCamera: Bool

    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color.creamBackground
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Welcome Section
                        WelcomeSection()

                        // Stats Cards
                        StatsSection(entries: entries)

                        // Recent Entries
                        RecentEntriesSection(entries: Array(entries.prefix(5)))
                    }
                    .padding(.bottom, 100)
                }

                // Floating Action Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        FABButton(showCamera: $showCamera)
                            .padding(.trailing, 24)
                            .padding(.bottom, 100)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Brew Notes")
                        .font(.headline)
                        .foregroundStyle(Color.primaryText)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gearshape.fill")
                            .foregroundStyle(Color.coffeeBrown)
                    }
                }
            }
        }
    }
}

// MARK: - Welcome Section
struct WelcomeSection: View {
    var body: some View {
        VStack(spacing: 8) {
            Text("Hello, Friend!")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(Color.primaryText)

            Text("What will you drink today?")
                .font(.subheadline)
                .foregroundStyle(Color.secondaryText)
        }
        .padding(.top, 24)
    }
}

// MARK: - Stats Section
struct StatsSection: View {
    let entries: [DrinkEntry]

    var totalDrinks: Int { entries.count }
    var averageRating: Double {
        guard !entries.isEmpty else { return 0 }
        let total = entries.reduce(0) { $0 + $1.rating }
        return Double(total) / Double(entries.count)
    }
    var thisMonthCount: Int {
        let calendar = Calendar.current
        let now = Date()
        return entries.filter { calendar.isDate($0.createdAt, equalTo: now, toGranularity: .month) }.count
    }
    var favoriteDrink: String {
        guard !entries.isEmpty else { return "None" }
        let grouped = Dictionary(grouping: entries) { $0.specificDrink }
        return grouped.max(by: { $0.value.count < $1.value.count })?.key ?? "None"
    }

    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            StatCard(value: "\(totalDrinks)", label: "Total Drinks", icon: "cup.and.saucer.fill")
            StatCard(value: String(format: "%.1f", averageRating), label: "Avg Rating", icon: "star.fill")
            StatCard(value: "\(thisMonthCount)", label: "This Month", icon: "calendar")
            StatCard(value: favoriteDrink.prefix(10).description, label: "Favorite", icon: "heart.fill")
        }
        .padding(.horizontal, 16)
    }
}

struct StatCard: View {
    let value: String
    let label: String
    let icon: String

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(Color.coffeeBrown)
                Spacer()
            }
            HStack {
                Text(value)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(Color.coffeeBrown)
                Spacer()
            }
            HStack {
                Text(label)
                    .font(.caption)
                    .foregroundStyle(Color.secondaryText)
                Spacer()
            }
        }
        .padding(16)
        .liquidGlass(cornerRadius: 16)
    }
}

// MARK: - Recent Entries Section
struct RecentEntriesSection: View {
    let entries: [DrinkEntry]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Entries")
                .font(.headline)
                .foregroundStyle(Color.primaryText)
                .padding(.horizontal, 16)

            if entries.isEmpty {
                EmptyStateView()
            } else {
                ForEach(entries) { entry in
                    NavigationLink(destination: EntryDetailView(entry: entry)) {
                        EntryCard(entry: entry)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

struct EntryCard: View {
    let entry: DrinkEntry

    var body: some View {
        HStack(spacing: 12) {
            // Thumbnail
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(AppGradients.warmGradient)
                    .frame(width: 70, height: 70)

                if let photoData = entry.photoData,
                   let uiImage = UIImage(data: photoData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 70, height: 70)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    Text(entry.drinkType.emoji)
                        .font(.system(size: 28))
                }
            }

            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.specificDrink.isEmpty ? entry.drinkType.rawValue : entry.specificDrink)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.primaryText)

                Text(entry.createdAt.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundStyle(Color.secondaryText)

                HStack(spacing: 2) {
                    ForEach(1...5, id: \.self) { index in
                        Image(systemName: index <= entry.rating ? "star.fill" : "star")
                            .foregroundStyle(Color.ratingGold)
                            .font(.caption)
                    }
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundStyle(Color.secondaryText)
        }
        .padding(12)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
        .padding(.horizontal, 16)
    }
}

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "cup.and.saucer")
                .font(.system(size: 48))
                .foregroundStyle(Color.coffeeBrown.opacity(0.5))

            Text("No entries yet")
                .font(.headline)
                .foregroundStyle(Color.secondaryText)

            Text("Tap the camera button to log your first drink!")
                .font(.caption)
                .foregroundStyle(Color.secondaryText)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(32)
        .liquidGlass(cornerRadius: 16)
        .padding(.horizontal, 16)
    }
}

// MARK: - FAB Button
struct FABButton: View {
    @Binding var showCamera: Bool

    var body: some View {
        Button(action: { showCamera = true }) {
            ZStack {
                Circle()
                    .fill(AppGradients.coffeePrimary)
                    .frame(width: 64, height: 64)
                    .shadow(color: Color.coffeeBrown.opacity(0.4), radius: 10, y: 5)

                Image(systemName: "camera.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(.white)
            }
        }
    }
}

#Preview {
    HomeView(showCamera: .constant(false))
        .modelContainer(for: DrinkEntry.self, inMemory: true)
}
