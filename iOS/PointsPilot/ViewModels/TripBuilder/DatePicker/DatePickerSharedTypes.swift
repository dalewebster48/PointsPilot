import Foundation

struct DayRange: Equatable {
    var startDay: Int
    var endDay: Int

    static let maxDaysOut = 364

    static let fullYear = DayRange(startDay: 0, endDay: maxDaysOut)

    var isFullYear: Bool {
        startDay == 0 && endDay == DayRange.maxDaysOut
    }

    var startDate: Date? {
        isFullYear ? nil : DatePickerDateMath.date(daysFromToday: startDay)
    }

    var endDate: Date? {
        isFullYear ? nil : DatePickerDateMath.date(daysFromToday: endDay)
    }
}

extension DayRange {
    init(startDate: Date?, endDate: Date?) {
        switch (startDate, endDate) {
        case (nil, nil):
            self = .fullYear
        case let (start?, nil):
            let startDay = DatePickerDateMath.clamped(DatePickerDateMath.days(from: start))
            self.init(startDay: startDay, endDay: DayRange.maxDaysOut)
        case let (nil, end?):
            let endDay = DatePickerDateMath.clamped(DatePickerDateMath.days(from: end))
            self.init(startDay: 0, endDay: endDay)
        case let (start?, end?):
            let startDay = DatePickerDateMath.clamped(DatePickerDateMath.days(from: start))
            let endDay = DatePickerDateMath.clamped(DatePickerDateMath.days(from: end))
            self.init(startDay: min(startDay, endDay), endDay: max(startDay, endDay))
        }
    }
}

enum DatePickerPanel: Int, CaseIterable {
    case months
    case range
    case calendar
}

protocol DatePickerPanelViewModel: AnyObject {
    func applyRange(_ range: DayRange)
}

protocol DatePickerPanelDelegate: AnyObject {
    func panel(
        _ source: any DatePickerPanelViewModel,
        didUpdate range: DayRange
    )
}

enum DatePickerDateMath {
    static var today: Date {
        Calendar.current.startOfDay(for: Date())
    }

    static func date(daysFromToday days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: days, to: today) ?? today
    }

    static func days(from date: Date) -> Int {
        let comps = Calendar.current.dateComponents([.day], from: today, to: Calendar.current.startOfDay(for: date))
        return comps.day ?? 0
    }

    static func clamped(_ days: Int) -> Int {
        max(0, min(DayRange.maxDaysOut, days))
    }
}
