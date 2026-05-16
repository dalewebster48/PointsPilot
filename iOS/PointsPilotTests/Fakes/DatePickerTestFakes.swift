import Foundation
@testable import PointsPilot

final class DatePickerPanelDelegateFake: DatePickerPanelDelegate {
    struct Recorded {
        let source: any DatePickerPanelViewModel
        let range: DayRange
    }

    var recorded: [Recorded] = []

    func panel(
        _ source: any DatePickerPanelViewModel,
        didUpdate range: DayRange
    ) {
        recorded.append(Recorded(source: source, range: range))
    }
}
