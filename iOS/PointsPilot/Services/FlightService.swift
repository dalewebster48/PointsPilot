import Foundation

protocol FlightService: AnyObject {
    func searchFlights(
        filter: FlightSearchFilter,
        sort: FlightSort,
        limit: Int,
        offset: Int
    ) async throws -> FlightSearchResult
}

final class FlightServiceImpl: FlightService {
    private let flightRepository: any FlightRepository

    init(flightRepository: any FlightRepository) {
        self.flightRepository = flightRepository
    }

    func searchFlights(
        filter: FlightSearchFilter,
        sort: FlightSort,
        limit: Int,
        offset: Int
    ) async throws -> FlightSearchResult {
        try await flightRepository.fetchFlights(
            filter: filter,
            sort: sort,
            limit: limit,
            offset: offset
        )
    }
}
