import SwiftUI

struct PunkAPITestView: View {
    @StateObject private var beerViewModel = BeerViewModel()
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            VStack {
                // Search Bar
                HStack {
                    TextField("Search beers...", text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onSubmit {
                            Task {
                                await beerViewModel.searchBeers(query: searchText)
                            }
                        }
                    
                    Button("Search") {
                        Task {
                            await beerViewModel.searchBeers(query: searchText)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
                
                // Filter Buttons
                HStack(spacing: 12) {
                    Button("Popular") {
                        Task {
                            await beerViewModel.getPopularBeers()
                        }
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Light") {
                        Task {
                            await beerViewModel.getLightBeers()
                        }
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Strong") {
                        Task {
                            await beerViewModel.getStrongBeers()
                        }
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Random") {
                        Task {
                            if let randomBeer = await beerViewModel.getRandomBeer() {
                                beerViewModel.beers = [randomBeer]
                            }
                        }
                    }
                    .buttonStyle(.bordered)
                }
                .padding(.horizontal)
                
                // Content
                if beerViewModel.isLoading {
                    VStack {
                        ProgressView()
                        Text("Loading beers...")
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let errorMessage = beerViewModel.errorMessage {
                    VStack {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundColor(.orange)
                        Text("Error")
                            .font(.headline)
                        Text(errorMessage)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Button("Retry") {
                            Task {
                                await beerViewModel.loadBeers()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if beerViewModel.beers.isEmpty {
                    VStack {
                        Image(systemName: "beer.mug")
                            .font(.largeTitle)
                            .foregroundColor(.secondary)
                        Text("No beers found")
                            .font(.headline)
                        Text("Try searching or use the filter buttons above")
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List(beerViewModel.beers) { beer in
                        BeerTestRowView(beer: beer)
                    }
                    .refreshable {
                        await beerViewModel.refresh()
                    }
                }
            }
            .navigationTitle("Punk API Test")
            .task {
                await beerViewModel.loadBeers()
            }
        }
    }
}

struct BeerTestRowView: View {
    let beer: Beer
    
    var body: some View {
        HStack(spacing: 12) {
            // Beer Image
            AsyncImage(url: URL(string: beer.displayImageUrl ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } placeholder: {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.3))
                    .overlay(
                        Image(systemName: "beer.mug")
                            .foregroundColor(.gray)
                    )
            }
            .frame(width: 60, height: 60)
            .cornerRadius(8)
            
            // Beer Info
            VStack(alignment: .leading, spacing: 4) {
                Text(beer.name)
                    .font(.headline)
                    .lineLimit(1)
                
                Text(beer.brewery)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                HStack {
                    Text(beer.style)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(4)
                    
                    Text(beer.abvString)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.green.opacity(0.2))
                        .cornerRadius(4)
                    
                    if beer.ibu > 0 {
                        Text(beer.ibuString)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.orange.opacity(0.2))
                            .cornerRadius(4)
                    }
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    PunkAPITestView()
}
