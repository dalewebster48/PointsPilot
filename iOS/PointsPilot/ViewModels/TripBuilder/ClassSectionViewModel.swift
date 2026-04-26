import Foundation

final class ClassSectionViewModel: TripBuilderSectionViewModel {
    private let navigator: any Navigator
    private weak var pickerDelegate: (any TripBuilderClassPickerDelegate)?

    let iconName = "seat.airdrop"
    let title = "How?"
    let placeholder = "Any way possible"

    private var seatClass: SeatClass?
    private var dealsOnly = false
    private var maxCost: Int?

    var summary: String {
        guard let seatClass else { return "" }
        var parts = [seatClass.rawValue.capitalized]
        if dealsOnly {
            parts.append("deals only")
        } else if let maxCost {
            parts.append("max \(maxCost) pts")
        }
        return parts.joined(separator: ", ")
    }

    init(
        navigator: any Navigator,
        pickerDelegate: any TripBuilderClassPickerDelegate
    ) {
        self.navigator = navigator
        self.pickerDelegate = pickerDelegate
    }

    func didTap() {
        guard let pickerDelegate else { return }
        navigator.navigate(.push(.tripBuilderClassPicker(
            delegate: pickerDelegate,
            seatClass: seatClass,
            dealsOnly: dealsOnly,
            maxCost: maxCost
        )))
    }

    func updateWithFilter(_ filter: FlightSearchFilter) {
        if filter.economyDeal == true {
            seatClass = .economy
            dealsOnly = true
            maxCost = nil
        } else if filter.premiumDeal == true {
            seatClass = .premium
            dealsOnly = true
            maxCost = nil
        } else if filter.upperDeal == true {
            seatClass = .upper
            dealsOnly = true
            maxCost = nil
        } else if let max = filter.economyCostMax {
            seatClass = .economy
            dealsOnly = false
            maxCost = max
        } else if let max = filter.premiumCostMax {
            seatClass = .premium
            dealsOnly = false
            maxCost = max
        } else if let max = filter.upperCostMax {
            seatClass = .upper
            dealsOnly = false
            maxCost = max
        } else {
            seatClass = nil
            dealsOnly = false
            maxCost = nil
        }
    }
}
