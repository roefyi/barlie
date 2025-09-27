import SwiftUI

struct MyBarlieView: View {
    @StateObject private var viewModel = MyBarlieViewModel()
    @State private var selectedTab: ProfileTab = .next
    @State private var isHeaderCollapsed = false
    @State private var searchText = ""
    @State private var isSearching = false
    @FocusState private var isSearchFocused: Bool
    @State private var scrollOffset: CGFloat = 0
    @State private var lastScrollTime: Date = Date()
    @State private var scrollVelocity: CGFloat = 0
    @State private var headerHeight: CGFloat = 200
    
    enum ProfileTab: String, CaseIterable {
        case next = "Next"
        case drank = "Drank"
        case lists = "Lists"
    }
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                // Main scrollable content
                ScrollView {
                    LazyVStack(spacing: 0) {
                        // Header with scroll detection
                        GeometryReader { geometry in
                            CollapsingHeaderView(
                                isCollapsed: $isHeaderCollapsed,
                                isSearching: $isSearching
                            )
                            .background(
                                Color.clear
                                    .onAppear {
                                        headerHeight = geometry.size.height
                                    }
                                    .onChange(of: geometry.frame(in: .global).minY) { _, newValue in
                                        scrollOffset = newValue
                                        handleScrollOffsetChange(newValue)
                                        print("Scroll offset: \(newValue)")
                                    }
                            )
                        }
                        .frame(height: headerHeight)
                        
                        
                        // User stats
                        UserStatsView()
                            .padding(.bottom, 16)
                        
                        // Action buttons
                        ActionButtonsView()
                            .padding(.bottom, 16)
                        
                        // Tab selector
                        ProfileTabSelector(selectedTab: $selectedTab)
                            .padding(.bottom, 16)
                            .background(Color.black)
                        
                        // Content based on selected tab
                        VStack(spacing: 0) {
                            switch selectedTab {
                            case .next:
                                NextBeersGridView(viewModel: viewModel)
                            case .drank:
                                DrankBeersGridView(viewModel: viewModel)
                            case .lists:
                                ListsView(viewModel: viewModel)
                            }
                        }
                        .animation(.easeInOut(duration: 0.3), value: selectedTab)
                    }
                }
                
                // Compact navigation bar overlay
                CompactNavigationBarView(isSearching: $isSearching)
                    .opacity(isHeaderCollapsed ? 1 : 0)
                    .zIndex(1)
                    .animation(.none, value: isHeaderCollapsed)
                
                // Search overlay
                if isSearching {
                    SearchOverlayView(
                        searchText: $searchText,
                        isSearching: $isSearching,
                        isSearchFocused: $isSearchFocused
                    )
                    .transition(.opacity)
                    .zIndex(2)
                }
            }
            .navigationBarHidden(true)
            .background(Color.black)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    // MARK: - Scroll Handling
    
    private func handleScrollOffsetChange(_ offset: CGFloat) {
        // Calculate scroll velocity
        let currentTime = Date()
        let timeDelta = currentTime.timeIntervalSince(lastScrollTime)
        
        if timeDelta > 0 {
            let offsetDelta = offset - scrollOffset
            scrollVelocity = abs(offsetDelta) / CGFloat(timeDelta)
        }
        
        lastScrollTime = currentTime
        scrollOffset = offset
        
        // Immediate threshold with velocity-based animation
        let threshold: CGFloat = 0  // Trigger immediately on any scroll
        
        let shouldCollapse = offset < threshold
        
        if shouldCollapse != isHeaderCollapsed {
            // Calculate animation response based on scroll velocity
            // Faster scroll = faster animation, slower scroll = slower animation
            let baseResponse: CGFloat = 0.3
            let velocityFactor = min(max(scrollVelocity * 0.1, 0.1), 2.0) // Clamp between 0.1 and 2.0
            let dynamicResponse = baseResponse / velocityFactor
            
            withAnimation(.interactiveSpring(
                response: dynamicResponse, 
                dampingFraction: 0.7, 
                blendDuration: 0.05
            )) {
                isHeaderCollapsed = shouldCollapse
            }
        }
    }
}

// MARK: - Collapsing Header View

struct CollapsingHeaderView: View {
    @Binding var isCollapsed: Bool
    @Binding var isSearching: Bool
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Search button (fixed position)
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isSearching = true
                }
            }) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(Color.black)
            }
            
            Spacer()
            
            // Profile content (animates based on collapse state)
            VStack(spacing: 8) {
                // Profile image
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.blue.opacity(0.8),
                                Color.purple.opacity(0.8)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(
                        width: isCollapsed ? 0 : 80,
                        height: isCollapsed ? 0 : 80
                    )
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.system(size: isCollapsed ? 0 : 40))
                            .foregroundColor(.white)
                    )
                    .animation(.easeInOut(duration: 0.3), value: isCollapsed)
                
                // Username
                Text("Rome")
                    .font(.system(
                        size: isCollapsed ? 0 : 18,
                        weight: .semibold
                    ))
                    .foregroundColor(.white)
                    .opacity(isCollapsed ? 0 : 1)
                    .animation(.easeInOut(duration: 0.3), value: isCollapsed)
                
                // Handle
                Text("@romandenson")
                    .font(.system(
                        size: isCollapsed ? 0 : 16,
                        weight: .medium
                    ))
                    .foregroundColor(.secondary)
                    .opacity(isCollapsed ? 0 : 1)
                    .animation(.easeInOut(duration: 0.3), value: isCollapsed)
            }
            
            Spacer()
            
            // Empty space for symmetry
            Color.clear
                .frame(width: 44, height: 44)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 24)
        .background(Color.black)
        .background(
            GeometryReader { geometry in
                Color.clear
                    .preference(
                        key: ScrollOffsetPreferenceKey.self,
                        value: geometry.frame(in: .global).minY
                    )
            }
        )
    }
}

