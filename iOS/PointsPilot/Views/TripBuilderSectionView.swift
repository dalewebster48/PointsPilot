import UIKit

protocol TripBuilderSectionViewModel: AnyObject {
    var iconName: String { get }
    var title: String { get }
    var placeholder: String { get }
    var summary: String { get }

    func didTap()
    func updateWithFilter(_ filter: FlightSearchFilter)
}

final class TripBuilderSectionView: UIView {
    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var summaryLabel: UILabel!
    @IBOutlet private weak var chevronImageView: UIImageView!

    private var viewModel: (any TripBuilderSectionViewModel)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    func bind(viewModel: any TripBuilderSectionViewModel) {
        self.viewModel = viewModel
        iconImageView.image = UIImage(systemName: viewModel.iconName)
        titleLabel.text = viewModel.title

        let summary = viewModel.summary
        if summary.isEmpty {
            summaryLabel.text = viewModel.placeholder
            summaryLabel.textColor = Theme.secondaryLabel
        } else {
            summaryLabel.text = summary
            summaryLabel.textColor = Theme.primaryLabel
        }
    }

    @IBAction private func didTap() {
        viewModel?.didTap()
    }

    private func commonInit() {
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: Bundle(for: type(of: self)))
        guard let contentView = nib.instantiate(withOwner: self).first as? UIView else { return }
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(contentView)
        applyTheme()
    }

    private func applyTheme() {
        backgroundColor = Theme.secondaryBackground
        titleLabel?.textColor = Theme.primaryLabel
        summaryLabel?.textColor = Theme.secondaryLabel
        iconImageView?.tintColor = Theme.primaryAccent
        chevronImageView?.image = UIImage(systemName: "chevron.right")
        chevronImageView?.tintColor = Theme.secondaryLabel
    }
}
