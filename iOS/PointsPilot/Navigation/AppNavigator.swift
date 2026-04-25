import UIKit

final class AppNavigator: NSObject, Navigator, UIAdaptivePresentationControllerDelegate {
    private var navigationController: UINavigationController?
    private weak var presentedNavigationController: UINavigationController?
    private weak var bottomSheetController: UIViewController?
    private var viewControllerFactory: ViewControllerFactory?

    func configure(with factory: ViewControllerFactory) {
        self.viewControllerFactory = factory
    }

    func setRootNavigationController(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.presentedNavigationController = navigationController
    }

    func navigate(_ action: NavigationAction) {
        guard let presentedNavigationController else { return }

        switch action {
        case .modal(let route):
            let vc = makeViewController(for: route)
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .formSheet
            nav.presentationController?.delegate = self
            presentedNavigationController.present(nav, animated: true)
            self.presentedNavigationController = nav

        case .push(let route):
            let vc = makeViewController(for: route)
            presentedNavigationController.pushViewController(vc, animated: true)

        case .bottomSheet(let route):
            let vc = makeViewController(for: route)
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .pageSheet
            if let sheet = nav.sheetPresentationController {
                let collapsedDetentIdentifier: UISheetPresentationController.Detent.Identifier = .init("collapsed")
                let collapsed = UISheetPresentationController.Detent.custom(
                    identifier: collapsedDetentIdentifier
                ) { _ in 100 }
                sheet.detents = [collapsed, .medium(), .large()]
                sheet.selectedDetentIdentifier = collapsedDetentIdentifier
                sheet.prefersGrabberVisible = true
                sheet.prefersScrollingExpandsWhenScrolledToEdge = false
                sheet.largestUndimmedDetentIdentifier = .medium
            }
            nav.presentationController?.delegate = self
            presentedNavigationController.present(nav, animated: true)
            self.bottomSheetController = nav
            self.presentedNavigationController = nav
        }
    }

    func presentationControllerShouldDismiss(
        _ presentationController: UIPresentationController
    ) -> Bool {
        presentationController.presentedViewController !== bottomSheetController
    }

    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        let presenting = presentationController.presentingViewController as? UINavigationController
        self.presentedNavigationController = presenting ?? navigationController
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

    private func makeViewController(for route: NavigationRoute) -> UIViewController {
        guard let viewControllerFactory else {
            fatalError("ViewControllerFactory not configured on AppNavigator")
        }

        switch route {
        case .searchFilter(let filterDelegate):
            return viewControllerFactory.makeSearchFilterViewController(
                filterDelegate: filterDelegate
            )

        case .airportPicker(let mode, let delegate):
            return viewControllerFactory.makeAirportPickerViewController(
                mode: mode,
                pickerDelegate: delegate
            )
        }
    }
}
