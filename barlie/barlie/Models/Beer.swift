import Foundation

struct Beer: Identifiable, Codable {
    let id: UUID
    let name: String
    let brewery: String
    let style: String
    let abv: Double
    var imageUrl: String?

    var styleAndABV: String {
        "\(style) • \(String(format: "%.1f", abv))%"
    }

    static let sampleBeers: [Beer] = [
        Beer(id: UUID(), name: "Hazy Jane", brewery: "BrewDog", style: "IPA", abv: 5.0),
        Beer(id: UUID(), name: "Punk IPA", brewery: "BrewDog", style: "IPA", abv: 5.6),
        Beer(id: UUID(), name: "Guinness Draught", brewery: "Guinness", style: "Stout", abv: 4.2),
        Beer(id: UUID(), name: "Stout X", brewery: "Local Brews", style: "Stout", abv: 6.0),
        Beer(id: UUID(), name: "Pilsner Urquell", brewery: "Pilsner Urquell", style: "Pilsner", abv: 4.4),
        Beer(id: UUID(), name: "Budweiser", brewery: "Anheuser-Busch", style: "Lager", abv: 5.0),
        Beer(id: UUID(), name: "Heineken", brewery: "Heineken", style: "Lager", abv: 5.0),
        Beer(id: UUID(), name: "Sierra Nevada Pale Ale", brewery: "Sierra Nevada", style: "Pale Ale", abv: 5.6),
        Beer(id: UUID(), name: "Lagunitas IPA", brewery: "Lagunitas", style: "IPA", abv: 6.2),
        Beer(id: UUID(), name: "Murphy's Irish Stout", brewery: "Murphy's", style: "Stout", abv: 4.0),
        Beer(id: UUID(), name: "Corona Extra", brewery: "Grupo Modelo", style: "Lager", abv: 4.6),
        Beer(id: UUID(), name: "Sam Adams Boston Lager", brewery: "Samuel Adams", style: "Lager", abv: 5.0)
    ]
}

struct Rating: Identifiable, Codable {
    let id: UUID
    let beerId: String
    var rating: Int // 1-5 stars
    var review: String
    var date: Date
}

struct BeerList: Identifiable, Codable {
    let id: UUID
    var name: String
    var beerIds: [String]
}
