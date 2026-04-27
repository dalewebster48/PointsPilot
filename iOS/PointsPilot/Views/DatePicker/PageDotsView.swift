import UIKit

final class PageDotsView: UIView {
    private let inactiveSize: CGFloat = 6
    private let activeSize: CGFloat = 22

    private let stack = UIStackView()
    private var dotViews: [UIView] = []
    private var dotHeightConstraints: [NSLayoutConstraint] = []

    var activeIndex: Int = 0 {
        didSet { applyActive(animated: true) }
    }

    var onTap: ((Int) -> Void)?

    private let dotCount: Int

    init(dotCount: Int) {
        self.dotCount = dotCount
        super.init(frame: .zero)
        commonInit()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func commonInit() {
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false

        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        for index in 0..<dotCount {
            let dot = UIView()
            dot.translatesAutoresizingMaskIntoConstraints = false
            dot.layer.cornerRadius = 3
            dot.backgroundColor = inactiveColor
            dot.isUserInteractionEnabled = true
            dot.tag = index

            let height = dot.heightAnchor.constraint(equalToConstant: inactiveSize)
            dotHeightConstraints.append(height)
            NSLayoutConstraint.activate([
                dot.widthAnchor.constraint(equalToConstant: inactiveSize),
                height
            ])

            let recogniser = UITapGestureRecognizer(target: self, action: #selector(didTapDot(_:)))
            dot.addGestureRecognizer(recogniser)

            dotViews.append(dot)
            stack.addArrangedSubview(dot)
        }

        applyActive(animated: false)
    }

    @objc private func didTapDot(_ sender: UITapGestureRecognizer) {
        guard let index = sender.view?.tag else { return }
        onTap?(index)
    }

    private func applyActive(animated: Bool) {
        for (index, dot) in dotViews.enumerated() {
            let isActive = index == activeIndex
            dotHeightConstraints[index].constant = isActive ? activeSize : inactiveSize
            dot.backgroundColor = isActive ? Theme.primaryAccent : inactiveColor
        }

        guard animated else { return }
        UIView.animate(
            withDuration: 0.28,
            delay: 0,
            usingSpringWithDamping: 0.6,
            initialSpringVelocity: 0,
            options: [.curveEaseOut],
            animations: { self.layoutIfNeeded() }
        )
    }

    private var inactiveColor: UIColor {
        UIColor.label.withAlphaComponent(0.18)
    }
}
