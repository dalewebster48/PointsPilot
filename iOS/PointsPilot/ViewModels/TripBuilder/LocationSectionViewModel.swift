import Foundation

final class LocationSectionViewModel: TripBuilderSectionViewModel {
    private let navigator: any Navigator
    private let summaryProvider: any LocationSummaryProvider
    private let mode: TripBuilderLocationPickerMode
    private weak var pickerDelegate: (any TripBuilderLocationPickerDelegate)?

    let iconName: String
    let title: String
    let placeholder: String

    private var selectedCountries: [String] = []
    private var selectedAirports: [Airport] = []

    var summary: String {
        summaryProvider.summary(
            for: mode,
            countries: selectedCountries,
            airports: selectedAirports
        )
    }

    init(
        navigator: any Navigator,
        summaryProvider: any LocationSummaryProvider,
        mode: TripBuilderLocationPickerMode,
        pickerDelegate: any TripBuilderLocationPickerDelegate
    ) {
        self.navigator = navigator
        self.summaryProvider = summaryProvider
        self.mode = mode
        self.pickerDelegate = pickerDelegate

        switch mode {
        case .origin:
            iconName = "airplane.departure"
            title = "Where from?"
            placeholder = "Travelling from anywhere"
        case .destination:
            iconName = "airplane.arrival"
            title = "Where to?"
            placeholder = "Travelling to anywhere"
        }
    }

    func didTap() {
        navigator.navigate(.push(.tripBuilderLocationPicker(
            mode: mode,
            delegate: self,
            selectedCountries: selectedCountries,
            selectedAirports: selectedAirports
        )))
    }

    func updateWithFilter(_ filter: FlightSearchFilter) {}
}

// MARK: - TripBuilderLocationPickerDelegate

extension LocationSectionViewModel: TripBuilderLocationPickerDelegate {
    func didUpdateLocationSelection(
        countries: [String],
        airports: [Airport],
        for mode: TripBuilderLocationPickerMode
    ) {
        selectedCountries = countries
        selectedAirports = airports
        pickerDelegate?.didUpdateLocationSelection(
            countries: countries,
            airports: airports,
            for: mode
        )
    }
}
