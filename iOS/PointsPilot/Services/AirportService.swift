import Foundation

protocol AirportService: AnyObject {
    func searchAirports(
        filter: AirportSearchFilter,
        limit: Int,
        offset: Int
    ) async throws -> [Airport]
}

final class AirportServiceImpl: AirportService {
    private let airportRepository: any AirportRepository

    init(airportRepository: any AirportRepository) {
        self.airportRepository = airportRepository
    }

    func searchAirports(
        filter: AirportSearchFilter,
        limit: Int,
        offset: Int
    ) async throws -> [Airport] {
        try await airportRepository.fetchAirports(
            filter: filter,
            limit: limit,
            offset: offset
        )
    }
}
