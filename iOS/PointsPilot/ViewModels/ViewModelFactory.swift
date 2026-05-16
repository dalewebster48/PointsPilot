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
            navigator: navigator,
            cellViewModelFactory: self
        )
    }

    func makeFlightResultsViewModel(
        filter: FlightSearchFilter
    ) -> FlightResultsViewModel {
        FlightResultsViewModel(
            flightService: services.flightService,
            navigator: navigator,
            cellViewModelFactory: self,
            initialFilter: filter
        )
    }

    func makeFlightResultsPlaceholderViewModel() -> FlightResultsViewModel {
        FlightResultsViewModel(
            flightService: services.flightService,
            navigator: navigator,
            cellViewModelFactory: self,
            placeholderMode: true
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
        let initialRange = DayRange(
            startDate: dateFrom.flatMap { DateFormatter.yearMonthDay.date(from: $0) },
            endDate: dateTo.flatMap { DateFormatter.yearMonthDay.date(from: $0) }
        )
        return TripBuilderDatePickerViewModel(
            navigator: navigator,
            summaryFactory: self,
            inputFactory: self,
            summaryProvider: DateSummaryProviderImpl(),
            pickerDelegate: delegate,
            initialRange: initialRange
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
            summaryFactory: self,
            summaryProvider: ClassSummaryProviderImpl(),
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

// MARK: - DatePickerInputViewModelFactory

extension ViewModelFactory: DatePickerInputViewModelFactory {
    func makeMonthGridInputViewModel(
        parentDelegate: any DatePickerPanelDelegate
    ) -> any MonthGridInputViewModelProtocol {
        MonthGridInputViewModel(parentDelegate: parentDelegate)
    }

    func makeRangeSliderInputViewModel(
        parentDelegate: any DatePickerPanelDelegate,
        initialRange: DayRange
    ) -> any RangeSliderInputViewModelProtocol {
        RangeSliderInputViewModel(
            parentDelegate: parentDelegate,
            initialRange: initialRange
        )
    }

    func makeCalendarInputViewModel(
        parentDelegate: any DatePickerPanelDelegate,
        initialRange: DayRange
    ) -> any CalendarInputViewModelProtocol {
        CalendarInputViewModel(
            parentDelegate: parentDelegate,
            initialRange: initialRange
        )
    }
}

// MARK: - FlightResultCellViewModelFactory

extension ViewModelFactory: FlightResultCellViewModelFactory {
    func makeFlightResultCellViewModel(
        flight: Flight,
        sort: FlightSort,
        maxEconomy: Int,
        maxPremium: Int,
        maxUpper: Int
    ) -> any FlightResultCellViewModelProtocol {
        FlightResultCellViewModel(
            flight: flight,
            sort: sort,
            maxEconomy: maxEconomy,
            maxPremium: maxPremium,
            maxUpper: maxUpper
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
            summaryProvider: DateSummaryProviderImpl(),
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
