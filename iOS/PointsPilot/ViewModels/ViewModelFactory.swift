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

    func makeFlightResultsViewModel(
        filter: FlightSearchFilter
    ) -> FlightResultsViewModel {
        FlightResultsViewModel(
            flightService: services.flightService,
            navigator: navigator,
            initialFilter: filter
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

    func makeTripBuilderViewModel() -> TripBuilderViewModel {
        TripBuilderViewModel(
            navigator: navigator,
            sectionFactory: self
        )
    }

    func makeTripBuilderLocationPickerViewModel(
        mode: TripBuilderLocationPickerMode,
        delegate: any TripBuilderLocationPickerDelegate,
        selectedCountries: [String],
        selectedAirports: [Airport]
    ) -> TripBuilderLocationPickerViewModel {
        TripBuilderLocationPickerViewModel(
            airportService: services.airportService,
            summaryProvider: LocationSummaryProviderImpl(),
            summaryFactory: self,
            navigator: navigator,
            mode: mode,
            pickerDelegate: delegate,
            selectedCountries: selectedCountries,
            selectedAirports: selectedAirports
        )
    }

    func makeTripBuilderDatePickerViewModel(
        delegate: any TripBuilderDatePickerDelegate,
        dateFrom: String?,
        dateTo: String?
    ) -> TripBuilderDatePickerViewModel {
        TripBuilderDatePickerViewModel(
            navigator: navigator,
            pickerDelegate: delegate,
            dateFrom: dateFrom,
            dateTo: dateTo
        )
    }

    func makeTripBuilderClassPickerViewModel(
        delegate: any TripBuilderClassPickerDelegate,
        seatClass: SeatClass?,
        dealsOnly: Bool,
        maxCost: Int?
    ) -> TripBuilderClassPickerViewModel {
        TripBuilderClassPickerViewModel(
            navigator: navigator,
            pickerDelegate: delegate,
            seatClass: seatClass,
            dealsOnly: dealsOnly,
            maxCost: maxCost
        )
    }
}

// MARK: - TripBuilderSummaryViewModelFactory

extension ViewModelFactory: TripBuilderSummaryViewModelFactory {
    func makeTripBuilderSummaryViewModel(
        title: String,
        summary: NSAttributedString,
        instruction: String,
        buttonTitle: String
    ) -> any TripBuilderSummaryViewModelProtocol {
        TripBuilderSummaryViewModel(
            title: title,
            summary: summary,
            instruction: instruction,
            buttonTitle: buttonTitle
        )
    }
}

// MARK: - TripBuilderSectionViewModelFactory

extension ViewModelFactory: TripBuilderSectionViewModelFactory {
    func makeLocationSectionViewModel(
        mode: TripBuilderLocationPickerMode,
        pickerDelegate: any TripBuilderLocationPickerDelegate
    ) -> any TripBuilderSectionViewModel {
        LocationSectionViewModel(
            navigator: navigator,
            summaryProvider: LocationSummaryProviderImpl(),
            mode: mode,
            pickerDelegate: pickerDelegate
        )
    }

    func makeDateSectionViewModel(
        pickerDelegate: any TripBuilderDatePickerDelegate
    ) -> any TripBuilderSectionViewModel {
        DateSectionViewModel(
            navigator: navigator,
            pickerDelegate: pickerDelegate
        )
    }

    func makeClassSectionViewModel(
        pickerDelegate: any TripBuilderClassPickerDelegate
    ) -> any TripBuilderSectionViewModel {
        ClassSectionViewModel(
            navigator: navigator,
            pickerDelegate: pickerDelegate
        )
    }
}
