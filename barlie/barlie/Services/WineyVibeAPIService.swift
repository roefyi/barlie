import Foundation
import SwiftUI

// MARK: - WineyVibe API Response Models
struct WineyVibeBeerResponse: Codable {
    let data: [WineyVibeBeer]?
    let message: String?
    let success: Bool?
}

struct WineyVibeBeer: Codable, Identifiable {
    let id: String?
    let name: String?
    let brewery: String?
    let style: String?
    let abv: Double?
    let ibu: Int?
    let description: String?
    let imageUrl: String?
    let rating: Double?
    let availability: String?
    let price: Double?
    let color: String?
    let bitterness: String?
    let sweetness: String?
    let body: String?
    let carbonation: String?
    let servingTemperature: String?
    let foodPairings: [String]?
    let ingredients: [String]?
    let awards: [String]?
    let seasonality: String?
    let origin: String?
    let year: Int?
    
    enum CodingKeys: String, CodingKey {
        case id, name, brewery, style, abv, ibu, description, rating, availability, price, color
        case bitterness, sweetness, body, carbonation, seasonality, origin, year
        case imageUrl = "image_url"
        case servingTemperature = "serving_temperature"
        case foodPairings = "food_pairings"
        case ingredients, awards
    }
}

// MARK: - WineyVibe API Service
class WineyVibeAPIService: ObservableObject {
    static let shared = WineyVibeAPIService()
    
    private let session = URLSession.shared
    private let baseURL = APIConfig.wineyVibeBaseURL
    
    private init() {}
    
    // MARK: - Generic API Call Method
    private func makeRequest<T: Codable>(
        endpoint: String,
        responseType: T.Type,
        completion: @escaping (Result<T, APIError>) -> Void
    ) {
        guard let url = URL(string: baseURL + endpoint) else {
            completion(.failure(.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = APIConfig.wineyVibeHeaders
        
        session.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(.networkError(error)))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    completion(.failure(.invalidResponse))
                    return
                }
                
                guard 200...299 ~= httpResponse.statusCode else {
                    completion(.failure(.httpError(httpResponse.statusCode)))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(.noData))
                    return
                }
                
                do {
                    let decodedResponse = try JSONDecoder().decode(T.self, from: data)
                    completion(.success(decodedResponse))
                } catch {
                    print("Decoding error: \(error)")
                    print("Raw response: \(String(data: data, encoding: .utf8) ?? "Unable to convert to string")")
                    completion(.failure(.decodingError(error)))
                }
            }
        }.resume()
    }
    
    // MARK: - API Methods
    func fetchBeers(completion: @escaping (Result<WineyVibeBeerResponse, APIError>) -> Void) {
        makeRequest(endpoint: APIConfig.Endpoints.beers, responseType: WineyVibeBeerResponse.self, completion: completion)
    }
    
    func fetchBeerDetails(id: String, completion: @escaping (Result<WineyVibeBeer, APIError>) -> Void) {
        let endpoint = APIConfig.Endpoints.beerDetails.replacingOccurrences(of: "{id}", with: id)
        makeRequest(endpoint: endpoint, responseType: WineyVibeBeer.self, completion: completion)
    }
    
    func searchBeers(query: String, completion: @escaping (Result<WineyVibeBeerResponse, APIError>) -> Void) {
        let endpoint = "\(APIConfig.Endpoints.search)?q=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        makeRequest(endpoint: endpoint, responseType: WineyVibeBeerResponse.self, completion: completion)
    }
}

// MARK: - API Error Types
enum APIError: Error, LocalizedError {
    case invalidURL
    case networkError(Error)
    case invalidResponse
    case httpError(Int)
    case noData
    case decodingError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid response"
        case .httpError(let code):
            return "HTTP error: \(code)"
        case .noData:
            return "No data received"
        case .decodingError(let error):
            return "Decoding error: \(error.localizedDescription)"
        }
    }
}
