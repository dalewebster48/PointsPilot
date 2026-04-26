import Foundation

enum DatePickerMode: Int {
    case specificDates = 0
    case byMonth = 1
    case flexibleRange = 2
}

protocol TripBuilderDatePickerDelegate: AnyObject {
    func didUpdateDateSelection(
        dateFrom: String?,
        dateTo: String?
    )
}

protocol TripBuilderDatePickerViewModelProtocol: AnyObject {
    var mode: DatePickerMode { get }
    var dateFrom: Date? { get }
    var dateTo: Date? { get }
    var selectedMonths: Set<Int> { get }
    var rangeStartDate: Date? { get }
    var rangeEndDate: Date? { get }

    var viewDelegate: (any TripBuilderDatePickerViewModelViewDelegate)? { get set }

    func didSelectMode(_ mode: DatePickerMode)
    func didChangeDateFrom(_ date: Date)
    func didChangeDateTo(_ date: Date)
    func didToggleMonth(_ month: Int)
    func didChangeRangeStart(_ date: Date)
    func didChangeRangeEnd(_ date: Date)
    func didTapDone()
}

protocol TripBuilderDatePickerViewModelViewDelegate: AnyObject {
    func bind(viewModel: any TripBuilderDatePickerViewModelProtocol)
}

final class TripBuilderDatePickerViewModel: TripBuilderDatePickerViewModelProtocol {
    private weak var pickerDelegate: (any TripBuilderDatePickerDelegate)?
    private let navigator: Navigator

    var mode: DatePickerMode = .specificDates { didSet { bind() } }
    var dateFrom: Date? { didSet { bind() } }
    var dateTo: Date? { didSet { bind() } }
    var selectedMonths: Set<Int> = [] { didSet { bind() } }
    var rangeStartDate: Date? { didSet { bind() } }
    var rangeEndDate: Date? { didSet { bind() } }

    weak var viewDelegate: (any TripBuilderDatePickerViewModelViewDelegate)? {
        didSet { bind() }
    }

    init(
        navigator: Navigator,
        pickerDelegate: any TripBuilderDatePickerDelegate,
        dateFrom: String?,
        dateTo: String?
    ) {
        self.navigator = navigator
        self.pickerDelegate = pickerDelegate
        self.dateFrom = dateFrom.flatMap { Self.dateFormatter.date(from: $0) }
        self.dateTo = dateTo.flatMap { Self.dateFormatter.date(from: $0) }
    }

    func didSelectMode(_ mode: DatePickerMode) {
        self.mode = mode
    }

    func didChangeDateFrom(_ date: Date) {
        dateFrom = date
    }

    func didChangeDateTo(_ date: Date) {
        dateTo = date
    }

    func didToggleMonth(_ month: Int) {
        if selectedMonths.contains(month) {
            selectedMonths.remove(month)
        } else {
            let proposed = selectedMonths.union([month])
            if Self.isContinuous(proposed) {
                selectedMonths = proposed
            }
        }
    }

    func didChangeRangeStart(_ date: Date) {
        rangeStartDate = date
    }

    func didChangeRangeEnd(_ date: Date) {
        rangeEndDate = date
    }

    func didTapDone() {
        let (from, to) = resolvedDates()
        pickerDelegate?.didUpdateDateSelection(
            dateFrom: from.map { Self.dateFormatter.string(from: $0) },
            dateTo: to.map { Self.dateFormatter.string(from: $0) }
        )
        
        navigator.dismiss()
    }

    private func resolvedDates() -> (Date?, Date?) {
        switch mode {
        case .specificDates:
            return (dateFrom, dateTo)
        case .byMonth:
            return Self.dateRangeFromMonths(selectedMonths)
        case .flexibleRange:
            return (rangeStartDate, rangeEndDate)
        }
    }

    private static func isContinuous(_ months: Set<Int>) -> Bool {
        guard !months.isEmpty else { return true }
        let sorted = months.sorted()
        return sorted.last! - sorted.first! == sorted.count - 1
    }

    private static func dateRangeFromMonths(_ months: Set<Int>) -> (Date?, Date?) {
        guard !months.isEmpty else { return (nil, nil) }
        let sorted = months.sorted()
        let year = Calendar.current.component(.year, from: Date())
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let startDate = Calendar.current.date(from: DateComponents(year: year, month: sorted.first!, day: 1))
        let endDate = Calendar.current.date(from: DateComponents(year: year, month: sorted.last! + 1, day: 0))
        return (startDate, endDate)
    }

    private func bind() {
        Task { @MainActor in
            viewDelegate?.bind(viewModel: self)
        }
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
}