// MARK: - Compact Navigation Bar

struct CompactNavigationBarView: View {
    @Binding var isSearching: Bool
    
    var body: some View {
        HStack(alignment: .center) {
            // Search button
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isSearching = true
                }
            }) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
            }
            
            Spacer()
            
            // Title
            Text("Rome")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
            
            Spacer()
            
            // Empty space for symmetry
            Color.clear
                .frame(width: 44, height: 44)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            Color.black
                .ignoresSafeArea(.container, edges: .top)
        )
        .shadow(color: .black.opacity(0.8), radius: 12, x: 0, y: 6)
    }
}

// MARK: - Profile Tab Selector

struct ProfileTabSelector: View {
    @Binding var selectedTab: MyBarlieView.ProfileTab
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(MyBarlieView.ProfileTab.allCases, id: \.self) { tab in
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedTab = tab
                    }
                }) {
                    VStack(spacing: 4) {
                        HStack(spacing: 6) {
                            Image(systemName: iconForTab(tab))
                                .font(.system(size: 16, weight: .medium))
                            
                            Text(tab.rawValue)
                                .font(.system(size: 16, weight: .medium))
                        }
                        .foregroundColor(selectedTab == tab ? .primary : .secondary)
                        
                        Rectangle()
                            .frame(height: 2)
                            .foregroundColor(selectedTab == tab ? .primary : .clear)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                }
            }
        }
        .background(Color.black)
    }
    
    private func iconForTab(_ tab: MyBarlieView.ProfileTab) -> String {
        switch tab {
        case .next:
            return "clock"
        case .drank:
            return "checkmark.circle"
        case .lists:
            return "list.bullet"
        }
    }
}

// MARK: - User Stats View

struct UserStatsView: View {
    var body: some View {
        HStack(spacing: 40) {
            StatItemView(title: "Next", value: "12")
            StatItemView(title: "Drank", value: "47")
            StatItemView(title: "Lists", value: "3")
        }
        .padding(.horizontal, 20)
    }
}

struct StatItemView: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
            
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Action Buttons View

struct ActionButtonsView: View {
    var body: some View {
        HStack(spacing: 12) {
            ActionButtonView(
                title: "Add Beer",
                icon: "plus",
                action: {}
            )
            
            ActionButtonView(
                title: "Scan",
                icon: "qrcode.viewfinder",
                action: {}
            )
        }
        .padding(.horizontal, 20)
    }
}

struct ActionButtonView: View {
    let title: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                
                Text(title)
                    .font(.system(size: 16, weight: .medium))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color.blue)
            .cornerRadius(8)
        }
    }
}

// MARK: - Search Overlay View

struct SearchOverlayView: View {
    @Binding var searchText: String
    @Binding var isSearching: Bool
    @FocusState.Binding var isSearchFocused: Bool
    
    var body: some View {
        ZStack {
            // Background
            Color.black.opacity(0.95)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Search bar
                HStack(spacing: 12) {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isSearching = false
                            isSearchFocused = false
                        }
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                    }
                    
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        
                        TextField("Search for beers, breweries, or styles", text: $searchText)
                            .textFieldStyle(PlainTextFieldStyle())
                            .focused($isSearchFocused)
                            .onChange(of: searchText) { _, newValue in
                                // Handle search in profile context
                            }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                Spacer()
                
                // Search results placeholder
                VStack(spacing: 16) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    
                    Text("Search for beers, breweries, or styles")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
        }
    }
}

// MARK: - Content Views

struct NextBeersGridView: View {
    @ObservedObject var viewModel: MyBarlieViewModel
    
    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            ForEach(0..<12, id: \.self) { index in
                ProfileBeerCardView(
                    title: "Beer \(index + 1)",
                    brewery: "Brewery \(index + 1)",
                    style: "IPA"
                )
            }
        }
        .padding(.horizontal, 20)
    }
}

struct DrankBeersGridView: View {
    @ObservedObject var viewModel: MyBarlieViewModel
    
    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            ForEach(0..<47, id: \.self) { index in
                ProfileBeerCardView(
                    title: "Drank Beer \(index + 1)",
                    brewery: "Brewery \(index + 1)",
                    style: "Stout"
                )
            }
        }
        .padding(.horizontal, 20)
    }
}

struct ListsView: View {
    @ObservedObject var viewModel: MyBarlieViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            ForEach(0..<3, id: \.self) { index in
                ListCardView(
                    title: "List \(index + 1)",
                    count: "\(Int.random(in: 5...20)) beers"
                )
            }
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - Card Views

struct ProfileBeerCardView: View {
    let title: String
    let brewery: String
    let style: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Beer image placeholder
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(height: 120)
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                Text(brewery)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                Text(style)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.blue)
                    .lineLimit(1)
            }
        }
        .padding(12)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct ListCardView: View {
    let title: String
    let count: String
    
    var body: some View {
        HStack(spacing: 16) {
            // List icon
            Image(systemName: "list.bullet")
                .font(.system(size: 24))
                .foregroundColor(.blue)
                .frame(width: 40, height: 40)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(count)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)
        }
        .padding(16)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Preference Key

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: - Preview

#Preview {
    MyBarlieView()
}