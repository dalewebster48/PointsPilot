import Foundation

final class AppDataAccessContainer: DataAccessContainer {
    let flightRepository: any FlightRepository
    let airportRepository: any AirportRepository

    init(networkClient: any NetworkClient) {
        self.flightRepository = RemoteFlightRepository(networkClient: networkClient)
        self.airportRepository = RemoteAirportRepository(networkClient: networkClient)
    }
}
