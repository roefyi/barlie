import Foundation

class PunkAPIService: ObservableObject {
    private let baseURL = "https://api.punkapi.com/v2"
    private let session = URLSession.shared
    
    // Rate limiting
    private var requestCount = 0
    private let maxRequestsPerHour = 3600
    private var lastResetTime = Date()
    
    // MARK: - Public Methods
    
    /// Fetch all beers with pagination
    func fetchBeers(page: Int = 1, perPage: Int = 25) async throws -> [Beer] {
        let urlString = "\(baseURL)/beers?page=\(page)&per_page=\(perPage)"
        let punkBeers = try await performRequest(urlString: urlString)
        return punkBeers.map { $0.toBeer() }
    }
    
    /// Search beers by name
    func searchBeers(query: String, page: Int = 1, perPage: Int = 25) async throws -> [Beer] {
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "\(baseURL)/beers?beer_name=\(encodedQuery)&page=\(page)&per_page=\(perPage)"
        let punkBeers = try await performRequest(urlString: urlString)
        return punkBeers.map { $0.toBeer() }
    }
    
    /// Get beer by ID
    func getBeer(id: Int) async throws -> Beer? {
        let urlString = "\(baseURL)/beers/\(id)"
        let punkBeers = try await performRequest(urlString: urlString)
        return punkBeers.first?.toBeer()
    }
    
    /// Get random beer
    func getRandomBeer() async throws -> Beer? {
        let urlString = "\(baseURL)/beers/random"
        let punkBeers = try await performRequest(urlString: urlString)
        return punkBeers.first?.toBeer()
    }
    
    /// Filter beers by ABV range
    func filterBeersByABV(minABV: Double? = nil, maxABV: Double? = nil, page: Int = 1, perPage: Int = 25) async throws -> [Beer] {
        var urlString = "\(baseURL)/beers?page=\(page)&per_page=\(perPage)"
        
        if let minABV = minABV {
            urlString += "&abv_gt=\(minABV)"
        }
        if let maxABV = maxABV {
            urlString += "&abv_lt=\(maxABV)"
        }
        
        let punkBeers = try await performRequest(urlString: urlString)
        return punkBeers.map { $0.toBeer() }
    }
    
    /// Filter beers by IBU range
    func filterBeersByIBU(minIBU: Double? = nil, maxIBU: Double? = nil, page: Int = 1, perPage: Int = 25) async throws -> [Beer] {
        var urlString = "\(baseURL)/beers?page=\(page)&per_page=\(perPage)"
        
        if let minIBU = minIBU {
            urlString += "&ibu_gt=\(minIBU)"
        }
        if let maxIBU = maxIBU {
            urlString += "&ibu_lt=\(maxIBU)"
        }
        
        let punkBeers = try await performRequest(urlString: urlString)
        return punkBeers.map { $0.toBeer() }
    }
    
    /// Filter beers by EBC (color) range
    func filterBeersByEBC(minEBC: Double? = nil, maxEBC: Double? = nil, page: Int = 1, perPage: Int = 25) async throws -> [Beer] {
        var urlString = "\(baseURL)/beers?page=\(page)&per_page=\(perPage)"
        
        if let minEBC = minEBC {
            urlString += "&ebc_gt=\(minEBC)"
        }
        if let maxEBC = maxEBC {
            urlString += "&ebc_lt=\(maxEBC)"
        }
        
        let punkBeers = try await performRequest(urlString: urlString)
        return punkBeers.map { $0.toBeer() }
    }
    
    /// Get beers brewed before a specific date
    func getBeersBrewedBefore(date: String, page: Int = 1, perPage: Int = 25) async throws -> [Beer] {
        let urlString = "\(baseURL)/beers?brewed_before=\(date)&page=\(page)&per_page=\(perPage)"
        let punkBeers = try await performRequest(urlString: urlString)
        return punkBeers.map { $0.toBeer() }
    }
    
    /// Get beers brewed after a specific date
    func getBeersBrewedAfter(date: String, page: Int = 1, perPage: Int = 25) async throws -> [Beer] {
        let urlString = "\(baseURL)/beers?brewed_after=\(date)&page=\(page)&per_page=\(perPage)"
        let punkBeers = try await performRequest(urlString: urlString)
        return punkBeers.map { $0.toBeer() }
    }
    
    // MARK: - Private Methods
    
    private func performRequest(urlString: String) async throws -> [PunkBeerResponse] {
        // Check rate limiting
        try checkRateLimit()
        
        guard let url = URL(string: urlString) else {
            throw PunkAPIError.invalidURL
        }
        
        do {
            let (data, response) = try await session.data(from: url)
            
            // Check HTTP response
            if let httpResponse = response as? HTTPURLResponse {
                switch httpResponse.statusCode {
                case 200...299:
                    break // Success
                case 429:
                    throw PunkAPIError.rateLimitExceeded
                case 400...499:
                    throw PunkAPIError.serverError(httpResponse.statusCode)
                case 500...599:
                    throw PunkAPIError.serverError(httpResponse.statusCode)
                default:
                    throw PunkAPIError.serverError(httpResponse.statusCode)
                }
            }
            
            // Decode response
            let punkBeers = try JSONDecoder().decode([PunkBeerResponse].self, from: data)
            
            // Update rate limiting
            requestCount += 1
            
            return punkBeers
            
        } catch let error as PunkAPIError {
            throw error
        } catch {
            throw PunkAPIError.networkError(error)
        }
    }
    
    private func checkRateLimit() throws {
        // Reset counter if an hour has passed
        if Date().timeIntervalSince(lastResetTime) >= 3600 {
            requestCount = 0
            lastResetTime = Date()
        }
        
        // Check if we've exceeded the rate limit
        if requestCount >= maxRequestsPerHour {
            throw PunkAPIError.rateLimitExceeded
        }
    }
}

// MARK: - Convenience Extensions

extension PunkAPIService {
    /// Get popular beers (high ABV, well-known styles)
    func getPopularBeers() async throws -> [Beer] {
        // Get a mix of different beer types
        async let ipas = filterBeersByABV(minABV: 5.0, maxABV: 7.0, perPage: 10)
        async let stouts = filterBeersByABV(minABV: 6.0, maxABV: 10.0, perPage: 10)
        async let lagers = filterBeersByABV(minABV: 4.0, maxABV: 6.0, perPage: 5)
        
        let results = try await [ipas, stouts, lagers]
        return Array(results.flatMap { $0 }.shuffled().prefix(20))
    }
    
    /// Get light beers (low ABV)
    func getLightBeers() async throws -> [Beer] {
        return try await filterBeersByABV(minABV: 0.0, maxABV: 4.5, perPage: 25)
    }
    
    /// Get strong beers (high ABV)
    func getStrongBeers() async throws -> [Beer] {
        return try await filterBeersByABV(minABV: 7.0, maxABV: 15.0, perPage: 25)
    }
}
