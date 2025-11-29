import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \DrinkEntry.createdAt, order: .reverse) private var entries: [DrinkEntry]
    @Binding var showCamera: Bool

    var body: some View {
        NavigationStack {
            ZStack {
                // iOS 26 Mesh Gradient Background
                AppGradients.meshBackground
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
                            .padding(.bottom, 24)
                    }
                }
            }
            .navigationTitle("Brew Notes")
            .toolbarBackgroundVisibility(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gearshape.fill")
                            .foregroundStyle(Color.coffeeBrown)
                    }
                    .glassEffect(.regular.tint(Color.coffeeBrown.opacity(0.1)), in: .circle)
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
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(Color.primaryText)

            Text("What will you drink today?")
                .font(.subheadline)
                .foregroundStyle(Color.secondaryText)
        }
        .padding(.top, 16)
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
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(Color.coffeeBrown)

            Text(value)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(Color.primaryText)

            Text(label)
                .font(.caption)
                .foregroundStyle(Color.secondaryText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .glassEffect(.regular.tint(Color.white.opacity(0.3)), in: .rect(cornerRadius: 20))
    }
}

// MARK: - Recent Entries Section
struct RecentEntriesSection: View {
    let entries: [DrinkEntry]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Entries")
                .font(.title3.bold())
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
                if let photoData = entry.photoData,
                   let uiImage = UIImage(data: photoData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 70, height: 70)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                } else {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(AppGradients.warmGradient)
                        .frame(width: 70, height: 70)
                        .overlay {
                            Text(entry.drinkType.emoji)
                                .font(.system(size: 28))
                        }
                }
            }

            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.specificDrink.isEmpty ? entry.drinkType.rawValue : entry.specificDrink)
                    .font(.subheadline.weight(.semibold))
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
                .font(.caption.weight(.semibold))
        }
        .padding(12)
        .glassEffect(.regular.tint(Color.white.opacity(0.4)), in: .rect(cornerRadius: 20))
        .padding(.horizontal, 16)
    }
}

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "cup.and.saucer")
                .font(.system(size: 56))
                .foregroundStyle(Color.coffeeBrown.opacity(0.5))
                .symbolEffect(.pulse)

            Text("No entries yet")
                .font(.headline)
                .foregroundStyle(Color.primaryText)

            Text("Tap the camera button to log your first drink!")
                .font(.subheadline)
                .foregroundStyle(Color.secondaryText)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(40)
        .glassEffect(.regular.tint(Color.white.opacity(0.3)), in: .rect(cornerRadius: 24))
        .padding(.horizontal, 16)
    }
}

// MARK: - FAB Button
struct FABButton: View {
    @Binding var showCamera: Bool

    var body: some View {
        Button(action: { showCamera = true }) {
            Image(systemName: "camera.fill")
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 64, height: 64)
                .background(AppGradients.coffeePrimary, in: Circle())
                .shadow(color: Color.coffeeBrown.opacity(0.4), radius: 12, y: 6)
        }
        .sensoryFeedback(.impact(flexibility: .soft), trigger: showCamera)
    }
}

#Preview {
    HomeView(showCamera: .constant(false))
        .modelContainer(for: DrinkEntry.self, inMemory: true)
}
