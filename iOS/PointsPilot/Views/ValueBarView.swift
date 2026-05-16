import UIKit

final class ValueBarView: UIView {
    var fraction: CGFloat = 0 {
        didSet { setNeedsLayout() }
    }

    var fillColor: UIColor = .gray {
        didSet { fillLayer.backgroundColor = fillColor.cgColor }
    }

    private let fillLayer = CALayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        backgroundColor = UIColor.black.withAlphaComponent(0.05)
        layer.cornerRadius = 2
        clipsToBounds = true
        fillLayer.cornerRadius = 2
        layer.addSublayer(fillLayer)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        fillLayer.frame = CGRect(
            x: 0,
            y: 0,
            width: bounds.width * max(0, min(1, fraction)),
            height: bounds.height
        )
        CATransaction.commit()
    }
}
