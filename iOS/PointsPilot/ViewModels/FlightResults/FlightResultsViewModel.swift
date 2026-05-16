import Foundation

protocol FlightResultsViewModelProtocol: AnyObject {
    var cellViewModels: [any FlightResultCellViewModelProtocol] { get }
    var isLoading: Bool { get }
    var hasMorePages: Bool { get }
    var error: String? { get }
    var activeFilter: FlightSearchFilter { get }
    var activeSort: FlightSort { get }

    var viewDelegate: (any FlightResultsViewModelViewDelegate)? { get set }

    func didScrollNearEnd()
    func didTapRetry()
    func didSelectSort(_ field: FlightSort.Field)
}

protocol FlightResultsViewModelViewDelegate: AnyObject {
    func bind(viewModel: any FlightResultsViewModelProtocol)
}

final class FlightResultsViewModel: FlightResultsViewModelProtocol {
    private let flightService: any FlightService
    private let navigator: any Navigator
    private let cellViewModelFactory: any FlightResultCellViewModelFactory
    private let hasInitialFilter: Bool
    private let pageSize = 20
    private var currentOffset = 0
    private var isLoadingPage = false
    private var flights: [Flight] = []
    private var maxEconomy: Int = 0
    private var maxPremium: Int = 0
    private var maxUpper: Int = 0

    weak var viewDelegate: (any FlightResultsViewModelViewDelegate)? {
        didSet {
            if !hasInitialFilter {
                presentSearchFilter()
            }
            fetchFlights(reset: true)
        }
    }

    var cellViewModels: [any FlightResultCellViewModelProtocol] = [] { didSet { bind() } }
    var isLoading: Bool = false { didSet { bind() } }
    var hasMorePages: Bool = false { didSet { bind() } }
    var error: String? = nil { didSet { bind() } }
    var activeSort: FlightSort = .initial { didSet { bind() } }

    private var baseFilter: FlightSearchFilter = .empty { didSet { bind() } }

    var activeFilter: FlightSearchFilter { baseFilter }

    init(
        flightService: any FlightService,
        navigator: any Navigator,
        cellViewModelFactory: any FlightResultCellViewModelFactory,
        initialFilter: FlightSearchFilter? = nil
    ) {
        self.flightService = flightService
        self.navigator = navigator
        self.cellViewModelFactory = cellViewModelFactory
        self.hasInitialFilter = initialFilter != nil

        if let initialFilter {
            baseFilter = initialFilter
        }
    }

    func didScrollNearEnd() {
        guard hasMorePages, !isLoadingPage else { return }
        fetchFlights(reset: false)
    }

    func didTapRetry() {
        fetchFlights(reset: true)
    }

    func didSelectSort(_ field: FlightSort.Field) {
        if field == activeSort.field {
            activeSort.direction = activeSort.direction.toggled
        } else {
            activeSort = FlightSort(field: field, direction: .asc)
        }
        fetchFlights(reset: true)
    }

    private func presentSearchFilter() {
        navigator.navigate(.bottomSheet(.searchFilter(filterDelegate: self)))
    }

    private func fetchFlights(reset: Bool) {
        if reset {
            currentOffset = 0
            flights = []
            cellViewModels = []
        }

        isLoadingPage = true
        isLoading = cellViewModels.isEmpty

        Task { [weak self] in
            guard let self else { return }
            do {
                let result = try await self.flightService.searchFlights(
                    filter: self.baseFilter,
                    sort: self.activeSort,
                    limit: self.pageSize,
                    offset: self.currentOffset
                )
                self.flights += result.data
                self.currentOffset += result.data.count
                self.hasMorePages = result.total > self.currentOffset
                self.maxEconomy = result.maxEconomy
                self.maxPremium = result.maxPremium
                self.maxUpper = result.maxUpper
                self.rebuildCellViewModels()
                self.error = nil
            } catch {
                self.error = error.localizedDescription
            }
            self.isLoadingPage = false
            self.isLoading = false
        }
    }

    private func rebuildCellViewModels() {
        cellViewModels = flights.map { flight in
            cellViewModelFactory.makeFlightResultCellViewModel(
                flight: flight,
                sort: activeSort,
                maxEconomy: maxEconomy,
                maxPremium: maxPremium,
                maxUpper: maxUpper
            )
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
        baseFilter = filter
        fetchFlights(reset: true)
    }

    func didClearFilter() {
        baseFilter = .empty
        fetchFlights(reset: true)
    }
}
