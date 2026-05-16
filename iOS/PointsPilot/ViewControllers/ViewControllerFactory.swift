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

    func makeFlightResultsViewController(
        filter: FlightSearchFilter
    ) -> FlightResultsViewController {
        let viewModel = viewModelFactory.makeFlightResultsViewModel(filter: filter)
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

    func makeTripBuilderViewController() -> TripBuilderViewController {
        let viewModel = viewModelFactory.makeTripBuilderViewModel()
        return TripBuilderViewController(viewModel: viewModel)
    }

    func makeTripBuilderLocationPickerViewController(
        mode: TripBuilderLocationPickerMode,
        delegate: any TripBuilderLocationPickerDelegate,
        selectedCountries: [String],
        selectedAirports: [Airport]
    ) -> TripBuilderLocationPickerViewController {
        let viewModel = viewModelFactory.makeTripBuilderLocationPickerViewModel(
            mode: mode,
            delegate: delegate,
            selectedCountries: selectedCountries,
            selectedAirports: selectedAirports
        )
        return TripBuilderLocationPickerViewController(viewModel: viewModel)
    }

    func makeTripBuilderDatePickerViewController(
        delegate: any TripBuilderDatePickerDelegate,
        dateFrom: String?,
        dateTo: String?
    ) -> TripBuilderDatePickerViewController {
        let viewModel = viewModelFactory.makeTripBuilderDatePickerViewModel(
            delegate: delegate,
            dateFrom: dateFrom,
            dateTo: dateTo
        )
        return TripBuilderDatePickerViewController(viewModel: viewModel)
    }

    func makeTripBuilderClassPickerViewController(
        delegate: any TripBuilderClassPickerDelegate,
        seatClass: SeatClass?,
        dealsOnly: Bool,
        maxCost: Int?
    ) -> TripBuilderClassPickerViewController {
        let viewModel = viewModelFactory.makeTripBuilderClassPickerViewModel(
            delegate: delegate,
            seatClass: seatClass,
            dealsOnly: dealsOnly,
            maxCost: maxCost
        )
        return TripBuilderClassPickerViewController(viewModel: viewModel)
    }
}
