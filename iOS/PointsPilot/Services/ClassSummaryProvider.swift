import UIKit

protocol ClassSummaryProvider: AnyObject {
    func summary(
        seatClass: SeatClass?,
        dealsOnly: Bool,
        maxCost: Int?
    ) -> NSAttributedString
}

final class ClassSummaryProviderImpl: ClassSummaryProvider {
    func summary(
        seatClass: SeatClass?,
        dealsOnly: Bool,
        maxCost: Int?
    ) -> NSAttributedString {
        let result = NSMutableAttributedString()

        guard let seatClass else {
            result.append(plain("No preference"))
            return result
        }

        result.append(underlined(seatClass.rawValue.capitalized))

        if dealsOnly {
            result.append(plain(" "))
            result.append(underlined("deals only"))
        } else if let maxCost {
            result.append(plain(" under "))
            result.append(underlined("\(maxCost) points"))
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
