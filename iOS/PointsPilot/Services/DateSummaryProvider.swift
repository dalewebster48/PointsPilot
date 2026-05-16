import UIKit

protocol DateSummaryProvider: AnyObject {
    func summary(
        from startDate: Date?,
        to endDate: Date?
    ) -> NSAttributedString
}

final class DateSummaryProviderImpl: DateSummaryProvider {
    func summary(
        from startDate: Date?,
        to endDate: Date?
    ) -> NSAttributedString {
        let result = NSMutableAttributedString()

        switch (startDate, endDate) {
        case (nil, nil):
            result.append(plain("Any time in the next year"))
        case let (nil, end?):
            result.append(plain("Any time before "))
            result.append(underlined(DateFormatter.monthDay.string(from: end)))
        case let (start?, nil):
            result.append(plain("Any time after "))
            result.append(underlined(DateFormatter.monthDay.string(from: start)))
        case let (start?, end?):
            if Calendar.current.isDate(start, inSameDayAs: end) {
                result.append(plain("On "))
                result.append(underlined(DateFormatter.monthDay.string(from: start)))
            } else {
                result.append(plain("Between "))
                result.append(underlined(DateFormatter.monthDay.string(from: start)))
                result.append(plain(" and "))
                result.append(underlined(DateFormatter.monthDay.string(from: end)))
            }
        }

        return result
    }

    private func plain(_ string: String) -> NSAttributedString {
        NSAttributedString(string: string)
    }

    private func underlined(_ string: String) -> NSAttributedString {
        NSAttributedString(
            string: string,
            attributes: [
                .underlineStyle: NSUnderlineStyle.single.rawValue,
                .underlineColor: Theme.primaryAccent,
                .foregroundColor: Theme.primaryAccent
            ]
        )
    }

}
