import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Tab = .home
    @State private var showCamera = false

    enum Tab: String, CaseIterable {
        case home = "Home"
        case gallery = "Gallery"
        case profile = "Profile"

        var icon: String {
            switch self {
            case .home: return "house.fill"
            case .gallery: return "photo.on.rectangle.angled"
            case .profile: return "person.fill"
            }
        }
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab.home.tab {
                HomeView(showCamera: $showCamera)
            }

            Tab.gallery.tab {
                GalleryView()
            }

            Tab.profile.tab {
                ProfileView()
            }
        }
        .tabViewStyle(.sidebarAdaptable)
        .tint(Color.coffeeBrown)
        .fullScreenCover(isPresented: $showCamera) {
            CameraCaptureView()
        }
    }
}

// MARK: - Tab Extension for iOS 26
extension ContentView.Tab {
    func tab<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .tabItem {
                Label(self.rawValue, systemImage: self.icon)
            }
            .tag(self)
    }
}

#Preview {
    ContentView()
}
