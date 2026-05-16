import Foundation

struct FlightSearchResult: Decodable {
    let data: [Flight]
    let total: Int
    let maxEconomy: Int
    let maxPremium: Int
    let maxUpper: Int
}
