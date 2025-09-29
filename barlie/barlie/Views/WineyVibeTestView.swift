import SwiftUI

struct WineyVibeTestView: View {
    @StateObject private var apiService = WineyVibeAPIService.shared
    @State private var beers: [WineyVibeBeer] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var rawResponse: String = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Test Buttons
                VStack(spacing: 12) {
                    Button("Test Fetch Beers") {
                        testFetchBeers()
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button("Test Search Beers") {
                        testSearchBeers()
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Test Beer Details") {
                        testBeerDetails()
                    }
                    .buttonStyle(.bordered)
                }
                .padding()
                
                // Loading State
                if isLoading {
                    ProgressView("Testing API...")
                        .padding()
                }
                
                // Error Message
                if let errorMessage = errorMessage {
                    Text("Error: \(errorMessage)")
                        .foregroundColor(.red)
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(8)
                }
                
                // Raw Response
                if !rawResponse.isEmpty {
                    ScrollView {
                        Text("Raw API Response:")
                            .font(.headline)
                            .padding(.top)
                        
                        Text(rawResponse)
                            .font(.system(.caption, design: .monospaced))
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                    }
                }
                
                // Beer List
                if !beers.isEmpty {
                    List(beers.prefix(5)) { beer in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(beer.name ?? "Unknown Beer")
                                .font(.headline)
                            Text(beer.brewery ?? "Unknown Brewery")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text("ABV: \(beer.abv?.description ?? "N/A")%")
                                .font(.caption)
                        }
                    }
                }
                
                Spacer()
            }
            .navigationTitle("WineyVibe API Test")
        }
    }
    
    private func testFetchBeers() {
        isLoading = true
        errorMessage = nil
        rawResponse = ""
        
        apiService.fetchBeers { result in
            isLoading = false
            
            switch result {
            case .success(let response):
                self.beers = response.data ?? []
                self.rawResponse = "Success! Found \(self.beers.count) beers"
            case .failure(let error):
                self.errorMessage = error.localizedDescription
                self.rawResponse = "Error: \(error.localizedDescription)"
            }
        }
    }
    
    private func testSearchBeers() {
        isLoading = true
        errorMessage = nil
        rawResponse = ""
        
        apiService.searchBeers(query: "IPA") { result in
            isLoading = false
            
            switch result {
            case .success(let response):
                self.beers = response.data ?? []
                self.rawResponse = "Search Success! Found \(self.beers.count) IPA beers"
            case .failure(let error):
                self.errorMessage = error.localizedDescription
                self.rawResponse = "Search Error: \(error.localizedDescription)"
            }
        }
    }
    
    private func testBeerDetails() {
        isLoading = true
        errorMessage = nil
        rawResponse = ""
        
        // Test with a sample beer ID (we'll need to get a real one from the API)
        apiService.fetchBeerDetails(id: "1") { result in
            isLoading = false
            
            switch result {
            case .success(let beer):
                self.beers = [beer]
                self.rawResponse = "Beer Details Success! Found: \(beer.name ?? "Unknown")"
            case .failure(let error):
                self.errorMessage = error.localizedDescription
                self.rawResponse = "Beer Details Error: \(error.localizedDescription)"
            }
        }
    }
}

#Preview {
    WineyVibeTestView()
}
