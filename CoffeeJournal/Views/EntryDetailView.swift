import SwiftUI
import SwiftData

struct EntryDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Bindable var entry: DrinkEntry
    @State private var showEditSheet = false
    @State private var showDeleteAlert = false

    var body: some View {
        ZStack {
            Color.creamBackground
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    // Hero Image
                    HeroImageSection(entry: entry)

                    // Content
                    VStack(spacing: 20) {
                        // Title and Rating
                        TitleSection(entry: entry)

                        // Quick Info Pills
                        QuickInfoSection(entry: entry)

                        // Details Grid
                        DetailsGridSection(entry: entry)

                        // Notes Section
                        if !entry.notes.isEmpty {
                            NotesSection(notes: entry.notes)
                        }

                        // Mood & Tags
                        if entry.mood != nil || !entry.tags.isEmpty {
                            MoodTagsSection(mood: entry.mood, tags: entry.tags)
                        }
                    }
                    .padding(16)
                    .padding(.bottom, 80)
                }
            }

            // Bottom Edit Button
            VStack {
                Spacer()
                EditButtonSection(onEdit: { showEditSheet = true })
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button(action: { showEditSheet = true }) {
                        Label("Edit", systemImage: "pencil")
                    }

                    ShareLink(item: shareText) {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }

                    Divider()

                    Button(role: .destructive, action: { showDeleteAlert = true }) {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundStyle(Color.coffeeBrown)
                }
            }
        }
        .sheet(isPresented: $showEditSheet) {
            EditEntryView(entry: entry)
        }
        .alert("Delete Entry?", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                deleteEntry()
            }
        } message: {
            Text("This action cannot be undone.")
        }
    }

    private var shareText: String {
        let drinkName = entry.specificDrink.isEmpty ? entry.drinkType.rawValue : entry.specificDrink
        return "\(entry.drinkType.emoji) \(drinkName) - \(String(repeating: "★", count: entry.rating))\n\(entry.notes)"
    }

    private func deleteEntry() {
        modelContext.delete(entry)
        dismiss()
    }
}

// MARK: - Hero Image Section
struct HeroImageSection: View {
    let entry: DrinkEntry

    var body: some View {
        ZStack {
            if let photoData = entry.photoData,
               let uiImage = UIImage(data: photoData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 280)
                    .clipped()
            } else {
                AppGradients.warmGradient
                    .frame(height: 280)
                    .overlay {
                        Text(entry.drinkType.emoji)
                            .font(.system(size: 80))
                    }
            }
        }
        .overlay(alignment: .bottom) {
            LinearGradient(
                colors: [.clear, Color.creamBackground],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 60)
        }
    }
}

// MARK: - Title Section
struct TitleSection: View {
    let entry: DrinkEntry

    var body: some View {
        VStack(spacing: 8) {
            Text(entry.specificDrink.isEmpty ? entry.drinkType.rawValue : entry.specificDrink)
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(Color.primaryText)

            Text(entry.createdAt.formatted(date: .long, time: .shortened))
                .font(.subheadline)
                .foregroundStyle(Color.secondaryText)

            if !entry.location.isEmpty {
                HStack(spacing: 4) {
                    Image(systemName: "mappin")
                    Text(entry.location)
                }
                .font(.caption)
                .foregroundStyle(Color.coffeeBrown)
            }

            // Rating
            HStack(spacing: 4) {
                ForEach(1...5, id: \.self) { index in
                    Image(systemName: index <= entry.rating ? "star.fill" : "star")
                        .foregroundStyle(Color.ratingGold)
                        .font(.title3)
                }
            }
            .padding(.top, 4)
        }
    }
}

// MARK: - Quick Info Section
struct QuickInfoSection: View {
    let entry: DrinkEntry

    var body: some View {
        HStack(spacing: 12) {
            InfoPill(icon: entry.drinkType.icon, text: entry.drinkType.rawValue, color: .coffeeBrown)
            InfoPill(icon: entry.temperature.icon, text: entry.temperature.rawValue, color: entry.temperature == .hot ? .orange : .blue)
            if entry.milkType != .none {
                InfoPill(icon: "drop.fill", text: entry.milkType.rawValue, color: .cyan)
            }
        }
    }
}

struct InfoPill: View {
    let icon: String
    let text: String
    let color: Color

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
            Text(text)
                .font(.caption)
                .fontWeight(.medium)
        }
        .foregroundStyle(color)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(color.opacity(0.1))
        .clipShape(Capsule())
    }
}

// MARK: - Details Grid Section
struct DetailsGridSection: View {
    let entry: DrinkEntry

    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                DetailCard(title: "Type", value: entry.drinkType.rawValue, icon: entry.drinkType.icon)
                DetailCard(title: "Temperature", value: entry.temperature.rawValue, icon: entry.temperature.icon)
            }

            if entry.milkType != .none || entry.price != nil {
                HStack(spacing: 12) {
                    if entry.milkType != .none {
                        DetailCard(title: "Milk", value: entry.milkType.rawValue, icon: "drop.fill")
                    }
                    if let price = entry.price {
                        DetailCard(title: "Price", value: String(format: "$%.2f", price), icon: "dollarsign.circle")
                    }
                }
            }
        }
    }
}

struct DetailCard: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(Color.coffeeBrown)
                Text(title)
                    .font(.caption)
                    .foregroundStyle(Color.secondaryText)
            }
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(Color.primaryText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
    }
}

// MARK: - Notes Section
struct NotesSection: View {
    let notes: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "note.text")
                    .foregroundStyle(Color.coffeeBrown)
                Text("Notes")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.primaryText)
            }

            Text(notes)
                .font(.body)
                .foregroundStyle(Color.primaryText)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
        }
    }
}

// MARK: - Mood & Tags Section
struct MoodTagsSection: View {
    let mood: DrinkMood?
    let tags: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let mood = mood {
                HStack(spacing: 8) {
                    Text("Mood:")
                        .font(.subheadline)
                        .foregroundStyle(Color.secondaryText)

                    HStack(spacing: 4) {
                        Text(mood.icon)
                        Text(mood.rawValue)
                    }
                    .font(.subheadline)
                    .foregroundStyle(Color.coffeeBrown)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.coffeeBrown.opacity(0.1))
                    .clipShape(Capsule())
                }
            }

            if !tags.isEmpty {
                HStack {
                    ForEach(tags, id: \.self) { tag in
                        Text("#\(tag)")
                            .font(.caption)
                            .foregroundStyle(Color.matchaGreen)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.matchaGreen.opacity(0.1))
                            .clipShape(Capsule())
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Edit Button Section
struct EditButtonSection: View {
    let onEdit: () -> Void

    var body: some View {
        Button(action: onEdit) {
            Text("Edit Entry")
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(AppGradients.coffeePrimary)
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .padding(16)
        .background(.ultraThinMaterial)
    }
}

#Preview {
    NavigationStack {
        EntryDetailView(entry: DrinkEntry(
            drinkType: .coffee,
            specificDrink: "Oat Milk Latte",
            location: "Blue Bottle Coffee",
            temperature: .hot,
            milkType: .oat,
            price: 5.50,
            rating: 5,
            notes: "Perfect temperature, great latte art, very smooth and creamy. Will definitely come back!",
            mood: .relaxing
        ))
    }
    .modelContainer(for: DrinkEntry.self, inMemory: true)
}
