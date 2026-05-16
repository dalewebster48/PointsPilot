import Foundation

struct CabinResult {
    let cost: String
    let barFraction: CGFloat
    let isDeal: Bool

    init(
        rawCost: Int,
        isDeal: Bool,
        max: Int
    ) {
        self.cost = CabinResult.formatPoints(rawCost)
        self.barFraction = CabinResult.barFraction(cost: rawCost, max: max)
        self.isDeal = isDeal
    }

    private static func formatPoints(_ cost: Int) -> String {
        if cost == 0 { return "—" }
        if cost >= 1000 { return "\(cost / 1000)k" }
        return "\(cost)"
    }

    private static func barFraction(cost: Int, max: Int) -> CGFloat {
        guard cost > 0, max > 0 else { return 0 }
        return CGFloat(cost) / CGFloat(max)
    }
}

protocol FlightResultCellViewModelProtocol: AnyObject {
    var originCode: String { get }
    var destinationCode: String { get }
    var dayOfWeek: String { get }
    var dateText: String { get }
    var economy: CabinResult { get }
    var premium: CabinResult { get }
    var upper: CabinResult { get }
    var sortField: FlightSort.Field { get }
}

protocol FlightResultCellViewModelFactory {
    func makeFlightResultCellViewModel(
        flight: Flight,
        sort: FlightSort,
        maxEconomy: Int,
        maxPremium: Int,
        maxUpper: Int
    ) -> any FlightResultCellViewModelProtocol
}

final class FlightResultCellViewModel: FlightResultCellViewModelProtocol {
    let originCode: String
    let destinationCode: String
    let dayOfWeek: String
    let dateText: String
    let economy: CabinResult
    let premium: CabinResult
    let upper: CabinResult
    let sortField: FlightSort.Field

    init(
        flight: Flight,
        sort: FlightSort,
        maxEconomy: Int,
        maxPremium: Int,
        maxUpper: Int
    ) {
        self.originCode = flight.origin.id
        self.destinationCode = flight.destination.id
        self.sortField = sort.field

        let date = DateFormatter.yearMonthDay.date(from: flight.date)
        self.dayOfWeek = date.map { DateFormatter.shortDayOfWeek.string(from: $0).uppercased() } ?? ""
        self.dateText = date.map { DateFormatter.dayMonth.string(from: $0) } ?? flight.date

        self.economy = CabinResult(
            rawCost: flight.economyCost,
            isDeal: flight.economyDeal,
            max: maxEconomy
        )
        self.premium = CabinResult(
            rawCost: flight.premiumCost,
            isDeal: flight.premiumDeal,
            max: maxPremium
        )
        self.upper = CabinResult(
            rawCost: flight.upperCost,
            isDeal: flight.upperDeal,
            max: maxUpper
        )
    }
}
