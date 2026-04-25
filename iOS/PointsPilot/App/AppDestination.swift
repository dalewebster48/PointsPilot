import Foundation

enum NavigationRoute {
    case searchFilter(filterDelegate: any SearchFilterDelegate)
    case airportPicker(
        mode: AirportPickerMode,
        delegate: any AirportPickerDelegate
    )
}

enum NavigationAction {
    case modal(NavigationRoute)
    case push(NavigationRoute)
    case bottomSheet(NavigationRoute)
}
