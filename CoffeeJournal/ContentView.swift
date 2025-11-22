import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Tab = .home
    @State private var showCamera = false

    enum Tab {
        case home, gallery, profile
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                HomeView(showCamera: $showCamera)
                    .tag(Tab.home)

                GalleryView()
                    .tag(Tab.gallery)

                ProfileView()
                    .tag(Tab.profile)
            }

            // Custom Tab Bar with Liquid Glass
            CustomTabBar(selectedTab: $selectedTab)
        }
        .fullScreenCover(isPresented: $showCamera) {
            CameraCaptureView()
        }
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: ContentView.Tab

    var body: some View {
        HStack(spacing: 0) {
            TabBarButton(
                icon: "house.fill",
                title: "Home",
                isSelected: selectedTab == .home
            ) {
                selectedTab = .home
            }

            TabBarButton(
                icon: "photo.on.rectangle.angled",
                title: "Gallery",
                isSelected: selectedTab == .gallery
            ) {
                selectedTab = .gallery
            }

            TabBarButton(
                icon: "person.fill",
                title: "Profile",
                isSelected: selectedTab == .profile
            ) {
                selectedTab = .profile
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 25))
        .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
        .padding(.horizontal, 40)
        .padding(.bottom, 8)
    }
}

struct TabBarButton: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 22))
                Text(title)
                    .font(.caption2)
                    .fontWeight(.medium)
            }
            .foregroundStyle(isSelected ? Color.coffeeBrown : .gray)
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    ContentView()
}
