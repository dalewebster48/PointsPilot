import UIKit

final class FlightDealCell: UICollectionViewCell {
    @IBOutlet private weak var routeLabel: UILabel!
    @IBOutlet private weak var dayLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var economyCostLabel: UILabel!
    @IBOutlet private weak var economyUnitLabel: UILabel!
    @IBOutlet private weak var economyBar: ValueBarView!
    @IBOutlet private weak var premiumCostLabel: UILabel!
    @IBOutlet private weak var premiumUnitLabel: UILabel!
    @IBOutlet private weak var premiumBar: ValueBarView!
    @IBOutlet private weak var upperCostLabel: UILabel!
    @IBOutlet private weak var upperUnitLabel: UILabel!
    @IBOutlet private weak var upperBar: ValueBarView!
    @IBOutlet private weak var separatorView: UIView!

    static let reuseIdentifier = "FlightDealCell"

    override func awakeFromNib() {
        super.awakeFromNib()
        applyTheme()
    }

    func configure(viewModel: any FlightResultCellViewModelProtocol) {
        routeLabel.text = "\(viewModel.originCode)  →  \(viewModel.destinationCode)"
        dayLabel.text = viewModel.dayOfWeek
        dateLabel.text = viewModel.dateText

        apply(
            cabin: viewModel.economy,
            isSortColumn: viewModel.sortField == .economy,
            costLabel: economyCostLabel,
            unitLabel: economyUnitLabel,
            bar: economyBar
        )
        apply(
            cabin: viewModel.premium,
            isSortColumn: viewModel.sortField == .premium,
            costLabel: premiumCostLabel,
            unitLabel: premiumUnitLabel,
            bar: premiumBar
        )
        apply(
            cabin: viewModel.upper,
            isSortColumn: viewModel.sortField == .upper,
            costLabel: upperCostLabel,
            unitLabel: upperUnitLabel,
            bar: upperBar
        )
    }

    private func apply(
        cabin: CabinResult,
        isSortColumn: Bool,
        costLabel: UILabel,
        unitLabel: UILabel,
        bar: ValueBarView
    ) {
        costLabel.text = cabin.cost
        costLabel.font = isSortColumn
            ? .systemFont(ofSize: 22, weight: .heavy)
            : .systemFont(ofSize: 19, weight: cabin.isDeal ? .heavy : .semibold)

        let primaryColor: UIColor
        if cabin.isDeal {
            primaryColor = Theme.primaryAccent
        } else if isSortColumn {
            primaryColor = Theme.primaryLabel
        } else {
            primaryColor = Theme.secondaryLabel
        }

        costLabel.textColor = primaryColor
        unitLabel.textColor = cabin.isDeal ? Theme.primaryAccent : Theme.secondaryLabel
        bar.fillColor = primaryColor
        bar.fraction = cabin.barFraction
    }

    private func applyTheme() {
        backgroundColor = Theme.background
        contentView.backgroundColor = Theme.background
        routeLabel.textColor = Theme.primaryLabel
        dayLabel.textColor = Theme.secondaryLabel
        dateLabel.textColor = Theme.primaryLabel
        economyUnitLabel.text = "pts"
        premiumUnitLabel.text = "pts"
        upperUnitLabel.text = "pts"
        separatorView.backgroundColor = Theme.separator
    }
}
