import Foundation

protocol SearchFilterDelegate: AnyObject {
    func didApplyFilter(_ filter: FlightSearchFilter)
    func didClearFilter()
}

protocol SearchFilterViewModelProtocol: AnyObject {
    var originAirport: Airport? { get }
    var destinationAirport: Airport? { get }
    var dateFrom: Date? { get }
    var dateTo: Date? { get }
    var economyCostMin: Int? { get }
    var economyCostMax: Int? { get }
    var economyDealOnly: Bool { get }
    var premiumCostMin: Int? { get }
    var premiumCostMax: Int? { get }
    var premiumDealOnly: Bool { get }
    var upperCostMin: Int? { get }
    var upperCostMax: Int? { get }
    var upperDealOnly: Bool { get }

    var viewDelegate: (any SearchFilterViewModelViewDelegate)? { get set }

    func didTapOriginAirport()
    func didTapDestinationAirport()
    func didChangeDateFrom(_ date: Date?)
    func didChangeDateTo(_ date: Date?)
    func didChangeEconomyCostMin(_ value: Int?)
    func didChangeEconomyCostMax(_ value: Int?)
    func didToggleEconomyDealOnly(_ value: Bool)
    func didChangePremiumCostMin(_ value: Int?)
    func didChangePremiumCostMax(_ value: Int?)
    func didTogglePremiumDealOnly(_ value: Bool)
    func didChangeUpperCostMin(_ value: Int?)
    func didChangeUpperCostMax(_ value: Int?)
    func didToggleUpperDealOnly(_ value: Bool)
    func didTapApply()
    func didTapClear()
}

protocol SearchFilterViewModelViewDelegate: AnyObject {
    func bind(viewModel: any SearchFilterViewModelProtocol)
}

final class SearchFilterViewModel: SearchFilterViewModelProtocol {
    private let navigator: any Navigator
    weak var filterDelegate: (any SearchFilterDelegate)?
    weak var viewDelegate: (any SearchFilterViewModelViewDelegate)?

    var originAirport: Airport? = nil { didSet { bind() } }
    var destinationAirport: Airport? = nil { didSet { bind() } }
    var dateFrom: Date? = nil { didSet { bind() } }
    var dateTo: Date? = nil { didSet { bind() } }
    var economyCostMin: Int? = nil { didSet { bind() } }
    var economyCostMax: Int? = nil { didSet { bind() } }
    var economyDealOnly: Bool = false { didSet { bind() } }
    var premiumCostMin: Int? = nil { didSet { bind() } }
    var premiumCostMax: Int? = nil { didSet { bind() } }
    var premiumDealOnly: Bool = false { didSet { bind() } }
    var upperCostMin: Int? = nil { didSet { bind() } }
    var upperCostMax: Int? = nil { didSet { bind() } }
    var upperDealOnly: Bool = false { didSet { bind() } }

    init(navigator: any Navigator) {
        self.navigator = navigator
    }

    func didTapOriginAirport() {
        navigator.navigate(.modal(.airportPicker(mode: .origin, delegate: self)))
    }

    func didTapDestinationAirport() {
        navigator.navigate(.modal(.airportPicker(mode: .destination, delegate: self)))
    }

    func didChangeDateFrom(_ date: Date?) { dateFrom = date }
    func didChangeDateTo(_ date: Date?) { dateTo = date }
    func didChangeEconomyCostMin(_ value: Int?) { economyCostMin = value }
    func didChangeEconomyCostMax(_ value: Int?) { economyCostMax = value }
    func didToggleEconomyDealOnly(_ value: Bool) { economyDealOnly = value }
    func didChangePremiumCostMin(_ value: Int?) { premiumCostMin = value }
    func didChangePremiumCostMax(_ value: Int?) { premiumCostMax = value }
    func didTogglePremiumDealOnly(_ value: Bool) { premiumDealOnly = value }
    func didChangeUpperCostMin(_ value: Int?) { upperCostMin = value }
    func didChangeUpperCostMax(_ value: Int?) { upperCostMax = value }
    func didToggleUpperDealOnly(_ value: Bool) { upperDealOnly = value }

    func didTapApply() {
        let filter = FlightSearchFilter(
            origins: originAirport.map { [$0.code] },
            destinations: destinationAirport.map { [$0.code] },
            dateFrom: dateFrom.map { DateFormatter.yearMonthDay.string(from: $0) },
            dateTo: dateTo.map { DateFormatter.yearMonthDay.string(from: $0) },
            economyCostMin: economyCostMin,
            economyCostMax: economyCostMax,
            economyDeal: economyDealOnly ? true : nil,
            premiumCostMin: premiumCostMin,
            premiumCostMax: premiumCostMax,
            premiumDeal: premiumDealOnly ? true : nil,
            upperCostMin: upperCostMin,
            upperCostMax: upperCostMax,
            upperDeal: upperDealOnly ? true : nil
        )
        filterDelegate?.didApplyFilter(filter)
    }

    func didTapClear() {
        originAirport = nil
        destinationAirport = nil
        dateFrom = nil
        dateTo = nil
        economyCostMin = nil
        economyCostMax = nil
        economyDealOnly = false
        premiumCostMin = nil
        premiumCostMax = nil
        premiumDealOnly = false
        upperCostMin = nil
        upperCostMax = nil
        upperDealOnly = false
        filterDelegate?.didClearFilter()
    }

    private func bind() {
        Task { @MainActor in
            viewDelegate?.bind(viewModel: self)
        }
    }
}

// MARK: - AirportPickerDelegate

extension SearchFilterViewModel: AirportPickerDelegate {
    func didSelectAirport(
        _ airport: Airport,
        for mode: AirportPickerMode
    ) {
        switch mode {
        case .origin:
            originAirport = airport
        case .destination:
            destinationAirport = airport
        }
    }
}
