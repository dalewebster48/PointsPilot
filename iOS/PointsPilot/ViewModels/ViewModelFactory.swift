import Foundation

final class ViewModelFactory {
    private let services: ServicesContainer
    private let navigator: any Navigator

    init(
        services: ServicesContainer,
        navigator: any Navigator
    ) {
        self.services = services
        self.navigator = navigator
    }

    func makeFlightResultsViewModel() -> FlightResultsViewModel {
        FlightResultsViewModel(
            flightService: services.flightService,
            navigator: navigator
        )
    }

    func makeSearchFilterViewModel(
        filterDelegate: any SearchFilterDelegate
    ) -> SearchFilterViewModel {
        let vm = SearchFilterViewModel(navigator: navigator)
        vm.filterDelegate = filterDelegate
        return vm
    }

    func makeAirportPickerViewModel(
        mode: AirportPickerMode,
        pickerDelegate: any AirportPickerDelegate
    ) -> AirportPickerViewModel {
        AirportPickerViewModel(
            airportService: services.airportService,
            navigator: navigator,
            mode: mode,
            pickerDelegate: pickerDelegate
        )
    }
}