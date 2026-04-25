import Foundation

final class RemoteFlightRepository: FlightRepository {
    private let networkClient: any NetworkClient

    init(networkClient: any NetworkClient) {
        self.networkClient = networkClient
    }

    func fetchFlights(
        filter: FlightSearchFilter,
        limit: Int,
        offset: Int
    ) async throws -> SearchResult<Flight> {
        let request = FlightSearchRequest(filter: filter, limit: limit, offset: offset)
        return try await networkClient.get(url: .flights, query: request)
    }
}

// MARK: - URL Endpoints

private extension URL {
    static var serverBase: URL { URL(string: "http://localhost:4000")! }
    static var flights: URL { serverBase.appending(path: "flights") }
}

// MARK: - Request

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
    let orderBy: String?
    let limit: Int
    let offset: Int

    init(
        filter: FlightSearchFilter,
        limit: Int,
        offset: Int
    ) {
        self.origin = filter.origin
        self.destination = filter.destination
        self.originCountry = filter.originCountry
        self.destinationCountry = filter.destinationCountry
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
        self.orderBy = filter.orderBy
        self.limit = limit
        self.offset = offset
    }
}
