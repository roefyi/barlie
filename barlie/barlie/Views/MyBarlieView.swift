import SwiftUI

struct MyBarlieView: View {
    @StateObject private var viewModel = MyBarlieViewModel()
    @State private var selectedTab: ProfileTab = .next
    @State private var scrollOffset: CGFloat = 0
    @State private var showCompactHeader = false
    @State private var searchText = ""
    @State private var isSearching = false
    @FocusState private var isSearchFocused: Bool
    @State private var headerHeight: CGFloat = 0
    
    enum ProfileTab: String, CaseIterable {
        case next = "Next"
        case drank = "Drank"
        case lists = "Lists"
    }
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                // Scrollable Content
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            // Profile Header with Fixed Search Icon
                            ProfileHeaderWithFixedSearchView(
                                isSearching: $isSearching,
                                showCompactHeader: $showCompactHeader,
                                headerHeight: $headerHeight
                            )
                            
                            // User Stats
                            UserStatsView()
                                .padding(.bottom, 16)
                            
                            // Action Buttons
                            ActionButtonsView()
                                .padding(.bottom, 16)
                            
                            // Tab Selector
                            ProfileTabSelector(selectedTab: $selectedTab)
                                .padding(.bottom, 16)
                            
                            // Content based on selected tab
                            Group {
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
                    .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                        // Scroll detection is now handled in ProfileHeaderWithFixedSearchView
                        print("Scroll offset: \(value), showCompact: \(showCompactHeader)")
                    }
                }
                
                // Navigation Bar (appears when scrolling)
                if showCompactHeader {
                    CompactNavigationBarView(isSearching: $isSearching)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .zIndex(1)
                }
                
                // Full-Screen Search Overlay
                if isSearching {
                    VStack(spacing: 0) {
                        // Search Bar with Filter and Cancel
                        HStack {
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.secondary)
                                
                                TextField("Search for beers, breweries, or styles", text: $searchText)
                                    .textFieldStyle(PlainTextFieldStyle())
                                    .focused($isSearchFocused)
                                    .onChange(of: searchText) { newValue in
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
                        .onAppear {
                            // Set focus when search overlay appears
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                isSearchFocused = true
                            }
                        }
                        
                        // Content Area - Blank until text is typed
                        if searchText.isEmpty {
                            Spacer()
                        } else {
                            // Search Results (could be profile-specific search)
                            ScrollView {
                                LazyVStack(spacing: 0) {
                                    // For now, show a placeholder - could search user's beers, lists, etc.
                                    Text("Search results for: \(searchText)")
                                        .font(.system(size: 16))
                                        .foregroundColor(.secondary)
                                        .padding()
                                }
                            }
                        }
                    }
                         .background(Color.black)
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .navigationBarHidden(true)
        }
    }
}

// Custom preference key for scroll offset
struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// Compact Navigation Bar that appears when scrolling
struct CompactNavigationBarView: View {
    @Binding var isSearching: Bool
    
    var body: some View {
        HStack(alignment: .top) {
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isSearching = true
                }
            }) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 18))
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .padding(.top, 2)
            }
            
            Spacer()
            
            Text("Rome")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.white)
            
            Spacer()
            
            // Empty space for symmetry
            Color.clear
                .frame(width: 44, height: 44)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            Color.black
                .ignoresSafeArea(.container, edges: .top)
        )
        .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 1)
    }
}

struct ProfileHeaderWithFixedSearchView: View {
    @Binding var isSearching: Bool
    @Binding var showCompactHeader: Bool
    @Binding var headerHeight: CGFloat
    
    var body: some View {
        HStack(alignment: .top) {
            // Fixed Search Icon (never moves)
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isSearching = true
                }
            }) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .padding(.top, 2)
            }
            
            Spacer()
            
            // Profile Content (shrinks and fades)
            VStack(spacing: 4) {
                // Profile Image - shrinks when scrolling
                Circle()
                    .fill(Color(.systemGray2))
                    .frame(
                        width: showCompactHeader ? 30 : 60,
                        height: showCompactHeader ? 30 : 60
                    )
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.system(size: showCompactHeader ? 15 : 30))
                            .foregroundColor(.primary)
                    )
                    .animation(.easeInOut(duration: 0.25), value: showCompactHeader)
                
                // Username - fades out when scrolling
                Text("Rome")
                    .font(.system(size: showCompactHeader ? 17 : 24, weight: .bold))
                    .foregroundColor(.white)
                    .opacity(showCompactHeader ? 0 : 1)
                    .animation(.easeInOut(duration: 0.25), value: showCompactHeader)
                
                // Handle - fades out when scrolling
                Text("@romandenson")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .opacity(showCompactHeader ? 0 : 1)
                    .animation(.easeInOut(duration: 0.25), value: showCompactHeader)
            }
            
            Spacer()
            
            // Empty space for symmetry
            Color.clear
                .frame(width: 44, height: 44)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
        .background(Color.black)
        .background(
            GeometryReader { geometry in
                Color.clear
                    .onAppear {
                        headerHeight = geometry.size.height
                    }
                    .onChange(of: geometry.frame(in: .global).minY) { newValue in
                        // More reliable scroll detection
                        let threshold: CGFloat = headerHeight > 0 ? headerHeight * 0.3 : 60
                        let shouldShowCompact = newValue < -threshold
                        
                        if shouldShowCompact != showCompactHeader {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                showCompactHeader = shouldShowCompact
                            }
                        }
                    }
                    .preference(
                        key: ScrollOffsetPreferenceKey.self,
                        value: geometry.frame(in: .global).minY
                    )
            }
        )
    }
}

