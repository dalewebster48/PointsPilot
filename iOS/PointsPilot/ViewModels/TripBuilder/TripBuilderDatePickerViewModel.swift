import Foundation

protocol TripBuilderDatePickerDelegate: AnyObject {
    func didUpdateDateSelection(
        dateFrom: String?,
        dateTo: String?
    )
}

protocol TripBuilderDatePickerViewModelProtocol: AnyObject {
    var range: DayRange { get }
    var focusedPanel: DatePickerPanel { get }
    var summaryViewModel: any TripBuilderSummaryViewModelProtocol { get }
    var monthInputViewModel: any MonthGridInputViewModelProtocol { get }
    var rangeInputViewModel: any RangeSliderInputViewModelProtocol { get }
    var calendarInputViewModel: any CalendarInputViewModelProtocol { get }

    var viewDelegate: (any TripBuilderDatePickerViewModelViewDelegate)? { get set }

    func didChangeFocusedPanel(_ panel: DatePickerPanel)
    func didTapDone()
}

protocol TripBuilderDatePickerViewModelViewDelegate: AnyObject {
    func bind(viewModel: any TripBuilderDatePickerViewModelProtocol)
}

final class TripBuilderDatePickerViewModel: TripBuilderDatePickerViewModelProtocol {
    private let navigator: any Navigator
    private let summaryFactory: any TripBuilderSummaryViewModelFactory
    private let inputFactory: any DatePickerInputViewModelFactory
    private let summaryProvider: any DateSummaryProvider
    private weak var pickerDelegate: (any TripBuilderDatePickerDelegate)?

    private(set) var range: DayRange { didSet { bind() } }
    private(set) var focusedPanel: DatePickerPanel = .months { didSet { bind() } }

    lazy var monthInputViewModel: any MonthGridInputViewModelProtocol = inputFactory.makeMonthGridInputViewModel(
        parentDelegate: self
    )

    lazy var rangeInputViewModel: any RangeSliderInputViewModelProtocol = inputFactory.makeRangeSliderInputViewModel(
        parentDelegate: self,
        initialRange: range
    )

    lazy var calendarInputViewModel: any CalendarInputViewModelProtocol = inputFactory.makeCalendarInputViewModel(
        parentDelegate: self,
        initialRange: range
    )

    var summaryViewModel: any TripBuilderSummaryViewModelProtocol {
        summaryFactory.makeTripBuilderSummaryViewModel(
            title: "When are you travelling?",
            summary: summaryProvider.summary(from: range.startDate, to: range.endDate),
            instruction: instruction(for: focusedPanel),
            buttonTitle: "Ok"
        )
    }

    weak var viewDelegate: (any TripBuilderDatePickerViewModelViewDelegate)? {
        didSet { bind() }
    }

    init(
        navigator: any Navigator,
        summaryFactory: any TripBuilderSummaryViewModelFactory,
        inputFactory: any DatePickerInputViewModelFactory,
        summaryProvider: any DateSummaryProvider,
        pickerDelegate: any TripBuilderDatePickerDelegate,
        initialRange: DayRange
    ) {
        self.navigator = navigator
        self.summaryFactory = summaryFactory
        self.inputFactory = inputFactory
        self.summaryProvider = summaryProvider
        self.pickerDelegate = pickerDelegate
        self.range = initialRange
    }

    func didChangeFocusedPanel(_ panel: DatePickerPanel) {
        guard panel != focusedPanel else { return }
        focusedPanel = panel
    }

    func didTapDone() {
        pickerDelegate?.didUpdateDateSelection(
            dateFrom: range.startDate.map { DateFormatter.yearMonthDay.string(from: $0) },
            dateTo: range.endDate.map { DateFormatter.yearMonthDay.string(from: $0) }
        )
        navigator.dismiss()
    }

    private func instruction(for panel: DatePickerPanel) -> String {
        switch panel {
        case .months: return "Pick months you might travel in"
        case .range: return "Drag the handles to set a window"
        case .calendar: return "Pick exact dates if you know them"
        }
    }

    private func bind() {
        Task { @MainActor in
            viewDelegate?.bind(viewModel: self)
        }
    }
}

// MARK: - DatePickerPanelDelegate

extension TripBuilderDatePickerViewModel: DatePickerPanelDelegate {
    func panel(
        _ source: any DatePickerPanelViewModel,
        didUpdate range: DayRange
    ) {
        guard range != self.range else { return }
        self.range = range
        // Push the new range into every other sub-VM so all panels stay in sync.
        // The originating sub-VM already reflects this range, so skip it to
        // avoid an unnecessary re-render and to break any feedback loops.
        if source !== monthInputViewModel { monthInputViewModel.applyRange(range) }
        if source !== rangeInputViewModel { rangeInputViewModel.applyRange(range) }
        if source !== calendarInputViewModel { calendarInputViewModel.applyRange(range) }
    }
}
