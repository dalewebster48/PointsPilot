import Foundation

enum NavigationRoute {
    case searchFilter(filterDelegate: any SearchFilterDelegate)
    case airportPicker(
        mode: AirportPickerMode,
        delegate: any AirportPickerDelegate
    )
    case flightResults(filter: FlightSearchFilter)
    case tripBuilderLocationPicker(
        mode: TripBuilderLocationPickerMode,
        delegate: any TripBuilderLocationPickerDelegate,
        selectedCountries: [String],
        selectedAirports: [Airport]
    )
    case tripBuilderDatePicker(
        delegate: any TripBuilderDatePickerDelegate,
        dateFrom: String?,
        dateTo: String?
    )
    case tripBuilderClassPicker(
        delegate: any TripBuilderClassPickerDelegate,
        seatClass: SeatClass?,
        dealsOnly: Bool,
        maxCost: Int?
    )
}

enum NavigationAction {
    case modal(NavigationRoute)
    case push(NavigationRoute)
    case bottomSheet(NavigationRoute)
}
