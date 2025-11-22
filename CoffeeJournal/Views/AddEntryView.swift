import SwiftUI
import SwiftData

struct AddEntryView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let imageData: Data?
    let previewImage: UIImage?

    @State private var drinkType: DrinkType = .coffee
    @State private var specificDrink: String = ""
    @State private var location: String = ""
    @State private var temperature: DrinkTemperature = .hot
    @State private var milkType: MilkType = .none
    @State private var price: String = ""
    @State private var rating: Int = 4
    @State private var notes: String = ""
    @State private var selectedMood: DrinkMood?
    @State private var tags: [String] = []
    @State private var newTag: String = ""

    var body: some View {
        NavigationStack {
            ZStack {
                Color.creamBackground
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // Photo Preview
                        PhotoPreviewSection(image: previewImage)

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
                    BottomButtonSection(onCancel: { dismiss() }, onSave: saveEntry)
                }
            }
            .navigationTitle("Add Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Color.coffeeBrown)
                }
            }
        }
    }

    private func saveEntry() {
        let entry = DrinkEntry(
            drinkType: drinkType,
            specificDrink: specificDrink,
            location: location,
            temperature: temperature,
            milkType: milkType,
            price: Double(price),
            rating: rating,
            notes: notes,
            mood: selectedMood,
            tags: tags,
            photoData: imageData
        )

        modelContext.insert(entry)

        dismiss()
        // Dismiss camera view as well
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            NotificationCenter.default.post(name: .dismissCamera, object: nil)
        }
    }
}

// MARK: - Notification Extension
extension Notification.Name {
    static let dismissCamera = Notification.Name("dismissCamera")
}

// MARK: - Photo Preview Section
struct PhotoPreviewSection: View {
    let image: UIImage?

    var body: some View {
        if let image = image {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
        }
    }
}

// MARK: - Drink Type Section
struct DrinkTypeSection: View {
    @Binding var drinkType: DrinkType

    var body: some View {
        FormField(title: "Drink Type", icon: "cup.and.saucer") {
            HStack(spacing: 12) {
                ForEach(DrinkType.allCases, id: \.self) { type in
                    DrinkTypeButton(type: type, isSelected: drinkType == type) {
                        drinkType = type
                    }
                }
            }
        }
    }
}

struct DrinkTypeButton: View {
    let type: DrinkType
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Text(type.emoji)
                    .font(.title2)
                Text(type.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(isSelected ? AppGradients.coffeePrimary : AnyShapeStyle(Color.white))
            .foregroundStyle(isSelected ? .white : Color.primaryText)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.coffeeBrown.opacity(0.2), lineWidth: isSelected ? 0 : 1)
            )
        }
    }
}

// MARK: - Specific Drink Section
struct SpecificDrinkSection: View {
    let drinkType: DrinkType
    @Binding var specificDrink: String

    var body: some View {
        FormField(title: "Specific Drink", icon: "list.bullet") {
            Menu {
                ForEach(drinkType.subTypes, id: \.self) { subType in
                    Button(subType) {
                        specificDrink = subType
                    }
                }
            } label: {
                HStack {
                    Text(specificDrink.isEmpty ? "Select drink type" : specificDrink)
                        .foregroundStyle(specificDrink.isEmpty ? Color.secondaryText : Color.primaryText)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .foregroundStyle(Color.secondaryText)
                }
                .padding(12)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.coffeeBrown.opacity(0.2), lineWidth: 1)
                )
            }
        }
    }
}

// MARK: - Temperature Section
struct TemperatureSection: View {
    @Binding var temperature: DrinkTemperature

    var body: some View {
        FormField(title: "Temperature", icon: "thermometer.medium") {
            HStack(spacing: 12) {
                ForEach(DrinkTemperature.allCases, id: \.self) { temp in
                    Button(action: { temperature = temp }) {
                        HStack {
                            Image(systemName: temp.icon)
                            Text(temp.rawValue)
                        }
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(temperature == temp ? AppGradients.coffeePrimary : AnyShapeStyle(Color.white))
                        .foregroundStyle(temperature == temp ? .white : Color.primaryText)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.coffeeBrown.opacity(0.2), lineWidth: temperature == temp ? 0 : 1)
                        )
                    }
                }
            }
        }
    }
}

// MARK: - Milk Type Section
struct MilkTypeSection: View {
    @Binding var milkType: MilkType

