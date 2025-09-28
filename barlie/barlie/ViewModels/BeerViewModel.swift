import Foundation
import SwiftUI

@MainActor
class BeerViewModel: ObservableObject {
    @Published var beers: [Beer] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var hasMoreBeers = true
    
    private let punkAPIService = PunkAPIService()
    private var currentPage = 1
    private let pageSize = 25
    
    // MARK: - Public Methods
    
    /// Load initial beers
    func loadBeers() async {
        await loadBeers(reset: true)
    }
    
    /// Load more beers (pagination)
    func loadMoreBeers() async {
        guard !isLoading && hasMoreBeers else { return }
        await loadBeers(reset: false)
    }
    
    /// Search beers by name
    func searchBeers(query: String) async {
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            await loadBeers()
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let searchResults = try await punkAPIService.searchBeers(query: query)
            beers = searchResults
            hasMoreBeers = false // Search results don't use pagination
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    /// Get random beer
    func getRandomBeer() async -> Beer? {
        do {
            return try await punkAPIService.getRandomBeer()
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }
    
    /// Filter beers by ABV range
    func filterBeersByABV(minABV: Double? = nil, maxABV: Double? = nil) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let filteredBeers = try await punkAPIService.filterBeersByABV(
                minABV: minABV,
                maxABV: maxABV,
                page: 1,
                perPage: pageSize
            )
            beers = filteredBeers
            hasMoreBeers = false // Filtered results don't use pagination
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    /// Get popular beers
    func getPopularBeers() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let popularBeers = try await punkAPIService.getPopularBeers()
            beers = popularBeers
            hasMoreBeers = false
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    /// Get light beers
    func getLightBeers() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let lightBeers = try await punkAPIService.getLightBeers()
            beers = lightBeers
            hasMoreBeers = false
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    /// Get strong beers
    func getStrongBeers() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let strongBeers = try await punkAPIService.getStrongBeers()
            beers = strongBeers
            hasMoreBeers = false
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    /// Clear error message
    func clearError() {
        errorMessage = nil
    }
    
    // MARK: - Private Methods
    
    private func loadBeers(reset: Bool) async {
        if reset {
            currentPage = 1
            hasMoreBeers = true
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let newBeers = try await punkAPIService.fetchBeers(
                page: currentPage,
                perPage: pageSize
            )
            
            if reset {
                beers = newBeers
            } else {
                beers.append(contentsOf: newBeers)
            }
            
            // Check if we have more beers to load
            hasMoreBeers = newBeers.count == pageSize
            currentPage += 1
            
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}

// MARK: - Convenience Methods

extension BeerViewModel {
    /// Get beer by ID
    func getBeer(by id: Int) -> Beer? {
        return beers.first { beer in
            // Since we're using UUID for our Beer model, we'll need to find by name
            // In a real app, you'd want to store the original Punk API ID
            return beer.name.contains("\(id)")
        }
    }
    
    /// Refresh current data
    func refresh() async {
        await loadBeers(reset: true)
    }
    
    /// Check if we can load more beers
    var canLoadMore: Bool {
        return !isLoading && hasMoreBeers
    }
}
