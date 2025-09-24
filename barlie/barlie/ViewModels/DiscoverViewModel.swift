import Foundation
import SwiftUI

class DiscoverViewModel: ObservableObject {
    @Published var allBeers: [Beer] = Beer.sampleBeers
    @Published var forYouBeers: [Beer] = []
    @Published var mostLikedBeers: [Beer] = []
    @Published var searchResults: [Beer] = []
    
    init() {
        loadBeers()
        setupTabBeers()
    }
    
    private func loadBeers() {
        // In a real app, this would load from a database or API
        // For now, we'll use the sample data
    }
    
    private func setupTabBeers() {
        // For You: Personalized recommendations (mix of different styles)
        forYouBeers = Array(allBeers.shuffled().prefix(8))
        
        // Most Liked: Popular beers (simulate with higher ratings)
        mostLikedBeers = allBeers.sorted { beer1, beer2 in
            // Simulate popularity based on name length and style
            let popularity1 = beer1.name.count + (beer1.style == "IPA" ? 10 : 0)
            let popularity2 = beer2.name.count + (beer2.style == "IPA" ? 10 : 0)
            return popularity1 > popularity2
        }
    }
    
    func searchBeers(query: String) {
        guard !query.isEmpty else {
            searchResults = []
            return
        }
        
        searchResults = allBeers.filter { beer in
            beer.name.localizedCaseInsensitiveContains(query) ||
            beer.brewery.localizedCaseInsensitiveContains(query) ||
            beer.style.localizedCaseInsensitiveContains(query)
        }
    }
    
    func getBeersForTab(_ tab: DiscoverView.DiscoverTab) -> [Beer] {
        switch tab {
        case .forYou:
            return forYouBeers
        case .mostLiked:
            return mostLikedBeers
        }
    }
}
