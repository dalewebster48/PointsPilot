import Foundation

final class DateSectionViewModel: TripBuilderSectionViewModel {
    private let navigator: any Navigator
    private weak var pickerDelegate: (any TripBuilderDatePickerDelegate)?

    let iconName = "calendar"
    let title = "When?"
    let placeholder = "Travelling anytime"

    private var dateFrom: String?
    private var dateTo: String?

    var summary: String {
        switch (dateFrom, dateTo) {
        case let (from?, to?):
            return "\(from) – \(to)"
        case let (from?, nil):
            return "From \(from)"
        case let (nil, to?):
            return "Until \(to)"
        case (nil, nil):
            return ""
        }
    }

    init(
        navigator: any Navigator,
        pickerDelegate: any TripBuilderDatePickerDelegate
    ) {
        self.navigator = navigator
        self.pickerDelegate = pickerDelegate
    }

    func didTap() {
        guard let pickerDelegate else { return }
        navigator.navigate(.push(.tripBuilderDatePicker(
            delegate: pickerDelegate,
            dateFrom: dateFrom,
            dateTo: dateTo
        )))
    }

    func updateWithFilter(_ filter: FlightSearchFilter) {
        dateFrom = filter.dateFrom
        dateTo = filter.dateTo
    }
}
