import Foundation

struct FlightSearchFilter: Equatable {
    var origin: String?
    var destination: String?
    var originCountry: String?
    var destinationCountry: String?
    var dateFrom: String?
    var dateTo: String?
    var economyCostMin: Int?
    var economyCostMax: Int?
    var economyDeal: Bool?
    var premiumCostMin: Int?
    var premiumCostMax: Int?
    var premiumDeal: Bool?
    var upperCostMin: Int?
    var upperCostMax: Int?
    var upperDeal: Bool?
    var orderBy: String?

    static let empty = FlightSearchFilter()

    var isEmpty: Bool { self == .empty }
}
