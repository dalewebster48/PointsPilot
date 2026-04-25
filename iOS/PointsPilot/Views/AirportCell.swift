import UIKit

final class AirportCell: UITableViewCell {
    @IBOutlet private weak var codeLabel: UILabel!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var countryLabel: UILabel!

    static let reuseIdentifier = "AirportCell"

    override func awakeFromNib() {
        super.awakeFromNib()
        applyTheme()
    }

    func configure(with airport: Airport) {
        codeLabel.text = airport.code
        nameLabel.text = airport.name
        countryLabel.text = airport.country
    }

    private func applyTheme() {
        backgroundColor = Theme.background
        contentView.backgroundColor = Theme.background
        codeLabel.textColor = Theme.primaryAccent
        nameLabel.textColor = Theme.primaryLabel
        countryLabel.textColor = Theme.secondaryLabel
    }
}
