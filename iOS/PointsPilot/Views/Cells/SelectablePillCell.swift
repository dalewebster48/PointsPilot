import UIKit

final class SelectablePillCell: UICollectionViewCell {
    enum Size {
        case small
        case medium
        case large
    }

    enum DisplayState {
        case normal
        case selected
        case disabled
    }

    @IBOutlet private weak var labelStack: UIStackView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var topConstraint: NSLayoutConstraint!
    @IBOutlet private weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var leadingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var trailingConstraint: NSLayoutConstraint!

    static let reuseIdentifier = "SelectablePillCell"

    var displayState: DisplayState = .normal {
        didSet { applyDisplayState() }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        clipsToBounds = true
        applySize(.medium)
        applyDisplayState()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        displayState = .normal
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

    private func applyDisplayState() {
        switch displayState {
        case .normal:
            backgroundColor = Theme.secondaryBackground
            titleLabel.textColor = Theme.primaryLabel
            subtitleLabel.textColor = Theme.secondaryLabel
            contentView.alpha = 1.0
            isUserInteractionEnabled = true
        case .selected:
            backgroundColor = Theme.primaryAccent
            titleLabel.textColor = .white
            subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.7)
            contentView.alpha = 1.0
            isUserInteractionEnabled = true
        case .disabled:
            backgroundColor = Theme.secondaryBackground
            titleLabel.textColor = Theme.primaryLabel
            subtitleLabel.textColor = Theme.secondaryLabel
            contentView.alpha = 0.4
            isUserInteractionEnabled = false
        }
    }
}
