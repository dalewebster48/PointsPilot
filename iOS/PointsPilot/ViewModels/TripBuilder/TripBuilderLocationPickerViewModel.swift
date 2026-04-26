import Foundation

enum TripBuilderLocationPickerMode {
    case origin
    case destination
}

protocol TripBuilderLocationPickerDelegate: AnyObject {
    func didUpdateLocationSelection(
        countries: [String],
        airports: [Airport],
        for mode: TripBuilderLocationPickerMode
    )
}

protocol TripBuilderLocationPickerViewModelProtocol: AnyObject {
    var summaryViewModel: any TripBuilderSummaryViewModelProtocol { get }
    var countries: [String] { get }
    var selectedCountries: Set<String> { get }
    var filteredAirports: [Airport] { get }
    var selectedAirportCodes: Set<String> { get }
    var isLoading: Bool { get }

    var viewDelegate: (any TripBuilderLocationPickerViewModelViewDelegate)? { get set }

    func didToggleCountry(_ country: String)
    func didToggleAirport(at index: Int)
    func didTapDone()
}

protocol TripBuilderLocationPickerViewModelViewDelegate: AnyObject {
    func bind(viewModel: any TripBuilderLocationPickerViewModelProtocol)
}

final class TripBuilderLocationPickerViewModel: TripBuilderLocationPickerViewModelProtocol {
    private let airportService: any AirportService
    private let summaryProvider: any LocationSummaryProvider
    private let summaryFactory: any TripBuilderSummaryViewModelFactory
    private let navigator: any Navigator
    private let mode: TripBuilderLocationPickerMode
    private weak var pickerDelegate: (any TripBuilderLocationPickerDelegate)?

    private var allAirports: [Airport] = []

    var countries: [String] = [] { didSet { bind() } }
    var selectedCountries: Set<String> = [] { didSet { bind() } }
    var selectedAirportCodes: Set<String> = [] { didSet { bind() } }
    var isLoading: Bool = false { didSet { bind() } }

    var filteredAirports: [Airport] {
        if selectedCountries.isEmpty {
            return allAirports
        }
        return allAirports.filter { selectedCountries.contains($0.country) }
    }

    var summaryViewModel: any TripBuilderSummaryViewModelProtocol {
        let selectedAirports = allAirports.filter { selectedAirportCodes.contains($0.code) }
        let title: String
        switch mode {
        case .origin: title = "Where are you flying from?"
        case .destination: title = "Where are you flying to?"
        }
        return summaryFactory.makeTripBuilderSummaryViewModel(
            title: title,
            summary: summaryProvider.summary(
                for: mode,
                countries: Array(selectedCountries),
                airports: selectedAirports
            ),
            instruction: "Select regions or airports to narrow the search",
            buttonTitle: "Ok"
        )
    }
    
    weak var viewDelegate: (any TripBuilderLocationPickerViewModelViewDelegate)? {
        didSet { fetchAirports() }
    }

    init(
        airportService: any AirportService,
        summaryProvider: any LocationSummaryProvider,
        summaryFactory: any TripBuilderSummaryViewModelFactory,
        navigator: any Navigator,
        mode: TripBuilderLocationPickerMode,
        pickerDelegate: any TripBuilderLocationPickerDelegate,
        selectedCountries: [String],
        selectedAirports: [Airport]
    ) {
        self.airportService = airportService
        self.summaryProvider = summaryProvider
        self.summaryFactory = summaryFactory
        self.navigator = navigator
        self.mode = mode
        self.pickerDelegate = pickerDelegate
        self.allAirports = selectedAirports
        self.selectedCountries = Set(selectedCountries)
        self.selectedAirportCodes = Set(selectedAirports.map { $0.code })
    }

    func didToggleCountry(_ country: String) {
        if selectedCountries.contains(country) {
            selectedCountries.remove(country)
        } else {
            selectedCountries.insert(country)
        }
    }

    func didToggleAirport(at index: Int) {
        let airport = filteredAirports[index]
        if selectedAirportCodes.contains(airport.code) {
            selectedAirportCodes.remove(airport.code)
        } else {
            selectedAirportCodes.insert(airport.code)
        }
    }

    func didTapDone() {
        let selectedAirportsList = allAirports.filter { selectedAirportCodes.contains($0.code) }
        pickerDelegate?.didUpdateLocationSelection(
            countries: Array(selectedCountries),
            airports: selectedAirportsList,
            for: mode
        )
        
        navigator.dismiss()
    }

    private func fetchAirports() {
        isLoading = true
        Task { [weak self] in
            guard let self else { return }
            do {
                let airports = try await self.airportService.searchAirports(
                    filter: AirportSearchFilter(),
                    limit: 1000,
                    offset: 0
                )
                self.allAirports = airports
                self.countries = Array(Set(airports.map { $0.country })).sorted()
                self.isLoading = false
            } catch {
                self.isLoading = false
            }
        }
    }

    private func bind() {
        Task { @MainActor in
            viewDelegate?.bind(viewModel: self)
        }
    }
}
