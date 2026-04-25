import UIKit

final class ViewControllerFactory {
    private let viewModelFactory: ViewModelFactory

    init(viewModelFactory: ViewModelFactory) {
        self.viewModelFactory = viewModelFactory
    }

    func makeFlightResultsViewController() -> FlightResultsViewController {
        let viewModel = viewModelFactory.makeFlightResultsViewModel()
        return FlightResultsViewController(viewModel: viewModel)
    }

    func makeSearchFilterViewController(
        filterDelegate: any SearchFilterDelegate
    ) -> SearchFilterViewController {
        let viewModel = viewModelFactory.makeSearchFilterViewModel(
            filterDelegate: filterDelegate
        )
        return SearchFilterViewController(viewModel: viewModel)
    }

    func makeAirportPickerViewController(
        mode: AirportPickerMode,
        pickerDelegate: any AirportPickerDelegate
    ) -> AirportPickerViewController {
        let viewModel = viewModelFactory.makeAirportPickerViewModel(
            mode: mode,
            pickerDelegate: pickerDelegate
        )
        return AirportPickerViewController(viewModel: viewModel)
    }
}
