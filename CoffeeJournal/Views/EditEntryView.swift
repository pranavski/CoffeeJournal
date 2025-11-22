import SwiftUI
import SwiftData

struct EditEntryView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var entry: DrinkEntry

    @State private var drinkType: DrinkType
    @State private var specificDrink: String
    @State private var location: String
    @State private var temperature: DrinkTemperature
    @State private var milkType: MilkType
    @State private var price: String
    @State private var rating: Int
    @State private var notes: String
    @State private var selectedMood: DrinkMood?
    @State private var tags: [String]
    @State private var newTag: String = ""

    init(entry: DrinkEntry) {
        self.entry = entry
        _drinkType = State(initialValue: entry.drinkType)
        _specificDrink = State(initialValue: entry.specificDrink)
        _location = State(initialValue: entry.location)
        _temperature = State(initialValue: entry.temperature)
        _milkType = State(initialValue: entry.milkType)
        _price = State(initialValue: entry.price.map { String(format: "%.2f", $0) } ?? "")
        _rating = State(initialValue: entry.rating)
        _notes = State(initialValue: entry.notes)
        _selectedMood = State(initialValue: entry.mood)
        _tags = State(initialValue: entry.tags)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.creamBackground
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // Photo Preview
                        if let photoData = entry.photoData,
                           let uiImage = UIImage(data: photoData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 180)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
                        }

                        // Drink Type Selection
                        DrinkTypeSection(drinkType: $drinkType)

                        // Specific Drink
                        SpecificDrinkSection(drinkType: drinkType, specificDrink: $specificDrink)

                        // Temperature
                        TemperatureSection(temperature: $temperature)

                        // Location
                        FormField(title: "Location", icon: "mappin") {
                            TextField("Coffee shop or home", text: $location)
                                .textFieldStyle(CoffeeTextFieldStyle())
                        }

                        // Milk Type
                        MilkTypeSection(milkType: $milkType)

                        // Price
                        FormField(title: "Price (optional)", icon: "dollarsign.circle") {
                            TextField("0.00", text: $price)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(CoffeeTextFieldStyle())
                        }

                        // Rating
                        RatingSection(rating: $rating)

                        // Mood
                        MoodSection(selectedMood: $selectedMood)

                        // Tags
                        TagsSection(tags: $tags, newTag: $newTag)

                        // Notes
                        FormField(title: "Notes", icon: "note.text") {
                            TextEditor(text: $notes)
                                .frame(minHeight: 100)
                                .padding(8)
                                .background(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.coffeeBrown.opacity(0.2), lineWidth: 1)
                                )
                        }
                    }
                    .padding(16)
                    .padding(.bottom, 100)
                }

                // Bottom Buttons
                VStack {
                    Spacer()
                    HStack(spacing: 16) {
                        Button(action: { dismiss() }) {
                            Text("Cancel")
                                .font(.headline)
                                .foregroundStyle(Color.coffeeBrown)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.coffeeBrown, lineWidth: 1)
                                )
                        }

                        Button(action: saveChanges) {
                            Text("Save Changes")
                                .font(.headline)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(AppGradients.coffeePrimary)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                    }
                    .padding(16)
                    .background(.ultraThinMaterial)
                }
            }
            .navigationTitle("Edit Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { saveChanges() }
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.coffeeBrown)
                }
            }
        }
    }

    private func saveChanges() {
        entry.drinkType = drinkType
        entry.specificDrink = specificDrink
        entry.location = location
        entry.temperature = temperature
        entry.milkType = milkType
        entry.price = Double(price)
        entry.rating = rating
        entry.notes = notes
        entry.mood = selectedMood
        entry.tags = tags
        entry.updatedAt = Date()

        dismiss()
    }
}

#Preview {
    EditEntryView(entry: DrinkEntry(
        drinkType: .coffee,
        specificDrink: "Latte",
        location: "Starbucks",
        rating: 4,
        notes: "Pretty good!"
    ))
    .modelContainer(for: DrinkEntry.self, inMemory: true)
}
