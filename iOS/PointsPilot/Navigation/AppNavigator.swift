import UIKit

final class AppNavigator: NSObject, Navigator, UIAdaptivePresentationControllerDelegate {
    private var primaryNavigationController: UINavigationController?
    private var secondaryNavigationController: UINavigationController?
    private weak var presentedNavigationController: UINavigationController?
    private var viewControllerFactory: ViewControllerFactory?

    private var stack: [NavigationAction] = []

    private var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }

    func configure(with factory: ViewControllerFactory) {
        self.viewControllerFactory = factory
    }

    func bootstrap(window: UIWindow) {
        guard let factory = viewControllerFactory else {
            fatalError("ViewControllerFactory not configured on AppNavigator")
        }

        let primaryNav = UINavigationController(
            rootViewController: factory.makeTripBuilderViewController()
        )
        primaryNavigationController = primaryNav
        presentedNavigationController = primaryNav

        if isIPad {
            let secondaryNav = UINavigationController(
                rootViewController: factory.makeFlightResultsPlaceholderViewController()
            )
            secondaryNavigationController = secondaryNav
            window.rootViewController = factory.makeSidebarContainerViewController(
                primaryNav: primaryNav,
                secondaryNav: secondaryNav
            )
        } else {
            window.rootViewController = primaryNav
        }

        window.makeKeyAndVisible()
    }

    func navigate(_ action: NavigationAction) {
        guard let presentedNavigationController else { return }

        switch action {
        case .modal:
            break

        case .push(let route):
            if swapDetailColumnIfApplicable(route: route) { return }
            stack.append(action)
            let vc = makeViewController(for: route)
            presentedNavigationController.pushViewController(vc, animated: true)

        case .bottomSheet:
            break
        }
    }

    private func swapDetailColumnIfApplicable(route: NavigationRoute) -> Bool {
        guard case .flightResults(let filter) = route,
              let secondaryNav = secondaryNavigationController,
              let factory = viewControllerFactory else {
            return false
        }

        let vc = factory.makeFlightResultsViewController(filter: filter)
        secondaryNav.setViewControllers([vc], animated: false)
        return true
    }

    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
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
