import UIKit

final class FlightDealCell: UICollectionViewCell {
    @IBOutlet private weak var originCodeLabel: UILabel!
    @IBOutlet private weak var originNameLabel: UILabel!
    @IBOutlet private weak var destinationCodeLabel: UILabel!
    @IBOutlet private weak var destinationNameLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var economyPointsLabel: UILabel!
    @IBOutlet private weak var economyDealBadge: UIView!
    @IBOutlet private weak var premiumPointsLabel: UILabel!
    @IBOutlet private weak var premiumDealBadge: UIView!
    @IBOutlet private weak var upperPointsLabel: UILabel!
    @IBOutlet private weak var upperDealBadge: UIView!

    static let reuseIdentifier = "FlightDealCell"

    override func awakeFromNib() {
        super.awakeFromNib()
        applyTheme()
        economyDealBadge.layer.cornerRadius = 4
        premiumDealBadge.layer.cornerRadius = 4
        upperDealBadge.layer.cornerRadius = 4
    }

    func configure(with flight: Flight) {
        originCodeLabel.text = flight.origin.id
        originNameLabel.text = flight.origin.name
        destinationCodeLabel.text = flight.destination.id
        destinationNameLabel.text = flight.destination.name
        dateLabel.text = flight.date

        configurePoints(
            label: economyPointsLabel,
            badge: economyDealBadge,
            cost: flight.economyCost,
            isDeal: flight.economyDeal
        )
        configurePoints(
            label: premiumPointsLabel,
            badge: premiumDealBadge,
            cost: flight.premiumCost,
            isDeal: flight.premiumDeal
        )
        configurePoints(
            label: upperPointsLabel,
            badge: upperDealBadge,
            cost: flight.upperCost,
            isDeal: flight.upperDeal
        )
    }

    private func configurePoints(
        label: UILabel,
        badge: UIView,
        cost: Int,
        isDeal: Bool
    ) {
        if cost > 0 {
            label.text = Self.numberFormatter.string(from: NSNumber(value: cost))
        } else {
            label.text = "—"
        }
        badge.isHidden = !isDeal
    }

    private func applyTheme() {
        backgroundColor = Theme.background
        contentView.backgroundColor = Theme.background
        originCodeLabel.textColor = Theme.primaryLabel
        originNameLabel.textColor = Theme.secondaryLabel
        destinationCodeLabel.textColor = Theme.primaryLabel
        destinationNameLabel.textColor = Theme.secondaryLabel
        dateLabel.textColor = Theme.secondaryLabel
        economyPointsLabel.textColor = Theme.primaryLabel
        premiumPointsLabel.textColor = Theme.primaryLabel
        upperPointsLabel.textColor = Theme.primaryLabel
        economyDealBadge.backgroundColor = Theme.dealHighlight
        premiumDealBadge.backgroundColor = Theme.dealHighlight
        upperDealBadge.backgroundColor = Theme.dealHighlight
    }

    private static let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        return formatter
    }()
}
