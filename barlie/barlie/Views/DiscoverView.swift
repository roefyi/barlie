import SwiftUI

struct DiscoverView: View {
    @StateObject private var viewModel = DiscoverViewModel()
    @State private var searchText = ""
    @State private var selectedTab: DiscoverTab = .forYou
    @State private var isSearching = false
    @State private var showFilter = false
    @FocusState private var isSearchFocused: Bool
    
    enum DiscoverTab: String, CaseIterable {
        case forYou = "For You"
        case mostLiked = "Most Liked"
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Main Content
                VStack(spacing: 0) {
                    // Custom Header
                    HStack(alignment: .top) {
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                isSearching = true
                                isSearchFocused = true
                            }
                        }) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 20))
                                .foregroundColor(.white)
                                .frame(width: 44, height: 44)
                                .padding(.top, 2)
                        }
                        
                        Spacer()
                        
                        Text("Discover")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.top, 2)
                        
                        Spacer()
                        
                        // Empty space for symmetry
                        Color.clear
                            .frame(width: 44, height: 44)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)
                    .background(Color.black)
                    
                    // Tab Slider (when not searching)
                    if !isSearching {
                        DiscoverTabSelector(selectedTab: $selectedTab)
                            .padding(.top, 16)
                            .padding(.bottom, 16)
                    }
                    
                    // Content based on selected tab
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            switch selectedTab {
                            case .forYou:
                                ForYouTabView()
                            case .mostLiked:
                                MostLikedTabView()
                            }
                        }
                    }
                    .padding(.top, 16)
                }
                .navigationBarHidden(true)
                
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
                                    .onChange(of: searchText) { _, newValue in
                                        viewModel.searchBeers(query: newValue)
                                    }
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            
                                // Filter Button
                                Button(action: {
                                    showFilter = true
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
                                    ForEach(viewModel.searchResults) { beer in
                                        BeerCardView(beer: beer)
                                    }
                                }
                            }
                        }
                    }
                    .background(Color.black)
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
        }
        .sheet(isPresented: $showFilter) {
            BeerFilterView(
                selectedStyle: $viewModel.selectedStyle,
                isPresented: $showFilter
            )
        }
    }
    
}

struct BeerCardView: View {
    let beer: Beer
    @State private var isNextActive = false
    @State private var showBeerDetail = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Beer Image Placeholder
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
                Text(beer.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text(beer.brewery)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                
                Text(beer.styleAndABV)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isNextActive = true
                    // Add beer to user's profile (simulate adding to Next list)
                    // In a real app, this would save to a database or user preferences
                }
            }) {
                Text(isNextActive ? "Next" : "+Next")
                    .font(.system(size: 12, weight: .medium))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(isNextActive ? Color.red : Color(.systemGray5))
                    .foregroundColor(isNextActive ? .white : .primary)
                    .cornerRadius(6)
            }
            .disabled(isNextActive)
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
        .onTapGesture {
            showBeerDetail = true
        }
        .sheet(isPresented: $showBeerDetail) {
            NavigationView {
                BeerDetailView(beer: beer, isMarkedAsNext: isNextActive)
            }
        }
    }
}

struct DiscoverTabSelector: View {
    @Binding var selectedTab: DiscoverView.DiscoverTab
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(DiscoverView.DiscoverTab.allCases, id: \.self) { tab in
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
        .gesture(
            DragGesture()
                .onEnded { value in
                    let threshold: CGFloat = 50
                    let translation = value.translation.width
                    
                    withAnimation(.easeInOut(duration: 0.2)) {
                        if translation > threshold {
                            // Swipe right - go to previous tab
                            switch selectedTab {
                            case .forYou:
                                selectedTab = .mostLiked
                            case .mostLiked:
                                selectedTab = .forYou
                            }
                        } else if translation < -threshold {
                            // Swipe left - go to next tab
                            switch selectedTab {
                            case .forYou:
                                selectedTab = .mostLiked
                            case .mostLiked:
                                selectedTab = .forYou
                            }
                        }
                    }
                }
        )
    }
}

// MARK: - Tab Content Views

struct ForYouTabView: View {
    @StateObject private var viewModel = DiscoverViewModel()
    
    var body: some View {
        LazyVStack(spacing: 0) {
            ForEach(viewModel.forYouBeers) { beer in
                BeerCardView(beer: beer)
            }
        }
    }
}

struct MostLikedTabView: View {
    @StateObject private var viewModel = DiscoverViewModel()
    
    var body: some View {
        LazyVStack(spacing: 0) {
            ForEach(viewModel.mostLikedBeers) { beer in
                BeerCardView(beer: beer)
            }
        }
    }
}

#Preview {
    DiscoverView()
}
