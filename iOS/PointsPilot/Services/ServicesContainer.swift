import Foundation

final class ServicesContainer {
    private let dataAccess: any DataAccessContainer

    init(dataAccess: any DataAccessContainer) {
        self.dataAccess = dataAccess
    }
}