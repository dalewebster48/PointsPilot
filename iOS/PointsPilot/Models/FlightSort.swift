import Foundation

struct FlightSort: Equatable {
    enum Field: String, CaseIterable {
        case date
        case economy
        case premium
        case upper

        var label: String {
            switch self {
            case .date: return "Date"
            case .economy: return "Economy"
            case .premium: return "Premium"
            case .upper: return "Upper"
            }
        }
    }

    enum Direction: String {
        case asc
        case desc

        var toggled: Direction {
            self == .asc ? .desc : .asc
        }

        var arrow: String {
            self == .asc ? "↑" : "↓"
        }
    }

    var field: Field
    var direction: Direction

    static let initial = FlightSort(field: .date, direction: .asc)
}
