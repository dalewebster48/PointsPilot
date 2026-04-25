import UIKit

enum Theme {
    static var primaryAccent: UIColor {
        UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(red: 0.4, green: 0.6, blue: 1.0, alpha: 1.0)
                : UIColor(red: 0.2, green: 0.4, blue: 0.9, alpha: 1.0)
        }
    }

    static var secondaryAccent: UIColor {
        UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(red: 0.3, green: 0.8, blue: 0.7, alpha: 1.0)
                : UIColor(red: 0.1, green: 0.6, blue: 0.5, alpha: 1.0)
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
        UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? primaryAccent.withAlphaComponent(0.15)
                : primaryAccent.withAlphaComponent(0.08)
        }
    }

    static var dealBackground: UIColor {
        UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? dealHighlight.withAlphaComponent(0.15)
                : dealHighlight.withAlphaComponent(0.08)
        }
    }
}
