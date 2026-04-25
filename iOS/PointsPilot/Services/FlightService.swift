import Foundation

protocol FlightService: AnyObject {
    func searchFlights(
        filter: FlightSearchFilter,
        limit: Int,
        offset: Int
    ) async throws -> SearchResult<Flight>
}

final class FlightServiceImpl: FlightService {
    private let flightRepository: any FlightRepository

    init(flightRepository: any FlightRepository) {
        self.flightRepository = flightRepository
    }

    func searchFlights(
        filter: FlightSearchFilter,
        limit: Int,
        offset: Int
    ) async throws -> SearchResult<Flight> {
        try await flightRepository.fetchFlights(
            filter: filter,
            limit: limit,
            offset: offset
        )
    }
}
