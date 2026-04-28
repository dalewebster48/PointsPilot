import Foundation

final class RemoteAirportRepository: AirportRepository {
    private let networkClient: any NetworkClient

    init(networkClient: any NetworkClient) {
        self.networkClient = networkClient
    }

    func fetchAirports(
        filter: AirportSearchFilter,
        limit: Int,
        offset: Int
    ) async throws -> [Airport] {
        let request = AirportSearchRequest(filter: filter, limit: limit, offset: offset)
        let response: SearchResult<Airport> = try await networkClient.get(url: .airports, query: request)
        return response.data
    }
}

// MARK: - URL Endpoints

private extension URL {
    static var airports: URL { base.appending(path: "airports") }
}

// MARK: - Request

private struct AirportSearchRequest: Encodable {
    let name: String?
    let country: String?
    let limit: Int
    let offset: Int

    init(
        filter: AirportSearchFilter,
        limit: Int,
        offset: Int
    ) {
        self.name = filter.name
        self.country = filter.country
        self.limit = limit
        self.offset = offset
    }
}
