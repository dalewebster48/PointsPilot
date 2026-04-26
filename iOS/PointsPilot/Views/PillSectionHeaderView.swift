import UIKit

final class PillSectionHeaderView: UICollectionReusableView {
    static let reuseIdentifier = "PillSectionHeaderView"

    private let titleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        titleLabel.font = .boldSystemFont(ofSize: 32)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        applyTheme()
    }

    func configure(title: String) {
        titleLabel.text = title
    }

    private func applyTheme() {
        backgroundColor = Theme.background
        titleLabel.textColor = Theme.primaryLabel
    }
}
