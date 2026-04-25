import Foundation

protocol DataAccessContainer: AnyObject {
    var flightRepository: any FlightRepository { get }
    var airportRepository: any AirportRepository { get }
}