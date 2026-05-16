import Foundation

protocol FlightRepository: AnyObject {
    func fetchFlights(
        filter: FlightSearchFilter,
        sort: FlightSort,
        limit: Int,
        offset: Int
    ) async throws -> FlightSearchResult
}
