import Foundation

protocol FlightResultsViewModelProtocol: AnyObject {
    var flights: [Flight] { get }
    var isLoading: Bool { get }
    var hasMorePages: Bool { get }
    var error: String? { get }
    var activeFilter: FlightSearchFilter { get }

    var viewDelegate: (any FlightResultsViewModelViewDelegate)? { get set }

    func didScrollNearEnd()
    func didTapRetry()
}

protocol FlightResultsViewModelViewDelegate: AnyObject {
    func bind(viewModel: any FlightResultsViewModelProtocol)
}

final class FlightResultsViewModel: FlightResultsViewModelProtocol {
    private let flightService: any FlightService
    private let navigator: any Navigator
    private let pageSize = 20
    private var currentOffset = 0
    private var isLoadingPage = false

    weak var viewDelegate: (any FlightResultsViewModelViewDelegate)? {
        didSet {
            presentSearchFilter()
            fetchFlights(reset: true)
        }
    }

    var flights: [Flight] = [] { didSet { bind() } }
    var isLoading: Bool = false { didSet { bind() } }
    var hasMorePages: Bool = false { didSet { bind() } }
    var error: String? = nil { didSet { bind() } }
    var activeFilter: FlightSearchFilter = .empty { didSet { bind() } }

    init(
        flightService: any FlightService,
        navigator: any Navigator
    ) {
        self.flightService = flightService
        self.navigator = navigator
    }

    func didScrollNearEnd() {
        guard hasMorePages, !isLoadingPage else { return }
        fetchFlights(reset: false)
    }

    func didTapRetry() {
        fetchFlights(reset: true)
    }

    private func presentSearchFilter() {
        navigator.navigate(.bottomSheet(.searchFilter(filterDelegate: self)))
    }

    private func fetchFlights(reset: Bool) {
        if reset {
            currentOffset = 0
            flights = []
        }

        isLoadingPage = true
        isLoading = flights.isEmpty

        Task { [weak self] in
            guard let self else { return }
            do {
                let result = try await self.flightService.searchFlights(
                    filter: self.activeFilter,
                    limit: self.pageSize,
                    offset: self.currentOffset
                )
                self.flights += result.data
                self.currentOffset += result.data.count
                self.hasMorePages = (result.total ?? 0) > self.currentOffset
                self.error = nil
            } catch {
                self.error = error.localizedDescription
            }
            self.isLoadingPage = false
            self.isLoading = false
        }
    }

    private func bind() {
        Task { @MainActor in
            viewDelegate?.bind(viewModel: self)
        }
    }
}

// MARK: - SearchFilterDelegate

extension FlightResultsViewModel: SearchFilterDelegate {
    func didApplyFilter(_ filter: FlightSearchFilter) {
        activeFilter = filter
        fetchFlights(reset: true)
    }

    func didClearFilter() {
        activeFilter = .empty
        fetchFlights(reset: true)
    }
}
