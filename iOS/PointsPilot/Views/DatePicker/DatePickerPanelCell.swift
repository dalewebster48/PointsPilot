import UIKit

final class DatePickerPanelCell: UICollectionViewCell {
    static let reuseIdentifier = "DatePickerPanelCell"

    private let stack = UIStackView()
    private let titleLabel = UILabel()
    private let container = UIView()

    private weak var embeddedPanel: UIView?

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    func embed(panelView: UIView, title: String) {
        titleLabel.text = title

        // Move the panel into this cell only if it isn't already there.
        // Re-parenting it harmlessly removes it from any previous cell.
        if embeddedPanel !== panelView {
            embeddedPanel?.removeFromSuperview()
            panelView.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(panelView)
            NSLayoutConstraint.activate([
                panelView.topAnchor.constraint(equalTo: container.topAnchor),
                panelView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                panelView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
                panelView.bottomAnchor.constraint(equalTo: container.bottomAnchor)
            ])
            embeddedPanel = panelView
        }
    }

    func setFocusOpacity(_ alpha: CGFloat) {
        stack.alpha = alpha
    }

    private func commonInit() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.font = .boldSystemFont(ofSize: 32)
        titleLabel.textColor = Theme.primaryLabel
        titleLabel.numberOfLines = 1

        stack.addArrangedSubview(titleLabel)
        stack.addArrangedSubview(container)

        contentView.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentView.topAnchor),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
}
