import SwiftUI
import SwiftData

struct GalleryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \DrinkEntry.createdAt, order: .reverse) private var entries: [DrinkEntry]
    @State private var searchText = ""
    @State private var selectedFilter: DrinkType? = nil
    @State private var viewMode: ViewMode = .grid

    enum ViewMode {
        case grid, list
    }

    var filteredEntries: [DrinkEntry] {
        var result = entries

        if let filter = selectedFilter {
            result = result.filter { $0.drinkType == filter }
        }

        if !searchText.isEmpty {
            result = result.filter {
                $0.specificDrink.localizedCaseInsensitiveContains(searchText) ||
                $0.location.localizedCaseInsensitiveContains(searchText) ||
                $0.notes.localizedCaseInsensitiveContains(searchText)
            }
        }

        return result
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppGradients.meshBackground
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Filter Pills
                    FilterSection(selectedFilter: $selectedFilter)

                    // Gallery Content
                    if filteredEntries.isEmpty {
                        GalleryEmptyState()
                    } else {
                        ScrollView {
                            switch viewMode {
                            case .grid:
                                GalleryGridView(entries: filteredEntries)
                            case .list:
                                GalleryListView(entries: filteredEntries)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Gallery")
            .toolbarBackgroundVisibility(.hidden, for: .navigationBar)
            .searchable(text: $searchText, prompt: "Search drinks...")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button(action: { viewMode = .grid }) {
                            Label("Grid", systemImage: "square.grid.2x2")
                        }
                        Button(action: { viewMode = .list }) {
                            Label("List", systemImage: "list.bullet")
                        }
                    } label: {
                        Image(systemName: viewMode == .grid ? "square.grid.2x2" : "list.bullet")
                            .foregroundStyle(Color.coffeeBrown)
                    }
                    .glassEffect(.regular.tint(Color.coffeeBrown.opacity(0.1)), in: .circle)
                }
            }
        }
    }
}

// MARK: - Filter Section
struct FilterSection: View {
    @Binding var selectedFilter: DrinkType?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                FilterPill(title: "All", isSelected: selectedFilter == nil) {
                    selectedFilter = nil
                }

                ForEach(DrinkType.allCases, id: \.self) { type in
                    FilterPill(
                        title: type.emoji + " " + type.rawValue,
                        isSelected: selectedFilter == type
                    ) {
                        selectedFilter = type
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
    }
}

struct FilterPill: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(isSelected ? .white : Color.coffeeBrown)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background {
                    if isSelected {
                        Capsule()
                            .fill(AppGradients.coffeePrimary)
                    }
                }
                .glassEffect(isSelected ? .clear : .regular.tint(Color.white.opacity(0.4)), in: .capsule)
        }
        .sensoryFeedback(.selection, trigger: isSelected)
    }
}

// MARK: - Gallery Grid View
struct GalleryGridView: View {
    let entries: [DrinkEntry]
    let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(entries) { entry in
                NavigationLink(destination: EntryDetailView(entry: entry)) {
                    GalleryGridItem(entry: entry)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(16)
    }
}

struct GalleryGridItem: View {
    let entry: DrinkEntry

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Background/Photo
            if let photoData = entry.photoData,
               let uiImage = UIImage(data: photoData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else {
                AppGradients.warmGradient
                    .overlay {
                        Text(entry.drinkType.emoji)
                            .font(.system(size: 40))
                    }
            }
        }
        .frame(height: 180)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(alignment: .bottomLeading) {
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.specificDrink.isEmpty ? entry.drinkType.rawValue : entry.specificDrink)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white)
                    .lineLimit(1)

                HStack(spacing: 2) {
                    ForEach(1...5, id: \.self) { index in
                        Image(systemName: index <= entry.rating ? "star.fill" : "star")
                            .font(.system(size: 8))
                            .foregroundStyle(Color.ratingGold)
                    }
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.ultraThinMaterial, in: UnevenRoundedRectangle(bottomLeadingRadius: 20, bottomTrailingRadius: 20))
        }
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

// MARK: - Gallery List View
struct GalleryListView: View {
    let entries: [DrinkEntry]

    var body: some View {
        LazyVStack(spacing: 12) {
            ForEach(entries) { entry in
                NavigationLink(destination: EntryDetailView(entry: entry)) {
                    EntryCard(entry: entry)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 16)
    }
}

// MARK: - Empty State
struct GalleryEmptyState: View {
    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 72))
                .foregroundStyle(Color.coffeeBrown.opacity(0.3))
                .symbolEffect(.pulse)

            Text("No entries found")
                .font(.title3.weight(.semibold))
                .foregroundStyle(Color.primaryText)

            Text("Try adjusting your filters or add a new drink!")
                .font(.subheadline)
                .foregroundStyle(Color.secondaryText)
                .multilineTextAlignment(.center)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(32)
    }
}

#Preview {
    GalleryView()
        .modelContainer(for: DrinkEntry.self, inMemory: true)
}
