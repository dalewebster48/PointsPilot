import Foundation

protocol DatePickerInputViewModelFactory: AnyObject {
    func makeMonthGridInputViewModel(
        parentDelegate: any DatePickerPanelDelegate,
        initialRange: DayRange
    ) -> any MonthGridInputViewModelProtocol

    func makeRangeSliderInputViewModel(
        parentDelegate: any DatePickerPanelDelegate,
        initialRange: DayRange
    ) -> any RangeSliderInputViewModelProtocol

    func makeCalendarInputViewModel(
        parentDelegate: any DatePickerPanelDelegate,
        initialRange: DayRange
    ) -> any CalendarInputViewModelProtocol
}
