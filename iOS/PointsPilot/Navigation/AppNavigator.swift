import UIKit

final class AppNavigator: NSObject, Navigator, UIAdaptivePresentationControllerDelegate {
    private var navigationController: UINavigationController?
    private weak var presentedNavigationController: UINavigationController?
    private var viewControllerFactory: ViewControllerFactory?

    private var stack: [NavigationAction] = []
    
    func configure(with factory: ViewControllerFactory) {
        self.viewControllerFactory = factory
    }

    func bootstrap(window: UIWindow) {
        let rootViewController = viewControllerFactory!.makeTripBuilderViewController()
        navigationController = UINavigationController(rootViewController: rootViewController)
        presentedNavigationController = navigationController
        
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }

    func navigate(_ action: NavigationAction) {
        guard let presentedNavigationController else { return }

        stack.append(action)
        
        switch action {
        case .modal(let route):
//            let vc = makeViewController(for: route)
//            let nav = UINavigationController(rootViewController: vc)
//            nav.modalPresentationStyle = .formSheet
//            nav.presentationController?.delegate = self
//            presentedNavigationController.present(nav, animated: true)
//            self.presentedNavigationController = nav
            break

        case .push(let route):
            let vc = makeViewController(for: route)
            presentedNavigationController.pushViewController(vc, animated: true)

        case .bottomSheet(let route):
            break
//            let vc = makeViewController(for: route)
//            let nav = UINavigationController(rootViewController: vc)
//            nav.modalPresentationStyle = .pageSheet
//            if let sheet = nav.sheetPresentationController {
//                let collapsedDetentIdentifier: UISheetPresentationController.Detent.Identifier = .init("collapsed")
//                let collapsed = UISheetPresentationController.Detent.custom(
//                    identifier: collapsedDetentIdentifier
//                ) { _ in 100 }
//                sheet.detents = [collapsed, .medium(), .large()]
//                sheet.selectedDetentIdentifier = collapsedDetentIdentifier
//                sheet.prefersGrabberVisible = true
//                sheet.prefersScrollingExpandsWhenScrolledToEdge = false
//                sheet.largestUndimmedDetentIdentifier = .medium
//            }
//            nav.presentationController?.delegate = self
//            presentedNavigationController.present(nav, animated: true)
//            self.presentedNavigationController = nav
        }
    }

    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
//        let presenting = presentationController.presentingViewController as? UINavigationController
//        self.presentedNavigationController = presenting ?? navigationController
    }

    func dismiss(completion: (() -> Void)? = nil) {
        let lastAction = stack.popLast()
        switch lastAction {
        case .push:
            presentedNavigationController?.popViewController(animated: true)
        default:
            break
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

        case .flightResults(let filter):
            return viewControllerFactory.makeFlightResultsViewController(
                filter: filter
            )

        case .tripBuilderLocationPicker(let mode, let delegate, let selectedCountries, let selectedAirports):
            return viewControllerFactory.makeTripBuilderLocationPickerViewController(
                mode: mode,
                delegate: delegate,
                selectedCountries: selectedCountries,
                selectedAirports: selectedAirports
            )

        case .tripBuilderDatePicker(let delegate, let dateFrom, let dateTo):
            return viewControllerFactory.makeTripBuilderDatePickerViewController(
                delegate: delegate,
                dateFrom: dateFrom,
                dateTo: dateTo
            )

        case .tripBuilderClassPicker(let delegate, let seatClass, let dealsOnly, let maxCost):
            return viewControllerFactory.makeTripBuilderClassPickerViewController(
                delegate: delegate,
                seatClass: seatClass,
                dealsOnly: dealsOnly,
                maxCost: maxCost
            )
        }
    }
}
