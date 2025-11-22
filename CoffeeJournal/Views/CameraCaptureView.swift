import SwiftUI
import PhotosUI

struct CameraCaptureView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedImage: UIImage?
    @State private var selectedItem: PhotosPickerItem?
    @State private var showImagePicker = false
    @State private var showCamera = false
    @State private var showAddEntry = false
    @State private var imageData: Data?
    @State private var flashMode: UIImagePickerController.CameraFlashMode = .auto

    var body: some View {
        NavigationStack {
            ZStack {
                // Dark background
                Color.black
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Camera Preview Area
                    ZStack {
                        if let image = selectedImage {
                            // Show selected image
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else {
                            // Placeholder
                            VStack(spacing: 16) {
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 64))
                                    .foregroundStyle(.white.opacity(0.6))

                                Text("Take or select a photo\nof your drink")
                                    .font(.subheadline)
                                    .foregroundStyle(.white.opacity(0.8))
                                    .multilineTextAlignment(.center)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                    // Controls
                    HStack(spacing: 40) {
                        // Gallery Button
                        PhotosPicker(selection: $selectedItem, matching: .images) {
                            VStack(spacing: 8) {
                                Image(systemName: "photo.on.rectangle")
                                    .font(.system(size: 28))
                                Text("Gallery")
                                    .font(.caption)
                            }
                            .foregroundStyle(.white)
                        }
                        .frame(width: 70)

                        // Capture Button
                        Button(action: { showCamera = true }) {
                            ZStack {
                                Circle()
                                    .stroke(.white, lineWidth: 4)
                                    .frame(width: 72, height: 72)

                                Circle()
                                    .fill(.white)
                                    .frame(width: 58, height: 58)
                            }
                        }

                        // Continue Button (appears when image selected)
                        if selectedImage != nil {
                            Button(action: { showAddEntry = true }) {
                                VStack(spacing: 8) {
                                    Image(systemName: "arrow.right.circle.fill")
                                        .font(.system(size: 28))
                                    Text("Continue")
                                        .font(.caption)
                                }
                                .foregroundStyle(Color.matchaGreen)
                            }
                            .frame(width: 70)
                        } else {
                            Color.clear
                                .frame(width: 70)
                        }
                    }
                    .padding(.vertical, 32)
                    .padding(.horizontal, 24)
                    .background(.ultraThinMaterial)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Capture")
                        .font(.headline)
                        .foregroundStyle(.white)
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundStyle(.white)
                            .padding(8)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { toggleFlashMode() }) {
                        Image(systemName: flashModeIcon)
                            .foregroundStyle(flashModeColor)
                            .padding(8)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
            .onChange(of: selectedItem) { _, newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                        imageData = data
                        selectedImage = UIImage(data: data)
                    }
                }
            }
            .fullScreenCover(isPresented: $showCamera) {
                ImagePicker(image: $selectedImage, imageData: $imageData, sourceType: .camera, flashMode: flashMode)
            }
            .fullScreenCover(isPresented: $showAddEntry) {
                AddEntryView(imageData: imageData, previewImage: selectedImage)
            }
        }
    }

    private var flashModeIcon: String {
        switch flashMode {
        case .auto: return "bolt.badge.automatic.fill"
        case .on: return "bolt.fill"
        case .off: return "bolt.slash.fill"
        @unknown default: return "bolt.fill"
        }
    }

    private var flashModeColor: Color {
        switch flashMode {
        case .auto: return .yellow
        case .on: return .yellow
        case .off: return .white
        @unknown default: return .yellow
        }
    }

    private func toggleFlashMode() {
        switch flashMode {
        case .auto:
            flashMode = .on
        case .on:
            flashMode = .off
        case .off:
            flashMode = .auto
        @unknown default:
            flashMode = .auto
        }
    }
}

// MARK: - Image Picker for Camera
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Binding var imageData: Data?
    let sourceType: UIImagePickerController.SourceType
    var flashMode: UIImagePickerController.CameraFlashMode = .auto
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        if sourceType == .camera {
            picker.cameraFlashMode = flashMode
        }
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
                parent.imageData = uiImage.jpegData(compressionQuality: 0.8)
            }
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

#Preview {
    CameraCaptureView()
}
