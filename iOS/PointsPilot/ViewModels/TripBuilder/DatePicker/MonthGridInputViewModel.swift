import Foundation

struct DatePickerMonth: Equatable {
    let label: String
    let year: String
    let firstDay: Int
    let lastDay: Int
}

enum MonthCellState {
    case selectable
    case selected
    case disabled
}

protocol MonthGridInputViewModelProtocol: AnyObject, DatePickerPanelViewModel {
    var months: [DatePickerMonth] { get }
    var viewDelegate: (any MonthGridInputViewModelViewDelegate)? { get set }

    func state(at index: Int) -> MonthCellState
    func didTapMonth(at index: Int)
}

protocol MonthGridInputViewModelViewDelegate: AnyObject {
    func bind(viewModel: any MonthGridInputViewModelProtocol)
}

final class MonthGridInputViewModel: MonthGridInputViewModelProtocol {
    weak var parentDelegate: (any DatePickerPanelDelegate)?

    lazy var months: [DatePickerMonth] = buildRollingMonths()

    private var selectedRange: ClosedRange<Int>? {
        didSet { bind() }
    }

    weak var viewDelegate: (any MonthGridInputViewModelViewDelegate)? {
        didSet { bind() }
    }

    init(parentDelegate: any DatePickerPanelDelegate) {
        self.parentDelegate = parentDelegate
    }

    func state(at index: Int) -> MonthCellState {
        guard let range = selectedRange else { return .selectable }
        if range.contains(index) { return .selected }
        if index == range.lowerBound - 1 || index == range.upperBound + 1 {
            return .selectable
        }
        return .disabled
    }

    func didTapMonth(at index: Int) {
        switch state(at: index) {
        case .disabled:
            return
        case .selectable:
            extendSelection(to: index)
        case .selected:
            shrinkSelection(removing: index)
        }
        notifyParent()
    }

    // Cross-panel sync was removed; this panel maintains its own selection.
    func applyRange(_ range: DayRange) {}

    private func extendSelection(to index: Int) {
        guard let range = selectedRange else {
            selectedRange = index...index
            return
        }
        if index == range.lowerBound - 1 {
            selectedRange = index...range.upperBound
        } else if index == range.upperBound + 1 {
            selectedRange = range.lowerBound...index
        }
    }

    private func shrinkSelection(removing index: Int) {
        guard let range = selectedRange else { return }
        if range.lowerBound == range.upperBound {
            selectedRange = nil
        } else if index == range.lowerBound {
            selectedRange = (range.lowerBound + 1)...range.upperBound
        } else if index == range.upperBound {
            selectedRange = range.lowerBound...(range.upperBound - 1)
        }
        // Interior taps are intentionally ignored to keep the selection contiguous.
    }

    private func notifyParent() {
        let range: DayRange
        if let selectedRange {
            range = DayRange(
                startDay: DatePickerDateMath.clamped(months[selectedRange.lowerBound].firstDay),
                endDay: DatePickerDateMath.clamped(months[selectedRange.upperBound].lastDay)
            )
        } else {
            range = .fullYear
        }
        parentDelegate?.panel(self, didUpdate: range)
    }

    private func bind() {
        print("Dale selected range", selectedRange)
        
        Task { @MainActor in
            viewDelegate?.bind(viewModel: self)
        }
    }

    // Builds the 12-month rolling window starting from the current month.
    // The first month's firstDay is clamped forward to today and the last
    // month's lastDay is clamped to the maxDaysOut horizon, so summary
    // ranges never reach into the past or beyond a year out.
    private func buildRollingMonths() -> [DatePickerMonth] {
        let calendar = Calendar.current
        let today = DatePickerDateMath.today
        let shortNames = calendar.shortMonthSymbols
        let cap = DatePickerDateMath.date(daysFromToday: DayRange.maxDaysOut)
        let currentMonthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: today))!

        var result: [DatePickerMonth] = []
        for offset in 0..<12 {
            guard let monthStart = calendar.date(byAdding: .month, value: offset, to: currentMonthStart) else { continue }
            let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: monthStart) ?? monthStart

            let clampedFirst = max(monthStart, today)
            let clampedLast = min(endOfMonth, cap)

            let monthIndex = calendar.component(.month, from: monthStart)
            let year = calendar.component(.year, from: monthStart)

            result.append(DatePickerMonth(
                label: shortNames[monthIndex - 1],
                year: String(year),
                firstDay: DatePickerDateMath.days(from: clampedFirst),
                lastDay: DatePickerDateMath.days(from: clampedLast)
            ))
        }
        return result
    }
}
