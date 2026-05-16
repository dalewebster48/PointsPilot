import Foundation

final class DateSectionViewModel: TripBuilderSectionViewModel {
    private let navigator: any Navigator
    private let summaryProvider: any DateSummaryProvider
    private weak var pickerDelegate: (any TripBuilderDatePickerDelegate)?

    let iconName = "calendar"
    let title = "When?"
    let placeholder = "Travelling anytime"

    private var dateFrom: String?
    private var dateTo: String?

    var summary: String {
        summaryProvider.summary(
            from: dateFrom.flatMap { DateFormatter.yearMonthDay.date(from: $0) },
            to: dateTo.flatMap { DateFormatter.yearMonthDay.date(from: $0) }
        ).string
    }

    init(
        navigator: any Navigator,
        summaryProvider: any DateSummaryProvider,
        pickerDelegate: any TripBuilderDatePickerDelegate
    ) {
        self.navigator = navigator
        self.summaryProvider = summaryProvider
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
