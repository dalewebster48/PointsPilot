import Foundation

protocol AirportRepository: AnyObject {
    func fetchAirports(
        filter: AirportSearchFilter,
        limit: Int,
        offset: Int
    ) async throws -> [Airport]
}
