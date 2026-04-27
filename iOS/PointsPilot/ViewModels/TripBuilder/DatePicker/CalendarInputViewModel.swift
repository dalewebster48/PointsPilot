import Foundation

struct DatePickerCalendarMonth: Equatable {
    let year: Int
    let monthIndex: Int
    let longName: String
    let leadingEmptyDayCells: Int
    let dayCount: Int
    let firstDay: Int
    let earliestSelectableDayInMonth: Int
    let latestSelectableDayInMonth: Int
}

protocol CalendarInputViewModelProtocol: AnyObject, DatePickerPanelViewModel {
    var months: [DatePickerCalendarMonth] { get }
    var startDate: Date { get }
    var endDate: Date { get }
    var viewDelegate: (any CalendarInputViewModelViewDelegate)? { get set }

    func didTapDay(year: Int, month: Int, day: Int)
}

protocol CalendarInputViewModelViewDelegate: AnyObject {
    func bind(viewModel: any CalendarInputViewModelProtocol)
}

final class CalendarInputViewModel: CalendarInputViewModelProtocol {
    private enum AnchorMode {
        case start
        case end
    }

    weak var parentDelegate: (any DatePickerPanelDelegate)?

    lazy var months: [DatePickerCalendarMonth] = buildCalendarMonths()

    private(set) var range: DayRange { didSet { bind() } }
    private var anchorMode: AnchorMode = .end

    var startDate: Date { DatePickerDateMath.date(daysFromToday: range.startDay) }
    var endDate: Date { DatePickerDateMath.date(daysFromToday: range.endDay) }

    weak var viewDelegate: (any CalendarInputViewModelViewDelegate)? {
        didSet { bind() }
    }

    init(
        parentDelegate: any DatePickerPanelDelegate,
        initialRange: DayRange
    ) {
        self.parentDelegate = parentDelegate
        self.range = initialRange
    }

    func applyRange(_ range: DayRange) {
        self.range = range
    }

    func didTapDay(year: Int, month: Int, day: Int) {
        let calendar = Calendar.current
        guard let tappedDate = calendar.date(from: DateComponents(year: year, month: month, day: day)) else { return }
        let dayOffset = DatePickerDateMath.clamped(DatePickerDateMath.days(from: tappedDate))

        let next: DayRange
        switch anchorMode {
        case .start:
            next = DayRange(startDay: dayOffset, endDay: dayOffset)
            anchorMode = .end
        case .end:
            let existingStart = range.startDay
            if dayOffset < existingStart {
                next = DayRange(startDay: dayOffset, endDay: existingStart)
            } else {
                next = DayRange(startDay: existingStart, endDay: dayOffset)
            }
            anchorMode = .start
        }
        parentDelegate?.panel(self, didUpdate: next)
    }

    private func bind() {
        Task { @MainActor in
            viewDelegate?.bind(viewModel: self)
        }
    }

    // Builds the 12 mini-month descriptors. Each carries its layout
    // metadata (leading-empty cells before the 1st, day count) and the
    // selectability bounds — earliest/latest tappable days clamped to
    // [today, today + maxDaysOut] so users can't pick into the past or
    // beyond the one-year horizon.
    private func buildCalendarMonths() -> [DatePickerCalendarMonth] {
        let calendar = Calendar.current
        let today = DatePickerDateMath.today
        let longNames = calendar.monthSymbols
        let cap = DatePickerDateMath.date(daysFromToday: DayRange.maxDaysOut)
        let currentMonthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: today))!

        var result: [DatePickerCalendarMonth] = []
        for offset in 0..<12 {
            guard let monthStart = calendar.date(byAdding: .month, value: offset, to: currentMonthStart) else { continue }
            let monthIndex = calendar.component(.month, from: monthStart)
            let year = calendar.component(.year, from: monthStart)
            let dayCount = calendar.range(of: .day, in: .month, for: monthStart)?.count ?? 30

            // Convert system weekday (Sun=1…Sat=7) into a Monday-leading
            // grid offset (Mon=0…Sun=6) — that's how the design lays out.
            let firstWeekday = calendar.component(.weekday, from: monthStart)
            let leadingEmpty = (firstWeekday + 5) % 7

            // First month: earliest selectable day is today's day-of-month.
            // Other months: anything from the 1st is selectable.
            let earliestSelectable = monthStart < today
                ? calendar.component(.day, from: today)
                : 1

            // Last month may extend past the one-year cap; truncate if so.
            let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: monthStart) ?? monthStart
            let latestSelectable = endOfMonth > cap
                ? calendar.component(.day, from: cap)
                : dayCount

            result.append(DatePickerCalendarMonth(
                year: year,
                monthIndex: monthIndex,
                longName: longNames[monthIndex - 1],
                leadingEmptyDayCells: leadingEmpty,
                dayCount: dayCount,
                firstDay: DatePickerDateMath.days(from: max(monthStart, today)),
                earliestSelectableDayInMonth: earliestSelectable,
                latestSelectableDayInMonth: latestSelectable
            ))
        }
        return result
    }
}
