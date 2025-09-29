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
        
        // Much more lenient thresholds to prevent snapping
        let collapseThreshold: CGFloat = -80  // Only collapse when scrolled down 80 points
        let expandThreshold: CGFloat = -20    // Only expand when scrolled back up to -20 points
        
        let shouldCollapse: Bool
        if isHeaderCollapsed {
            // Currently collapsed - only expand if we're well above the expand threshold
            shouldCollapse = offset < expandThreshold
        } else {
            // Currently expanded - only collapse if we're well below the collapse threshold
            shouldCollapse = offset < collapseThreshold
        }
        
        if shouldCollapse != isHeaderCollapsed {
            // Very smooth, slow animation that doesn't interfere with scrolling
            withAnimation(.easeInOut(duration: 0.4)) {
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
                title: "Share Profile",
                icon: "square.and.arrow.up",
                action: {}
            )
            
            ActionButtonView(
                title: "Settings",
                icon: "gearshape",
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
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .medium))
                
                Text(title)
                    .font(.system(size: 12, weight: .medium))
            }
            .foregroundColor(.primary)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color(.systemGray5))
            .cornerRadius(6)
        }
    }
}

// MARK: - Search Overlay View

struct SearchOverlayView: View {
    @Binding var searchText: String
    @Binding var isSearching: Bool
    @FocusState.Binding var isSearchFocused: Bool
    
    var body: some View {
                    VStack(spacing: 0) {
            // Search Bar with Filter and Cancel (matching Discover page)
                        HStack {
                            HStack {
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
                            
                                // Filter Button
                                Button(action: {
                                    // Handle filter action
                                }) {
                                    Image(systemName: "slider.horizontal.3")
                                        .font(.system(size: 20))
                                        .foregroundColor(.white)
                                }
                            .padding(.leading, 8)
                            
                            // Cancel Button
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    isSearching = false
                                    isSearchFocused = false
                                    searchText = ""
                                }
                            }) {
                                Text("Cancel")
                                    .foregroundColor(.white)
                                    .font(.system(size: 16))
                            }
                            .padding(.leading, 8)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 60) // Account for status bar
                        .padding(.bottom, 12)
                         .background(Color.black)
                        
                        // Content Area - Blank until text is typed
                        if searchText.isEmpty {
                            Spacer()
                        } else {
                // Search Results
                            ScrollView {
                                LazyVStack(spacing: 0) {
                        // Placeholder for search results
                        VStack(spacing: 16) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 48))
                                .foregroundColor(.secondary)
                            
                            Text("Search for beers, breweries, or styles")
                                .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.secondary)
                        }
                        .padding(.top, 100)
                    }
                }
            }
        }
        .background(Color.black)
    }
}

// MARK: - Content Views

struct NextBeersGridView: View {
    @ObservedObject var viewModel: MyBarlieViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(0..<4, id: \.self) { row in
                HStack(spacing: 0) {
                    ForEach(0..<4, id: \.self) { column in
                        let index = row * 4 + column
                        if index < Beer.sampleBeers.count {
                            ProfileBeerCardView(beer: Beer.sampleBeers[index])
                                .containerRelativeFrame(.horizontal, count: 4, span: 1, spacing: 0)
                                .aspectRatio(1, contentMode: .fit)
                        } else if index == Beer.sampleBeers.count {
                            // Add Beer button
            Button(action: {
                                // Handle add beer action
                            }) {
                                ZStack {
                                    Rectangle()
                                        .fill(Color(.systemGray5))
                                        .containerRelativeFrame(.horizontal, count: 4, span: 1, spacing: 0)
                                        .aspectRatio(1, contentMode: .fit)
                                    
                                    VStack(spacing: 4) {
                                        Image(systemName: "plus")
                                            .font(.system(size: 24, weight: .medium))
                                            .foregroundColor(.secondary)
                                        
                                        Text("Add Beer")
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                        } else {
                            // Empty space for remaining slots in the row
                            Rectangle()
                                .fill(Color.clear)
                                .containerRelativeFrame(.horizontal, count: 4, span: 1, spacing: 0)
                                .aspectRatio(1, contentMode: .fit)
                        }
                    }
                }
            }
            
            // Extra space to allow scrolling even in empty state
            Spacer()
                .frame(height: 1200)
        }
    }
}

struct DrankBeersGridView: View {
    @ObservedObject var viewModel: MyBarlieViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(0..<12, id: \.self) { row in
                HStack(spacing: 0) {
                    ForEach(0..<4, id: \.self) { column in
                        let index = row * 4 + column
                        if index < Beer.sampleBeers.count {
                            ProfileBeerCardView(beer: Beer.sampleBeers[index])
                                .containerRelativeFrame(.horizontal, count: 4, span: 1, spacing: 0)
                                .aspectRatio(1, contentMode: .fit)
                        } else if index == Beer.sampleBeers.count {
                            // Add Beer button
            Button(action: {
                                // Handle add beer action
                            }) {
                                ZStack {
                                    Rectangle()
                                        .fill(Color(.systemGray5))
                                        .containerRelativeFrame(.horizontal, count: 4, span: 1, spacing: 0)
                                        .aspectRatio(1, contentMode: .fit)
                                    
            VStack(spacing: 4) {
                                        Image(systemName: "plus")
                                            .font(.system(size: 24, weight: .medium))
                                            .foregroundColor(.secondary)
                                        
                                        Text("Add Beer")
                                            .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
                                    }
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                        } else {
                            // Empty space for remaining slots in the row
                            Rectangle()
                                .fill(Color.clear)
                                .containerRelativeFrame(.horizontal, count: 4, span: 1, spacing: 0)
                                .aspectRatio(1, contentMode: .fit)
                        }
                    }
                }
            }
            
            // Extra space to allow scrolling even in empty state
            Spacer()
                .frame(height: 1200)
        }
    }
}

struct ListsView: View {
    @ObservedObject var viewModel: MyBarlieViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            // Add New List button at the top
        Button(action: {
                // Handle add new list action
            }) {
                HStack(spacing: 12) {
                    ZStack {
                        Rectangle()
                            .fill(Color(.systemGray5))
                            .frame(width: 40, height: 40)
            .cornerRadius(8)
                        
                        Image(systemName: "plus")
                            .font(.system(size: 24))
                            .foregroundColor(.secondary)
                    }
                    
                    Text("Make New List")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
        }
        .padding(.horizontal, 20)
                .padding(.vertical, 16)
                         .background(Color.black)
            }
            .buttonStyle(PlainButtonStyle())
            
