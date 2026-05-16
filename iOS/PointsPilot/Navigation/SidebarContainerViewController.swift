import UIKit

final class SidebarContainerViewController: UIViewController {
    private let primaryNav: UINavigationController
    private let secondaryNav: UINavigationController
    private let primaryColumnWidth: CGFloat

    init(
        primaryNav: UINavigationController,
        secondaryNav: UINavigationController,
        primaryColumnWidth: CGFloat = 360
    ) {
        self.primaryNav = primaryNav
        self.secondaryNav = secondaryNav
        self.primaryColumnWidth = primaryColumnWidth
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Theme.background

        addChild(primaryNav)
        view.addSubview(primaryNav.view)
        primaryNav.didMove(toParent: self)

        addChild(secondaryNav)
        view.addSubview(secondaryNav.view)
        secondaryNav.didMove(toParent: self)

        primaryNav.view.translatesAutoresizingMaskIntoConstraints = false
        secondaryNav.view.translatesAutoresizingMaskIntoConstraints = false

        let separator = UIView()
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.backgroundColor = Theme.separator
        view.addSubview(separator)

        NSLayoutConstraint.activate([
            primaryNav.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            primaryNav.view.topAnchor.constraint(equalTo: view.topAnchor),
            primaryNav.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            primaryNav.view.widthAnchor.constraint(equalToConstant: primaryColumnWidth),

            separator.leadingAnchor.constraint(equalTo: primaryNav.view.trailingAnchor),
            separator.topAnchor.constraint(equalTo: view.topAnchor),
            separator.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            separator.widthAnchor.constraint(equalToConstant: 1.0 / UIScreen.main.scale),

            secondaryNav.view.leadingAnchor.constraint(equalTo: separator.trailingAnchor),
            secondaryNav.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            secondaryNav.view.topAnchor.constraint(equalTo: view.topAnchor),
            secondaryNav.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
}
