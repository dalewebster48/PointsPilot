import UIKit

final class TripBuilderSummary: UIView {
    @IBOutlet private weak var labelStackView: UIStackView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var summaryLabel: UILabel!
    @IBOutlet private weak var doneButton: UIButton!
    @IBOutlet private weak var instructionLabel: UILabel!
    @IBOutlet private weak var firstDivider: UIView!
    @IBOutlet private weak var secondDivider: UIView!

    private weak var contentView: UIView?

    var onDone: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    func configure(viewModel: any TripBuilderSummaryViewModelProtocol) {
        titleLabel.text = viewModel.title
        summaryLabel.text = viewModel.summary
        instructionLabel.text = viewModel.instruction
        doneButton.setTitle(viewModel.buttonTitle, for: .normal)
    }

    @IBAction private func didTapDone() {
        onDone?()
    }

    private func commonInit() {
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: Bundle(for: type(of: self)))
        guard let contentView = nib.instantiate(withOwner: self).first as? UIView else { return }
        contentView.translatesAutoresizingMaskIntoConstraints = false

        let effect: UIVisualEffect
        if #available(iOS 26.0, *) {
            effect = UIGlassEffect()
        } else {
            effect = UIBlurEffect(style: .systemThinMaterial)
        }
        let effectView = UIVisualEffectView(effect: effect)
        effectView.translatesAutoresizingMaskIntoConstraints = false
        effectView.layer.cornerRadius = 22
        effectView.layer.cornerCurve = .continuous
        effectView.clipsToBounds = true

        addSubview(effectView)
        effectView.contentView.addSubview(contentView)
        NSLayoutConstraint.activate([
            effectView.topAnchor.constraint(equalTo: topAnchor),
            effectView.leadingAnchor.constraint(equalTo: leadingAnchor),
            effectView.trailingAnchor.constraint(equalTo: trailingAnchor),
            effectView.bottomAnchor.constraint(equalTo: bottomAnchor),
            contentView.topAnchor.constraint(equalTo: effectView.contentView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: effectView.contentView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: effectView.contentView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: effectView.contentView.bottomAnchor)
        ])
        self.contentView = contentView
        
        // custom spacing
        labelStackView.setCustomSpacing(8, after: firstDivider)
        labelStackView.setCustomSpacing(8, after: instructionLabel)
        labelStackView.setCustomSpacing(24, after: summaryLabel)

        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.6
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 24
        clipsToBounds = false

        applyTheme()
    }

    private func applyTheme() {
        backgroundColor = .clear
        contentView?.backgroundColor = .clear
        titleLabel?.textColor = Theme.primaryLabel
        summaryLabel?.textColor = Theme.primaryLabel
        doneButton?.backgroundColor = Theme.primaryAccent
        doneButton?.setTitleColor(.white, for: .normal)
        doneButton?.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        doneButton?.layer.cornerRadius = 14
        doneButton?.layer.cornerCurve = .continuous
        
        firstDivider.backgroundColor = Theme.separator
        secondDivider.backgroundColor = Theme.separator
    }
}