            ForEach(0..<3, id: \.self) { index in
                ListCardView(
                    title: "List \(index + 1)",
                    count: "\(Int.random(in: 5...20)) beers"
                )
            }
            
            // Extra space to allow scrolling even in empty state
            Spacer()
                .frame(height: 1200)
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - Card Views

struct ProfileBeerCardView: View {
    let beer: Beer
    
    var body: some View {
        NavigationLink(destination: BeerDetailView(beer: beer, isMarkedAsNext: true)) {
            // Very visible gradient placeholder for testing
        Rectangle()
            .fill(
                LinearGradient(
                        gradient: Gradient(colors: [.red, .orange, .yellow, .green, .blue, .purple]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .aspectRatio(1, contentMode: .fit)
            .overlay(
                    Text("\(beer.name)")
                        .font(.caption)
                        .foregroundColor(.white)
                        .fontWeight(.bold)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ListCardView: View {
    let title: String
    let count: String
    
    var body: some View {
        HStack(spacing: 12) {
            // List icon
            RoundedRectangle(cornerRadius: 8)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [Color(.systemGray4), Color(.systemGray5)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 60, height: 80)
                .overlay(
                    Image(systemName: "list.bullet")
                        .font(.system(size: 24))
                        .foregroundColor(.secondary)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text(count)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
                         .background(Color.black)
    }
}

// MARK: - Beer Detail View

struct BeerDetailView: View {
    let beer: Beer
    let isMarkedAsNext: Bool
    @State private var isNextActive = false
    @State private var isRatingSheetPresented = false
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Beer Image
                    Rectangle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [.red, .orange, .yellow, .green, .blue, .purple]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 200, height: 200)
                        .cornerRadius(16)
                        .padding(.top, 40)
                    
                    // Action Buttons
                    HStack(spacing: 16) {
                        if isNextActive {
                            // Active state with menu
                            Menu {
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        isNextActive = true
                                    }
                                }) {
                                    Label("Currently Drinking", systemImage: "mug.fill")
                                }
                                
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        isNextActive = true
                                    }
                                }) {
                                    Label("Up Next", systemImage: "pin.fill")
                                }
                                
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        isNextActive = true
                                    }
                                }) {
                                    Label("Mark as Drank", systemImage: "checkmark.circle.fill")
                                }
                                
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        isNextActive = false
                                    }
                                }) {
                                    Label("Unqueue", systemImage: "minus.circle.fill")
                                }
                            } label: {
                                HStack(spacing: 8) {
                                    Text("Next")
                                        .font(.system(size: 16, weight: .medium))
                                    Image(systemName: "chevron.down")
                                        .font(.system(size: 14, weight: .medium))
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                                .background(Color.red)
                                .cornerRadius(8)
                            }
                            .buttonStyle(PlainButtonStyle())
                        } else {
                            // Inactive state with simple button
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    isNextActive = true
                                }
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "plus")
                                        .font(.system(size: 16, weight: .medium))
                                    Text("Next")
                                        .font(.system(size: 16, weight: .medium))
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        
                        Button(action: {
                            isRatingSheetPresented = true
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "hand.thumbsup")
                                    .font(.system(size: 16, weight: .medium))
                                Text("Rate it")
                                    .font(.system(size: 16, weight: .medium))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(.horizontal, 20)
                    
                    // Beer Information
                    VStack(alignment: .leading, spacing: 16) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(beer.name)
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text(beer.brewery)
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(.secondary)
                            
                            Text(beer.style)
                                .font(.system(size: 16, weight: .regular))
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                        }
                        
                        Divider()
                            .background(Color(.systemGray3))
                        
                        // Beer Details Section
                        VStack(alignment: .leading, spacing: 12) {
                            
                            VStack(alignment: .leading, spacing: 8) {
                                DetailRow(title: "ABV", value: "\(beer.abv)%")
                                DetailRow(title: "IBU", value: "\(beer.ibu)")
                                DetailRow(title: "Color", value: beer.color)
                                DetailRow(title: "Type", value: beer.style)
                            }
                        }
                        
                        Divider()
                            .background(Color(.systemGray3))
                        
                        // Description Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Description")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white)
                            
                            Text(beer.description)
                                .font(.system(size: 16))
                                .foregroundColor(.secondary)
                                .lineSpacing(4)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            isNextActive = isMarkedAsNext
        }
        .sheet(isPresented: $isRatingSheetPresented) {
            BeerRatingSheet(beer: beer)
        }
    }
}

