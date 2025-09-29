import Foundation

struct Beer: Identifiable, Codable {
    let id: UUID
    let name: String
    let brewery: String
    let style: String
    let abv: Double
    let ibu: Int
    let color: String
    let description: String
    var imageUrl: String?

    var styleAndABV: String {
        "\(style) • \(String(format: "%.1f", abv))%"
    }
    

    static let sampleBeers: [Beer] = [
        Beer(id: UUID(), name: "Hazy Jane", brewery: "BrewDog", style: "IPA", abv: 5.0, ibu: 35, color: "Golden", description: "A refreshing and crisp IPA with a perfect balance of hops and malt. This IPA offers a smooth drinking experience with subtle citrus notes and a clean finish."),
        Beer(id: UUID(), name: "Punk IPA", brewery: "BrewDog", style: "IPA", abv: 5.6, ibu: 45, color: "Amber", description: "Bold and hoppy IPA with tropical fruit flavors and a crisp bitterness. A classic craft beer that delivers on flavor and character."),
        Beer(id: UUID(), name: "Guinness Draught", brewery: "Guinness", style: "Stout", abv: 4.2, ibu: 25, color: "Dark", description: "The world's most famous stout with its signature creamy head and smooth, roasted malt flavor. A true Irish classic."),
        Beer(id: UUID(), name: "Stout X", brewery: "Local Brews", style: "Stout", abv: 6.0, ibu: 40, color: "Black", description: "A robust imperial stout with rich chocolate and coffee notes. Perfect for sipping on a cold evening."),
        Beer(id: UUID(), name: "Pilsner Urquell", brewery: "Pilsner Urquell", style: "Pilsner", abv: 4.4, ibu: 30, color: "Golden", description: "The original pilsner beer with a crisp, clean taste and perfect balance of hops and malt. A true Czech classic."),
        Beer(id: UUID(), name: "Budweiser", brewery: "Anheuser-Busch", style: "Lager", abv: 5.0, ibu: 20, color: "Light", description: "America's most popular beer with a smooth, crisp taste and clean finish. Perfect for any occasion."),
        Beer(id: UUID(), name: "Heineken", brewery: "Heineken", style: "Lager", abv: 5.0, ibu: 19, color: "Light", description: "A premium European lager with a distinctive taste and smooth finish. Known worldwide for its quality and consistency."),
        Beer(id: UUID(), name: "Sierra Nevada Pale Ale", brewery: "Sierra Nevada", style: "Pale Ale", abv: 5.6, ibu: 38, color: "Amber", description: "A hoppy American pale ale with citrus and pine notes. One of the most influential craft beers ever brewed."),
        Beer(id: UUID(), name: "Lagunitas IPA", brewery: "Lagunitas", style: "IPA", abv: 6.2, ibu: 51, color: "Golden", description: "A hop-forward IPA with bold citrus and pine flavors. Brewed with passion and a touch of attitude."),
        Beer(id: UUID(), name: "Murphy's Irish Stout", brewery: "Murphy's", style: "Stout", abv: 4.0, ibu: 22, color: "Dark", description: "A smooth and creamy Irish stout with rich roasted flavors and a velvety texture."),
        Beer(id: UUID(), name: "Corona Extra", brewery: "Grupo Modelo", style: "Lager", abv: 4.6, ibu: 18, color: "Light", description: "A refreshing Mexican lager with a light, crisp taste. Best served with a lime wedge."),
        Beer(id: UUID(), name: "Sam Adams Boston Lager", brewery: "Samuel Adams", style: "Lager", abv: 5.0, ibu: 30, color: "Amber", description: "A rich and complex American lager with caramel and toffee notes. A true Boston classic.")
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
