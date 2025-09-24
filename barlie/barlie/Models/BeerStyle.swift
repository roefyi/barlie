import Foundation

enum BeerStyle: String, CaseIterable, Identifiable {
    case all = "All"
    case ipa = "IPA"
    case lager = "Lager"
    case pilsner = "Pilsner"
    case stout = "Stout"
    case porter = "Porter"
    case wheat = "Wheat Beer"
    case paleAle = "Pale Ale"
    case amber = "Amber Ale"
    case brown = "Brown Ale"
    case blonde = "Blonde Ale"
    case saison = "Saison"
    case sour = "Sour"
    case belgian = "Belgian"
    case bock = "Bock"
    case doppelbock = "Doppelbock"
    case hefeweizen = "Hefeweizen"
    case kolsch = "Kölsch"
    case marzen = "Märzen"
    case oktoberfest = "Oktoberfest"
    case pilsnerUrquell = "Pilsner Urquell"
    
    var id: String { rawValue }
    
    static var popularStyles: [BeerStyle] {
        [.all, .ipa, .lager, .pilsner, .stout, .paleAle, .wheat, .amber]
    }
    
    static var allStyles: [BeerStyle] {
        Array(BeerStyle.allCases)
    }
}