    var body: some View {
        FormField(title: "Milk Type", icon: "drop") {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(MilkType.allCases, id: \.self) { milk in
                        Button(action: { milkType = milk }) {
                            Text(milk.rawValue)
                                .font(.caption)
                                .fontWeight(.medium)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(milkType == milk ? AppGradients.coffeePrimary : AnyShapeStyle(Color.white))
                                .foregroundStyle(milkType == milk ? .white : Color.primaryText)
                                .clipShape(Capsule())
                                .overlay(
                                    Capsule()
                                        .stroke(Color.coffeeBrown.opacity(0.2), lineWidth: milkType == milk ? 0 : 1)
                                )
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Rating Section
struct RatingSection: View {
    @Binding var rating: Int

    var body: some View {
        FormField(title: "Rating", icon: "star") {
            HStack(spacing: 8) {
                ForEach(1...5, id: \.self) { index in
                    Button(action: { rating = index }) {
                        Image(systemName: index <= rating ? "star.fill" : "star")
                            .font(.title)
                            .foregroundStyle(Color.ratingGold)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
        }
    }
}

// MARK: - Mood Section
struct MoodSection: View {
    @Binding var selectedMood: DrinkMood?

    var body: some View {
        FormField(title: "Mood (optional)", icon: "face.smiling") {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(DrinkMood.allCases, id: \.self) { mood in
                        Button(action: {
                            selectedMood = selectedMood == mood ? nil : mood
                        }) {
                            HStack(spacing: 4) {
                                Text(mood.icon)
                                Text(mood.rawValue)
                            }
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(selectedMood == mood ? AppGradients.coffeePrimary : AnyShapeStyle(Color.white))
                            .foregroundStyle(selectedMood == mood ? .white : Color.primaryText)
                            .clipShape(Capsule())
                            .overlay(
                                Capsule()
                                    .stroke(Color.coffeeBrown.opacity(0.2), lineWidth: selectedMood == mood ? 0 : 1)
                            )
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Tags Section
struct TagsSection: View {
    @Binding var tags: [String]
    @Binding var newTag: String

    var body: some View {
        FormField(title: "Tags (optional)", icon: "tag") {
            VStack(alignment: .leading, spacing: 12) {
                // Tag input field
                HStack {
                    TextField("Add a tag", text: $newTag)
                        .textFieldStyle(CoffeeTextFieldStyle())
                        .submitLabel(.done)
                        .onSubmit {
                            addTag()
                        }

                    Button(action: addTag) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundStyle(Color.coffeeBrown)
                    }
                    .disabled(newTag.trimmingCharacters(in: .whitespaces).isEmpty)
                }

                // Display existing tags
                if !tags.isEmpty {
                    FlowLayout(spacing: 8) {
                        ForEach(tags, id: \.self) { tag in
                            HStack(spacing: 4) {
                                Text(tag)
                                    .font(.caption)
                                Button(action: { removeTag(tag) }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.caption)
                                }
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color.coffeeBrown.opacity(0.1))
                            .foregroundStyle(Color.coffeeBrown)
                            .clipShape(Capsule())
                        }
                    }
                }
            }
        }
    }

    private func addTag() {
        let trimmedTag = newTag.trimmingCharacters(in: .whitespaces)
        if !trimmedTag.isEmpty && !tags.contains(trimmedTag) {
            tags.append(trimmedTag)
            newTag = ""
        }
    }

    private func removeTag(_ tag: String) {
        tags.removeAll { $0 == tag }
    }
}

// MARK: - Flow Layout for Tags
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.width ?? 0, subviews: subviews, spacing: spacing)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x,
                                       y: bounds.minY + result.positions[index].y),
                         proposal: .unspecified)
        }
    }

    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []

        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)

                if currentX + size.width > maxWidth && currentX > 0 {
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }

                positions.append(CGPoint(x: currentX, y: currentY))
                lineHeight = max(lineHeight, size.height)
                currentX += size.width + spacing
                self.size.width = max(self.size.width, currentX)
            }

            self.size.height = currentY + lineHeight
        }
    }
}

// MARK: - Form Field Wrapper
struct FormField<Content: View>: View {
    let title: String
    let icon: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .foregroundStyle(Color.coffeeBrown)
                    .font(.subheadline)
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.primaryText)
            }
            content
        }
    }
}

// MARK: - Custom Text Field Style
struct CoffeeTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(12)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.coffeeBrown.opacity(0.2), lineWidth: 1)
            )
    }
}

// MARK: - Bottom Button Section
struct BottomButtonSection: View {
    let onCancel: () -> Void
    let onSave: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            Button(action: onCancel) {
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

            Button(action: onSave) {
                Text("Save Entry")
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

#Preview {
    AddEntryView(imageData: nil, previewImage: nil)
        .modelContainer(for: DrinkEntry.self, inMemory: true)
}
