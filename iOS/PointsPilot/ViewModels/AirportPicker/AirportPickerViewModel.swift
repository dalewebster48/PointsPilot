import Foundation

enum AirportPickerMode {
    case origin
    case destination
}

protocol AirportPickerDelegate: AnyObject {
    func didSelectAirport(
        _ airport: Airport,
        for mode: AirportPickerMode
    )
}

protocol AirportPickerViewModelProtocol: AnyObject {
    var airports: [Airport] { get }
    var isLoading: Bool { get }

    var viewDelegate: (any AirportPickerViewModelViewDelegate)? { get set }

    func didUpdateSearchText(_ text: String)
    func didSelectAirport(at index: Int)
}

protocol AirportPickerViewModelViewDelegate: AnyObject {
    func bind(viewModel: any AirportPickerViewModelProtocol)
}

final class AirportPickerViewModel: AirportPickerViewModelProtocol {
    private let airportService: any AirportService
    private let navigator: any Navigator
    private let mode: AirportPickerMode
    private weak var pickerDelegate: (any AirportPickerDelegate)?
    private let debouncer = Debouncer(delay: 0.3)

    weak var viewDelegate: (any AirportPickerViewModelViewDelegate)? {
        didSet { fetchAirports(query: nil) }
    }

    var airports: [Airport] = [] {
        didSet { bind() }
    }

    var isLoading: Bool = false {
        didSet { bind() }
    }

    init(
        airportService: any AirportService,
        navigator: any Navigator,
        mode: AirportPickerMode,
        pickerDelegate: any AirportPickerDelegate
    ) {
        self.airportService = airportService
        self.navigator = navigator
        self.mode = mode
        self.pickerDelegate = pickerDelegate
    }

    func didUpdateSearchText(_ text: String) {
        let query = text.isEmpty ? nil : text
        debouncer.run { [weak self] in
            self?.fetchAirports(query: query)
        }
    }

    func didSelectAirport(at index: Int) {
        guard index < airports.count else { return }
        let airport = airports[index]
        pickerDelegate?.didSelectAirport(airport, for: mode)
        navigator.dismiss(completion: nil)
    }

    private func fetchAirports(query: String?) {
        Task { [weak self] in
            guard let self else { return }
            self.isLoading = true
            do {
                let filter = AirportSearchFilter(name: query)
                self.airports = try await self.airportService.searchAirports(
                    filter: filter,
                    limit: 50,
                    offset: 0
                )
            } catch {
                self.airports = []
            }
            self.isLoading = false
        }
    }

    private func bind() {
        Task { @MainActor in
            viewDelegate?.bind(viewModel: self)
        }
    }
}