struct DetailRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 16))
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Preference Key

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: - Beer Rating Sheet

struct BeerRatingSheet: View {
    let beer: Beer
    @Environment(\.dismiss) private var dismiss
    @State private var reviewText = ""
    @State private var selectedRating: RatingType? = nil
    
    enum RatingType: CaseIterable {
        case thumbsDown, neutral, thumbsUp, heart
        
        var icon: String {
            switch self {
            case .thumbsDown: return "hand.thumbsdown.fill"
            case .neutral: return "face.dashed"
            case .thumbsUp: return "hand.thumbsup"
            case .heart: return "heart"
            }
        }
        
        var emoji: String {
            switch self {
            case .thumbsDown: return "👎"
            case .neutral: return "😑"
            case .thumbsUp: return "👍"
            case .heart: return "❤️"
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header with beer info
                    HStack(spacing: 16) {
                        // Beer image placeholder
                        Rectangle()
                            .fill(LinearGradient(
                                colors: [.blue, .purple, .pink, .orange, .red],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .frame(width: 80, height: 80)
                            .cornerRadius(12)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Rome drank \(beer.name)")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text(beer.brewery)
                                .font(.system(size: 16))
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            // More options
                        }) {
                            Image(systemName: "ellipsis")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 30)
                    
                    // Rating Section
                    VStack(spacing: 16) {
                        Text("RATING")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                            .tracking(1)
                        
                        HStack(spacing: 20) {
                            ForEach(RatingType.allCases, id: \.self) { rating in
                                Button(action: {
                                    selectedRating = rating
                                }) {
                                    if selectedRating == rating {
                                        Text(rating.emoji)
                                            .font(.system(size: 24))
                                    } else {
                                        Image(systemName: rating.icon)
                                            .font(.system(size: 20, weight: .medium))
                                            .foregroundColor(.white)
                                    }
                                }
                                .frame(width: 50, height: 50)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(selectedRating == rating ? Color.red : Color(.systemGray6))
                                )
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                    .padding(.bottom, 30)
                    
                    // Review Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("REVIEW")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                            .tracking(1)
                        
                        TextEditor(text: $reviewText)
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            .frame(height: 120)
                            .overlay(
                                Group {
                                    if reviewText.isEmpty {
                                        HStack {
                                            VStack {
                                                Text("What'd you think?")
                                                    .font(.system(size: 16))
                                                    .foregroundColor(.secondary)
                                                    .padding(.top, 8)
                                                Spacer()
                                            }
                                            Spacer()
                                        }
                                        .allowsHitTesting(false)
                                    }
                                }
                            )
                        
                        HStack {
                            Spacer()
                            
                            Text("\(reviewText.count)/280")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer()
                    
                    // Action Buttons
                    HStack(spacing: 16) {
                        Button("Cancel") {
                            dismiss()
                        }
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.clear)
                        .cornerRadius(8)
                        
                        Button("Submit") {
                            // Handle submit
                            dismiss()
                        }
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.red)
                        .cornerRadius(8)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
        }
        .navigationBarHidden(true)
    }
}

// MARK: - Preview

#Preview {
    MyBarlieView()
}