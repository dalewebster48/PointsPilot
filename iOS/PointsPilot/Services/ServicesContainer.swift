import Foundation

final class ServicesContainer {
    let flightService: any FlightService
    let airportService: any AirportService

    init(dataAccess: any DataAccessContainer) {
        self.flightService = FlightServiceImpl(
            flightRepository: dataAccess.flightRepository
        )
        self.airportService = AirportServiceImpl(
            airportRepository: dataAccess.airportRepository
        )
    }
}