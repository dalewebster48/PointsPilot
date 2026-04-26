import Foundation

struct FlightSearchFilter: Equatable {
    var origins: [String]?
    var destinations: [String]?
    var originCountries: [String]?
    var destinationCountries: [String]?
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

    mutating func setOrigins(
        countries: [String],
        airports: [Airport]
    ) {
        originCountries = countries.isEmpty ? nil : countries
        origins = airports.isEmpty ? nil : airports.map { $0.code }
    }

    mutating func setDestinations(
        countries: [String],
        airports: [Airport]
    ) {
        destinationCountries = countries.isEmpty ? nil : countries
        destinations = airports.isEmpty ? nil : airports.map { $0.code }
    }

    mutating func setDates(
        from: String?,
        to: String?
    ) {
        dateFrom = from
        dateTo = to
    }

    mutating func setClass(
        _ seatClass: SeatClass?,
        dealsOnly: Bool,
        maxCost: Int?
    ) {
        economyCostMin = nil
        economyCostMax = nil
        economyDeal = nil
        premiumCostMin = nil
        premiumCostMax = nil
        premiumDeal = nil
        upperCostMin = nil
        upperCostMax = nil
        upperDeal = nil

        guard let seatClass else { return }

        switch seatClass {
        case .economy:
            if dealsOnly { economyDeal = true }
            if !dealsOnly { economyCostMax = maxCost }
        case .premium:
            if dealsOnly { premiumDeal = true }
            if !dealsOnly { premiumCostMax = maxCost }
        case .upper:
            if dealsOnly { upperDeal = true }
            if !dealsOnly { upperCostMax = maxCost }
        }
    }
}
