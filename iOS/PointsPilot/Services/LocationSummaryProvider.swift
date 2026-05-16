import UIKit

protocol LocationSummaryProvider: AnyObject {
    func summary(
        for mode: TripBuilderLocationPickerMode,
        countries: [String],
        airports: [Airport]
    ) -> NSAttributedString
}

final class LocationSummaryProviderImpl: LocationSummaryProvider {
    func summary(
        for mode: TripBuilderLocationPickerMode,
        countries: [String],
        airports: [Airport]
    ) -> NSAttributedString {
        let displayedCountries: [String]
        if airports.isEmpty {
            displayedCountries = countries.sorted()
        } else {
            displayedCountries = Array(Set(airports.map { $0.country })).sorted()
        }

        let result = NSMutableAttributedString()

        if airports.isEmpty {
            if displayedCountries.isEmpty {
                switch mode {
                case .origin: result.append(plain("Flying out of anywhere"))
                case .destination: result.append(plain("Flying to anywhere"))
                }
                return result
            }
            switch mode {
            case .origin:
                result.append(plain("Flying out of "))
                result.append(formatList(displayedCountries))
                result.append(plain(" from anywhere"))
            case .destination:
                result.append(plain("Flying to anywhere in "))
                result.append(formatList(displayedCountries))
            }
            return result
        }

        switch mode {
        case .origin:
            result.append(plain("Flying out of "))
            result.append(formatList(displayedCountries))
            result.append(plain(" from "))
            result.append(formatList(airports.map { $0.code }))
        case .destination:
            result.append(plain("Flying to "))
            result.append(formatList(displayedCountries))
            result.append(plain(" arriving at "))
            result.append(formatList(airports.map { $0.code }))
        }
        return result
    }

    private func plain(_ string: String) -> NSAttributedString {
        NSAttributedString(string: string)
    }

    private func underlined(_ string: String) -> NSAttributedString {
        NSAttributedString(
            string: string,
            attributes: [
                .underlineStyle: NSUnderlineStyle.single.rawValue,
                .underlineColor: Theme.primaryAccent,
                .foregroundColor: Theme.primaryAccent
            ]
        )
    }

    private func formatList(_ items: [String]) -> NSAttributedString {
        let result = NSMutableAttributedString()
        for (index, item) in items.enumerated() {
            if index == items.count - 1, index > 0 {
                result.append(plain(" or "))
            } else if index > 0 {
                result.append(plain(", "))
            }
            result.append(underlined(item))
        }
        return result
    }
}
