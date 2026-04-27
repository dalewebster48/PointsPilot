import Foundation

struct DatePickerMonth: Equatable {
    let index: Int
    let label: String
    let year: String
    let firstDay: Int
    let lastDay: Int
}

protocol MonthGridInputViewModelProtocol: AnyObject, DatePickerPanelViewModel {
    var months: [DatePickerMonth] { get }
    var selectedIndices: Set<Int> { get }
    var viewDelegate: (any MonthGridInputViewModelViewDelegate)? { get set }

    func didTapMonth(at index: Int)
}

protocol MonthGridInputViewModelViewDelegate: AnyObject {
    func bind(viewModel: any MonthGridInputViewModelProtocol)
}

final class MonthGridInputViewModel: MonthGridInputViewModelProtocol {
    weak var parentDelegate: (any DatePickerPanelDelegate)?

    lazy var months: [DatePickerMonth] = buildRollingMonths()

    private(set) var selectedIndices: Set<Int> = [] {
        didSet { bind() }
    }

    weak var viewDelegate: (any MonthGridInputViewModelViewDelegate)? {
        didSet { bind() }
    }

    init(
        parentDelegate: any DatePickerPanelDelegate,
        initialRange: DayRange
    ) {
        self.parentDelegate = parentDelegate
        self.selectedIndices = indices(overlapping: initialRange, in: self.months)
    }

    func applyRange(_ range: DayRange) {
        selectedIndices = indices(overlapping: range, in: months)
    }

    func didTapMonth(at index: Int) {
        var proposed = selectedIndices
        if proposed.contains(index) {
            proposed.remove(index)
        } else {
            proposed.insert(index)
        }
        let range = range(from: proposed, months: months)
        parentDelegate?.panel(self, didUpdate: range)
    }

    private func bind() {
        Task { @MainActor in
            viewDelegate?.bind(viewModel: self)
        }
    }

    // Returns the set of month indices that should appear "selected" for a
    // given day range. A month is considered selected when any part of its
    // day range overlaps with the picked range. The "full year" range is
    // treated as no specific month being chosen, so it returns an empty set.
    private func indices(
        overlapping range: DayRange,
        in months: [DatePickerMonth]
    ) -> Set<Int> {
        // Full-year is the "no preference" sentinel — show no months as picked.
        if range.isFullYear { return [] }

        var result: Set<Int> = []
        for month in months {
            // Standard interval-overlap test: two ranges overlap iff each
            // starts before the other ends.
            let monthStartsBeforeRangeEnds = month.firstDay <= range.endDay
            let monthEndsAfterRangeStarts = month.lastDay >= range.startDay
            if monthStartsBeforeRangeEnds && monthEndsAfterRangeStarts {
                result.insert(month.index)
            }
        }
        return result
    }

    // Converts a set of tapped month indices into a single contiguous day
    // range spanning from the earliest tapped month's first day to the
    // latest tapped month's last day. Tapping nothing collapses back to
    // the "any time in the next year" sentinel.
    private func range(
        from indices: Set<Int>,
        months: [DatePickerMonth]
    ) -> DayRange {
        // No months tapped → no specific window; reset to full year.
        guard !indices.isEmpty else { return .fullYear }

        // We only care about the extremes — gaps between tapped months are
        // intentionally collapsed, so May+August produces May 1 → Aug 31.
        let sorted = indices.sorted()
        let first = months[sorted.first!].firstDay
        let last = months[sorted.last!].lastDay

        return DayRange(
            startDay: DatePickerDateMath.clamped(first),
            endDay: DatePickerDateMath.clamped(last)
        )
    }

    // Builds the 12-month rolling window starting from the current month.
    // Each month carries its display label, year, and the day-offset bounds
    // we'll reuse for selection overlap math. The first month is clamped
    // forward to today (so April's first day is "today", not April 1st in
    // the past) and the last month is clamped backward to the maxDaysOut
    // horizon (so we never offer a date beyond a year out).
    private func buildRollingMonths() -> [DatePickerMonth] {
        let calendar = Calendar.current
        let today = DatePickerDateMath.today
        let shortNames = calendar.shortMonthSymbols
        let cap = DatePickerDateMath.date(daysFromToday: DayRange.maxDaysOut)
        // Anchor on the first day of the current month so .month arithmetic
        // produces clean month boundaries regardless of today's day-of-month.
        let currentMonthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: today))!

        var result: [DatePickerMonth] = []
        for offset in 0..<12 {
            guard let monthStart = calendar.date(byAdding: .month, value: offset, to: currentMonthStart) else { continue }
            // .month + day -1 lands on the last day of the same month.
            let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: monthStart) ?? monthStart

            // Clamp the visible day range so users can't pick into the past
            // or beyond the one-year horizon.
            let clampedFirst = max(monthStart, today)
            let clampedLast = min(endOfMonth, cap)

            let monthIndex = calendar.component(.month, from: monthStart)
            let year = calendar.component(.year, from: monthStart)

            result.append(DatePickerMonth(
                index: offset,
                label: shortNames[monthIndex - 1],
                year: String(year),
                firstDay: DatePickerDateMath.days(from: clampedFirst),
                lastDay: DatePickerDateMath.days(from: clampedLast)
            ))
        }
        return result
    }
}
