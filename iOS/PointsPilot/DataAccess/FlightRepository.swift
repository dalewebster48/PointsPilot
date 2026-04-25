import Foundation

protocol FlightRepository: AnyObject {
    func fetchFlights(
        filter: FlightSearchFilter,
        limit: Int,
        offset: Int
    ) async throws -> SearchResult<Flight>
}
