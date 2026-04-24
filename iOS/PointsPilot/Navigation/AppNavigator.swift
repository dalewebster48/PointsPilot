import UIKit

final class AppNavigator: Navigator {
    private var navigationController: UINavigationController?
    private weak var presentedNavigationController: UINavigationController?
    private var viewControllerFactory: ViewControllerFactory?

    func configure(with factory: ViewControllerFactory) {
        self.viewControllerFactory = factory
    }

    func setRootNavigationController(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.presentedNavigationController = navigationController
    }

    func navigate(to destination: AppDestination) {
        guard let viewControllerFactory, let presentedNavigationController else { return }

        switch destination {
        }
    }

    func dismiss(completion: (() -> Void)? = nil) {
        guard let presentedNavigationController else {
            completion?()
            return
        }

        let presenting = presentedNavigationController.presentingViewController as? UINavigationController

        presentedNavigationController.dismiss(animated: true) { [weak self] in
            self?.presentedNavigationController = presenting ?? self?.navigationController
            completion?()
        }
    }
}