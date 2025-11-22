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
                Color.creamBackground
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
                .padding(.bottom, 80)
            }
            .navigationTitle("Gallery")
            .navigationBarTitleDisplayMode(.large)
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
            HStack(spacing: 12) {
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
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(isSelected ? .white : Color.coffeeBrown)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    isSelected ? AnyShapeStyle(AppGradients.coffeePrimary) : AnyShapeStyle(Color.white)
                )
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(Color.coffeeBrown.opacity(0.2), lineWidth: isSelected ? 0 : 1)
                )
        }
    }
}

// MARK: - Gallery Grid View
struct GalleryGridView: View {
    let entries: [DrinkEntry]
    let columns = [GridItem(.flexible()), GridItem(.flexible())]

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
            }
        }
        .frame(height: 160)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(alignment: .bottomLeading) {
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.specificDrink.isEmpty ? entry.drinkType.rawValue : entry.specificDrink)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)

                HStack(spacing: 2) {
                    ForEach(1...5, id: \.self) { index in
                        Image(systemName: index <= entry.rating ? "star.fill" : "star")
                            .font(.system(size: 8))
                            .foregroundStyle(Color.ratingGold)
                    }
                }
            }
            .padding(10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                LinearGradient(
                    colors: [.black.opacity(0.7), .clear],
                    startPoint: .bottom,
                    endPoint: .top
                )
            )
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 5, y: 2)
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
        .padding(16)
    }
}

// MARK: - Empty State
struct GalleryEmptyState: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 64))
                .foregroundStyle(Color.coffeeBrown.opacity(0.3))

            Text("No entries found")
                .font(.headline)
                .foregroundStyle(Color.secondaryText)

            Text("Try adjusting your filters or add a new drink!")
                .font(.subheadline)
                .foregroundStyle(Color.secondaryText)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(32)
    }
}

#Preview {
    GalleryView()
        .modelContainer(for: DrinkEntry.self, inMemory: true)
}
