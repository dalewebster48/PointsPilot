import Foundation

protocol TripBuilderSectionViewModelFactory: AnyObject {
    func makeLocationSectionViewModel(
        mode: TripBuilderLocationPickerMode,
        pickerDelegate: any TripBuilderLocationPickerDelegate
    ) -> any TripBuilderSectionViewModel

    func makeDateSectionViewModel(
        pickerDelegate: any TripBuilderDatePickerDelegate
    ) -> any TripBuilderSectionViewModel

    func makeClassSectionViewModel(
        pickerDelegate: any TripBuilderClassPickerDelegate
    ) -> any TripBuilderSectionViewModel
}

protocol TripBuilderViewModelProtocol: AnyObject {
    var originSection: any TripBuilderSectionViewModel { get }
    var destinationSection: any TripBuilderSectionViewModel { get }
    var dateSection: any TripBuilderSectionViewModel { get }
    var classSection: any TripBuilderSectionViewModel { get }

    var viewDelegate: (any TripBuilderViewModelViewDelegate)? { get set }

    func didTapSearch()
}

protocol TripBuilderViewModelViewDelegate: AnyObject {
    func bind(viewModel: any TripBuilderViewModelProtocol)
}

final class TripBuilderViewModel: TripBuilderViewModelProtocol {
    private let navigator: any Navigator
    private let sectionFactory: any TripBuilderSectionViewModelFactory
    private var filter = FlightSearchFilter.empty

    lazy var originSection: any TripBuilderSectionViewModel = {
        sectionFactory.makeLocationSectionViewModel(mode: .origin, pickerDelegate: self)
    }()

    lazy var destinationSection: any TripBuilderSectionViewModel = {
        sectionFactory.makeLocationSectionViewModel(mode: .destination, pickerDelegate: self)
    }()

    lazy var dateSection: any TripBuilderSectionViewModel = {
        sectionFactory.makeDateSectionViewModel(pickerDelegate: self)
    }()

    lazy var classSection: any TripBuilderSectionViewModel = {
        sectionFactory.makeClassSectionViewModel(pickerDelegate: self)
    }()

    weak var viewDelegate: (any TripBuilderViewModelViewDelegate)? {
        didSet { bind() }
    }

    init(
        navigator: any Navigator,
        sectionFactory: any TripBuilderSectionViewModelFactory
    ) {
        self.navigator = navigator
        self.sectionFactory = sectionFactory
    }

    func didTapSearch() {
        navigator.navigate(.push(.flightResults(filter: filter)))
    }

    private func bind() {
        Task { @MainActor in
            viewDelegate?.bind(viewModel: self)
        }
    }
}

// MARK: - TripBuilderLocationPickerDelegate

extension TripBuilderViewModel: TripBuilderLocationPickerDelegate {
    func didUpdateLocationSelection(
        countries: [String],
        airports: [Airport],
        for mode: TripBuilderLocationPickerMode
    ) {
        switch mode {
        case .origin:
            filter.setOrigins(countries: countries, airports: airports)
        case .destination:
            filter.setDestinations(countries: countries, airports: airports)
        }
        bind()
    }
}

// MARK: - TripBuilderDatePickerDelegate

extension TripBuilderViewModel: TripBuilderDatePickerDelegate {
    func didUpdateDateSelection(
        dateFrom: String?,
        dateTo: String?
    ) {
        filter.setDates(from: dateFrom, to: dateTo)
        dateSection.updateWithFilter(filter)
        bind()
    }
}

// MARK: - TripBuilderClassPickerDelegate

extension TripBuilderViewModel: TripBuilderClassPickerDelegate {
    func didUpdateClassSelection(
        seatClass: SeatClass?,
        dealsOnly: Bool,
        maxCost: Int?
    ) {
        filter.setClass(seatClass, dealsOnly: dealsOnly, maxCost: maxCost)
        classSection.updateWithFilter(filter)
        bind()
    }
}
