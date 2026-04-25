import Foundation

struct AirportRef: Decodable, Equatable {
    let id: String
    let name: String
    let country: String
}

struct Flight: Decodable, Identifiable, Equatable {
    let id: Int
    let date: String
    let origin: AirportRef
    let destination: AirportRef
    let economyCost: Int
    let economyDeal: Bool
    let premiumCost: Int
    let premiumDeal: Bool
    let upperCost: Int
    let upperDeal: Bool
}