struct ProfileHeaderView: View {
    @Binding var isSearching: Bool
    
    var body: some View {
        HStack(alignment: .top) {
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isSearching = true
                }
            }) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .padding(.top, 2) // Align with top of profile image
            }
            
            Spacer()
            
            VStack(spacing: 4) {
                // Profile Image
                Circle()
                    .fill(Color(.systemGray2))
                    .frame(width: 60, height: 60)
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.primary)
                    )
                
                Text("Rome")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                
                Text("@romandenson")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Empty space for symmetry
            Color.clear
                .frame(width: 44, height: 44)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
                         .background(Color.black)
    }
}

struct UserStatsView: View {
    var body: some View {
        HStack(spacing: 20) {
            StatItemView(number: "127", label: "Beers Rated")
            
            Spacer()
            
            StatItemView(number: "4.2", label: "Avg Rating")
        }
        .padding(.horizontal, 20)
    }
}

struct StatItemView: View {
    let number: String
    let label: String
    
    var body: some View {
        VStack(spacing: 2) {
            Text(number)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.primary)
            
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(.secondary)
        }
    }
}

struct ActionButtonsView: View {
    var body: some View {
        HStack(spacing: 12) {
            ActionButtonView(icon: "clock", title: "Activity")
            ActionButtonView(icon: "square.and.arrow.up", title: "Share")
            ActionButtonView(icon: "gear", title: "Settings")
        }
        .padding(.horizontal, 20)
    }
}

struct ActionButtonView: View {
    let icon: String
    let title: String
    
    var body: some View {
        Button(action: {
            // Handle action
        }) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                
                Text(title)
                    .font(.system(size: 13, weight: .medium))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(.systemGray6))
            .foregroundColor(.primary)
            .cornerRadius(8)
        }
    }
}

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
                        Text(tab.rawValue)
                            .font(.system(size: 16, weight: .medium))
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
        .padding(.horizontal, 20)
                         .background(Color.black)
    }
}

struct NextBeersGridView: View {
    @ObservedObject var viewModel: MyBarlieViewModel
    
    let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 4)
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 0) {
            ForEach(viewModel.nextBeers) { beer in
                BeerGridView(beer: beer)
            }
            
            // Add More Card
            AddMoreBeerView()
        }
    }
}

struct DrankBeersGridView: View {
    @ObservedObject var viewModel: MyBarlieViewModel
    
    let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 4)
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 0) {
            ForEach(viewModel.drankBeers) { beer in
                BeerGridView(beer: beer)
            }
            
            // Add More Card
            AddMoreBeerView()
        }
    }
}

struct BeerGridView: View {
    let beer: Beer
    
    var body: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [Color(.systemGray4), Color(.systemGray5)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .aspectRatio(1, contentMode: .fit)
            .clipped()
    }
}

struct AddMoreBeerView: View {
    var body: some View {
        Rectangle()
            .fill(Color(.systemGray6))
            .aspectRatio(1, contentMode: .fit)
            .overlay(
                Image(systemName: "plus")
                    .font(.system(size: 24))
                    .foregroundColor(.secondary)
            )
            .clipped()
    }
}

struct ListsView: View {
    @ObservedObject var viewModel: MyBarlieViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(viewModel.beerLists) { list in
                ListCardView(list: list)
            }
            
            CreateNewListView()
        }
    }
}

struct ListCardView: View {
    let list: BeerList
    
    var body: some View {
        HStack(spacing: 12) {
            // List Icon
            RoundedRectangle(cornerRadius: 8)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [Color(.systemGray4), Color(.systemGray5)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 60, height: 80)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(list.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text("\(list.beerIds.count) beers")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
                         .background(Color.black)
        .overlay(
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(Color(.separator))
                .offset(y: 16),
            alignment: .bottom
        )
    }
}

struct CreateNewListView: View {
    var body: some View {
        HStack(spacing: 12) {
            // Create Icon
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemGray5))
                .frame(width: 60, height: 80)
                .overlay(
                    Image(systemName: "plus")
                        .font(.system(size: 20))
                        .foregroundColor(.secondary)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.secondary, style: StrokeStyle(lineWidth: 2, dash: [5]))
                )
            
            Text("Create New List")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.primary)
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
                         .background(Color.black)
        .overlay(
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(Color(.separator))
                .offset(y: 16),
            alignment: .bottom
        )
    }
}

#Preview {
    MyBarlieView()
}
