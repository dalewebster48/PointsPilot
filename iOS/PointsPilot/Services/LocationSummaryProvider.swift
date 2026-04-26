import Foundation

protocol LocationSummaryProvider: AnyObject {
    func summary(
        for mode: TripBuilderLocationPickerMode,
        countries: [String],
        airports: [Airport]
    ) -> String
}

final class LocationSummaryProviderImpl: LocationSummaryProvider {
    func summary(
        for mode: TripBuilderLocationPickerMode,
        countries: [String],
        airports: [Airport]
    ) -> String {
        let displayedCountries: [String]
        if airports.isEmpty {
            displayedCountries = countries.sorted()
        } else {
            displayedCountries = Array(Set(airports.map { $0.country })).sorted()
        }

        let leadIn: String
        switch mode {
        case .origin: leadIn = "Flying out of"
        case .destination: leadIn = "Flying to"
        }

        if airports.isEmpty {
            if displayedCountries.isEmpty {
                return "\(leadIn) anywhere"
            }
            let countryList = formatList(displayedCountries)
            switch mode {
            case .origin: return "Flying out of anywhere from \(countryList)"
            case .destination: return "Flying to anywhere in \(countryList)"
            }
        }

        let airportList = formatList(airports.map { $0.code })
        let countryList = formatList(displayedCountries)
        switch mode {
        case .origin: return "Flying out of \(countryList) from \(airportList)"
        case .destination: return "Flying to \(countryList) arriving at \(airportList)"
        }
    }

    private func formatList(_ items: [String]) -> String {
        switch items.count {
        case 0: return ""
        case 1: return items[0]
        case 2: return "\(items[0]) or \(items[1])"
        default:
            let head = items.dropLast().joined(separator: ", ")
            return "\(head) or \(items.last!)"
        }
    }
}
