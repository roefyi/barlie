import SwiftUI

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    let tabs: [(String, String)] = [
        ("magnifyingglass", "Discover"),
        ("person.circle", "My Barlie")
    ]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<tabs.count, id: \.self) { index in
                Button(action: {
                    withAnimation(.smoothSpring) {
                        HapticFeedback.light()
                        selectedTab = index
                    }
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: tabs[index].0)
                            .font(.system(size: 20))
                            .foregroundColor(selectedTab == index ? .primary : .secondary)
                            .scaleEffect(selectedTab == index ? 1.1 : 1.0)
                        
                        Text(tabs[index].1)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(selectedTab == index ? .primary : .secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
        .background(Color.black)
    }
}

// MARK: - Enhanced ContentView with Custom Tab Bar
struct EnhancedContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack {
            // Tab Content
            Group {
                switch selectedTab {
                case 0:
                    DiscoverView()
                        .slideInFromRight()
                case 1:
                    MyBarlieView()
                        .slideInFromLeft()
                default:
                    DiscoverView()
                }
            }
            .animation(.smoothSpring, value: selectedTab)
            
            VStack {
                Spacer()
                CustomTabBar(selectedTab: $selectedTab)
            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}

#Preview {
    EnhancedContentView()
}
