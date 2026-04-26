import UIKit

final class SelectablePillCell: UICollectionViewCell {
    @IBOutlet private weak var titleLabel: UILabel!

    static let reuseIdentifier = "SelectablePillCell"

    override var isSelected: Bool {
        didSet { applySelectionState() }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 16
        clipsToBounds = true
        applySelectionState()
    }

    func configure(title: String) {
        titleLabel.text = title
    }

    private func applySelectionState() {
        if isSelected {
            backgroundColor = Theme.primaryAccent
            titleLabel.textColor = .white
        } else {
            backgroundColor = Theme.secondaryBackground
            titleLabel.textColor = Theme.primaryLabel
        }
    }
}
