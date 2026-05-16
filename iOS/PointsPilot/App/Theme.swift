import UIKit

enum Theme {
    static var primaryAccent: UIColor {
        UIColor(red: 1.0, green: 0.420, blue: 0.290, alpha: 1.0)
    }

    static var secondaryAccent: UIColor {
        UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(red: 0.60, green: 0.60, blue: 0.62, alpha: 1.0)
                : UIColor(red: 0.42, green: 0.42, blue: 0.44, alpha: 1.0)
        }
    }

    static var dealHighlight: UIColor {
        UIColor.systemGreen
    }

    static var background: UIColor {
        UIColor.systemBackground
    }

    static var secondaryBackground: UIColor {
        UIColor.secondarySystemBackground
    }

    static var groupedBackground: UIColor {
        UIColor.systemGroupedBackground
    }

    static var primaryLabel: UIColor {
        UIColor.label
    }

    static var secondaryLabel: UIColor {
        UIColor.secondaryLabel
    }

    static var separator: UIColor {
        UIColor.separator
    }

    static var destructive: UIColor {
        UIColor.systemRed
    }

    static var accentBackground: UIColor {
        primaryAccent.withAlphaComponent(0.13)
    }

    static var dealBackground: UIColor {
        UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? dealHighlight.withAlphaComponent(0.15)
                : dealHighlight.withAlphaComponent(0.08)
        }
    }
}
