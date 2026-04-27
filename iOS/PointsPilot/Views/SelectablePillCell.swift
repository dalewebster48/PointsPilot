import UIKit

final class SelectablePillCell: UICollectionViewCell {
    enum Size {
        case small
        case medium
        case large
    }

    @IBOutlet private weak var labelStack: UIStackView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var topConstraint: NSLayoutConstraint!
    @IBOutlet private weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var leadingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var trailingConstraint: NSLayoutConstraint!

    static let reuseIdentifier = "SelectablePillCell"

    override var isSelected: Bool {
        didSet { applySelectionState() }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        clipsToBounds = true
        applySize(.medium)
        applySelectionState()
    }

    func configure(
        title: String,
        subtitle: String? = nil,
        size: Size = .medium
    ) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
        subtitleLabel.isHidden = subtitle == nil
        applySize(size)
    }

    private func applySize(_ size: Size) {
        switch size {
        case .small:
            layer.cornerRadius = 14
            titleLabel.font = .systemFont(ofSize: 13, weight: .medium)
            subtitleLabel.font = .systemFont(ofSize: 10, weight: .medium)
            topConstraint.constant = 6
            bottomConstraint.constant = 6
            leadingConstraint.constant = 12
            trailingConstraint.constant = 12
            labelStack.spacing = 0
        case .medium:
            layer.cornerRadius = 16
            titleLabel.font = .systemFont(ofSize: 14, weight: .medium)
            subtitleLabel.font = .systemFont(ofSize: 11, weight: .medium)
            topConstraint.constant = 6
            bottomConstraint.constant = 6
            leadingConstraint.constant = 12
            trailingConstraint.constant = 12
            labelStack.spacing = 0
        case .large:
            layer.cornerRadius = 18
            titleLabel.font = .systemFont(ofSize: 17, weight: .semibold)
            subtitleLabel.font = .systemFont(ofSize: 11, weight: .medium)
            topConstraint.constant = 12
            bottomConstraint.constant = 12
            leadingConstraint.constant = 16
            trailingConstraint.constant = 16
            labelStack.spacing = 1
        }
    }

    private func applySelectionState() {
        if isSelected {
            backgroundColor = Theme.primaryAccent
            titleLabel.textColor = .white
            subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.7)
        } else {
            backgroundColor = Theme.secondaryBackground
            titleLabel.textColor = Theme.primaryLabel
            subtitleLabel.textColor = Theme.secondaryLabel
        }
    }
}
