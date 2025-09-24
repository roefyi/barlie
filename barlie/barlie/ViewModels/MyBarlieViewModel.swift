import Foundation
import SwiftUI

class MyBarlieViewModel: ObservableObject {
    @Published var nextBeers: [Beer] = []
    @Published var drankBeers: [Beer] = []
    @Published var customLists: [BeerList] = []
    
    init() {
        loadData()
    }
    
    private func loadData() {
        // Load next beers (beers to try)
        nextBeers = Array(Beer.sampleBeers.prefix(8))
        
        // Load drank beers (beers already tried)
        drankBeers = Array(Beer.sampleBeers.suffix(6))
        
        // Load custom lists
        customLists = [
            BeerList(id: UUID(), name: "Summer Favorites", beerIds: []),
            BeerList(id: UUID(), name: "IPA Collection", beerIds: []),
            BeerList(id: UUID(), name: "Dark Beers", beerIds: [])
        ]
    }
    
    var beerLists: [BeerList] {
        return customLists
    }
}
