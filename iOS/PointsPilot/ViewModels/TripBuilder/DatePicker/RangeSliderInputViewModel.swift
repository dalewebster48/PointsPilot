import Foundation

enum DatePickerSeason: CaseIterable {
    case spring
    case summer
    case fall
    case winter

    var label: String {
        switch self {
        case .spring: return "Spring"
        case .summer: return "Summer"
        case .fall: return "Fall"
        case .winter: return "Winter"
        }
    }

    fileprivate var startMonth: Int {
        switch self {
        case .spring: return 3
        case .summer: return 6
        case .fall: return 9
        case .winter: return 12
        }
    }

    fileprivate var monthCount: Int { 3 }
}

struct DatePickerMonthTick: Equatable {
    let letter: String
    let percent: Double
}

protocol RangeSliderInputViewModelProtocol: AnyObject, DatePickerPanelViewModel {
    var startDate: Date { get }
    var endDate: Date { get }
    var startDay: Int { get }
    var endDay: Int { get }
    var maxDay: Int { get }
    var monthTicks: [DatePickerMonthTick] { get }
    var seasons: [DatePickerSeason] { get }
    var viewDelegate: (any RangeSliderInputViewModelViewDelegate)? { get set }

    func didChangeSliderValues(lower: Int, upper: Int)
    func didTapSeason(_ season: DatePickerSeason)
}

protocol RangeSliderInputViewModelViewDelegate: AnyObject {
    func bind(viewModel: any RangeSliderInputViewModelProtocol)
}

final class RangeSliderInputViewModel: RangeSliderInputViewModelProtocol {
    weak var parentDelegate: (any DatePickerPanelDelegate)?

    let seasons: [DatePickerSeason] = DatePickerSeason.allCases
    let maxDay = DayRange.maxDaysOut

    private(set) var range: DayRange { didSet { bind() } }

    var startDay: Int { range.startDay }
    var endDay: Int { range.endDay }
    var startDate: Date { DatePickerDateMath.date(daysFromToday: range.startDay) }
    var endDate: Date { DatePickerDateMath.date(daysFromToday: range.endDay) }

    weak var viewDelegate: (any RangeSliderInputViewModelViewDelegate)? {
        didSet { bind() }
    }

    lazy var monthTicks: [DatePickerMonthTick] = buildMonthTicks()

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

    func didChangeSliderValues(lower: Int, upper: Int) {
        let clampedLower = DatePickerDateMath.clamped(lower)
        let clampedUpper = DatePickerDateMath.clamped(upper)
        guard clampedLower <= clampedUpper else { return }
        let next = DayRange(startDay: clampedLower, endDay: clampedUpper)
        guard next != range else { return }
        parentDelegate?.panel(self, didUpdate: next)
    }

    func didTapSeason(_ season: DatePickerSeason) {
        guard let next = dayRange(for: season) else { return }
        parentDelegate?.panel(self, didUpdate: next)
    }

    private func bind() {
        Task { @MainActor in
            viewDelegate?.bind(viewModel: self)
        }
    }

    // Finds the upcoming (or in-progress) instance of a season and returns
    // its date span as a DayRange clamped to the picker's [today, maxDaysOut]
    // window. We try the current year first, falling back to next year for
    // seasons whose end is already in the past.
    private func dayRange(for season: DatePickerSeason) -> DayRange? {
        let calendar = Calendar.current
        let today = DatePickerDateMath.today
        let cap = DatePickerDateMath.date(daysFromToday: DayRange.maxDaysOut)
        let currentYear = calendar.component(.year, from: today)

        for yearOffset in 0...1 {
            let year = currentYear + yearOffset
            guard
                let start = calendar.date(from: DateComponents(year: year, month: season.startMonth, day: 1)),
                let endOfLastMonth = calendar.date(byAdding: DateComponents(month: season.monthCount, day: -1), to: start)
            else { continue }

            // Skip past seasons that have already ended within the picker window.
            let clampedEnd = min(endOfLastMonth, cap)
            if clampedEnd < today { continue }

            let startDay = DatePickerDateMath.clamped(DatePickerDateMath.days(from: max(start, today)))
            let endDay = DatePickerDateMath.clamped(DatePickerDateMath.days(from: clampedEnd))
            guard startDay <= endDay else { continue }
            return DayRange(startDay: startDay, endDay: endDay)
        }
        return nil
    }

    // Builds a single-letter tick per rolling month, positioned along the
    // slider track by the percentage at which that month begins. The first
    // tick is always at 0 (today's month, snapped forward to today).
    private func buildMonthTicks() -> [DatePickerMonthTick] {
        let calendar = Calendar.current
        let today = DatePickerDateMath.today
        let shortNames = calendar.shortMonthSymbols
        let currentMonthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: today))!

        var result: [DatePickerMonthTick] = []
        for offset in 0..<12 {
            guard let monthStart = calendar.date(byAdding: .month, value: offset, to: currentMonthStart) else { continue }
            let day = DatePickerDateMath.days(from: max(monthStart, today))
            let percent = max(0, min(1, Double(day) / Double(DayRange.maxDaysOut)))
            let monthIndex = calendar.component(.month, from: monthStart)
            let letter = String(shortNames[monthIndex - 1].prefix(1))
            result.append(DatePickerMonthTick(letter: letter, percent: percent))
        }
        return result
    }
}
