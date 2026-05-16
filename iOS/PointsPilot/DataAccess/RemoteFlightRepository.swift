import Foundation

final class RemoteFlightRepository: FlightRepository {
    private let networkClient: any NetworkClient

    init(networkClient: any NetworkClient) {
        self.networkClient = networkClient
    }

    func fetchFlights(
        filter: FlightSearchFilter,
        sort: FlightSort,
        limit: Int,
        offset: Int
    ) async throws -> FlightSearchResult {
        let request = FlightSearchRequest(
            filter: filter,
            sort: sort,
            limit: limit,
            offset: offset
        )
        return try await networkClient.get(url: .flights, query: request)
    }
}

// MARK: - URL Endpoints

private extension URL {
    static var flights: URL { base.appending(path: "flights") }
}

// MARK: - Request

private func commaSeparated(_ values: [String]?) -> String? {
    guard let values, !values.isEmpty else { return nil }
    return values.joined(separator: ",")
}

private struct FlightSearchRequest: Encodable {
    let origin: String?
    let destination: String?
    let originCountry: String?
    let destinationCountry: String?
    let dateFrom: String?
    let dateTo: String?
    let economyCostMin: Int?
    let economyCostMax: Int?
    let economyDeal: Bool?
    let premiumCostMin: Int?
    let premiumCostMax: Int?
    let premiumDeal: Bool?
    let upperCostMin: Int?
    let upperCostMax: Int?
    let upperDeal: Bool?
    let orderBy: String
    let orderDirection: String
    let limit: Int
    let offset: Int

    init(
        filter: FlightSearchFilter,
        sort: FlightSort,
        limit: Int,
        offset: Int
    ) {
        self.origin = commaSeparated(filter.origins)
        self.destination = commaSeparated(filter.destinations)
        self.originCountry = commaSeparated(filter.originCountries)
        self.destinationCountry = commaSeparated(filter.destinationCountries)
        self.dateFrom = filter.dateFrom
        self.dateTo = filter.dateTo
        self.economyCostMin = filter.economyCostMin
        self.economyCostMax = filter.economyCostMax
        self.economyDeal = filter.economyDeal
        self.premiumCostMin = filter.premiumCostMin
        self.premiumCostMax = filter.premiumCostMax
        self.premiumDeal = filter.premiumDeal
        self.upperCostMin = filter.upperCostMin
        self.upperCostMax = filter.upperCostMax
        self.upperDeal = filter.upperDeal
        self.orderBy = sort.field.rawValue
        self.orderDirection = sort.direction.rawValue
        self.limit = limit
        self.offset = offset
    }
}
