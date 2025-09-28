import Foundation

// MARK: - Punk API Response Models

struct PunkBeerResponse: Codable {
    let id: Int
    let name: String
    let tagline: String
    let firstBrewed: String
    let description: String
    let imageUrl: String?
    let abv: Double?
    let ibu: Double?
    let targetFg: Double?
    let targetOg: Double?
    let ebc: Double?
    let srm: Double?
    let ph: Double?
    let attenuationLevel: Double?
    let volume: Volume
    let boilVolume: BoilVolume
    let method: Method
    let ingredients: Ingredients
    let foodPairing: [String]
    let brewersTips: String
    let contributedBy: String
    
    enum CodingKeys: String, CodingKey {
        case id, name, tagline, description, abv, ibu, ebc, srm, ph, volume, method, ingredients
        case firstBrewed = "first_brewed"
        case imageUrl = "image_url"
        case targetFg = "target_fg"
        case targetOg = "target_og"
        case attenuationLevel = "attenuation_level"
        case boilVolume = "boil_volume"
        case foodPairing = "food_pairing"
        case brewersTips = "brewers_tips"
        case contributedBy = "contributed_by"
    }
}

struct Volume: Codable {
    let value: Double
    let unit: String
}

struct BoilVolume: Codable {
    let value: Double
    let unit: String
}

struct Method: Codable {
    let mashTemp: [MashTemp]
    let fermentation: Fermentation
    let twist: String?
    
    enum CodingKeys: String, CodingKey {
        case mashTemp = "mash_temp"
        case fermentation, twist
    }
}

struct MashTemp: Codable {
    let temp: Volume
    let duration: Int?
}

struct Fermentation: Codable {
    let temp: Volume
}

struct Ingredients: Codable {
    let malt: [Malt]
    let hops: [Hop]
    let yeast: String
}

struct Malt: Codable {
    let name: String
    let amount: Volume
}

struct Hop: Codable {
    let name: String
    let amount: Volume
    let add: String
    let attribute: String
}

// MARK: - Convert to App Beer Model

extension PunkBeerResponse {
    func toBeer() -> Beer {
        return Beer(
            id: UUID(),
            name: self.name,
            brewery: extractBreweryName(),
            style: self.tagline,
            abv: self.abv ?? 0.0,
            ibu: Int(self.ibu ?? 0),
            color: determineColorFromEBC(self.ebc),
            description: self.description,
            imageUrl: self.imageUrl
        )
    }
    
    private func extractBreweryName() -> String {
        // Punk API doesn't have separate brewery field, so we'll use contributed_by
        // or extract from name if it contains brewery info
        if let contributedBy = contributedBy.components(separatedBy: "<").first {
            return contributedBy.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return "Unknown Brewery"
    }
    
    private func determineColorFromEBC(_ ebc: Double?) -> String {
        guard let ebc = ebc else { return "Unknown" }
        
        switch ebc {
        case 0..<4: return "Pale"
        case 4..<8: return "Golden"
        case 8..<12: return "Amber"
        case 12..<20: return "Copper"
        case 20..<30: return "Brown"
        case 30..<40: return "Dark Brown"
        case 40..<60: return "Black"
        default: return "Very Dark"
        }
    }
}

// MARK: - API Error Types

enum PunkAPIError: Error, LocalizedError {
    case invalidURL
    case noData
    case decodingError
    case networkError(Error)
    case rateLimitExceeded
    case serverError(Int)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received"
        case .decodingError:
            return "Failed to decode response"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .rateLimitExceeded:
            return "Rate limit exceeded. Please try again later."
        case .serverError(let code):
            return "Server error: \(code)"
        }
    }
}
