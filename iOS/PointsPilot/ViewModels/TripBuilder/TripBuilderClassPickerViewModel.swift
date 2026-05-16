import Foundation

protocol TripBuilderClassPickerDelegate: AnyObject {
    func didUpdateClassSelection(
        seatClass: SeatClass?,
        dealsOnly: Bool,
        maxCost: Int?
    )
}

protocol TripBuilderClassPickerViewModelProtocol: AnyObject {
    var selectedClass: SeatClass? { get }
    var dealsOnly: Bool { get }
    var maxCost: Int? { get }
    var summaryViewModel: any TripBuilderSummaryViewModelProtocol { get }

    var viewDelegate: (any TripBuilderClassPickerViewModelViewDelegate)? { get set }

    func didSelectClass(_ seatClass: SeatClass)
    func didToggleDealsOnly(_ value: Bool)
    func didChangeMaxCost(_ value: Int?)
    func didTapDone()
}

protocol TripBuilderClassPickerViewModelViewDelegate: AnyObject {
    func bind(viewModel: any TripBuilderClassPickerViewModelProtocol)
}

final class TripBuilderClassPickerViewModel: TripBuilderClassPickerViewModelProtocol {
    private weak var pickerDelegate: (any TripBuilderClassPickerDelegate)?
    private let navigator: Navigator
    private let summaryFactory: any TripBuilderSummaryViewModelFactory
    private let summaryProvider: any ClassSummaryProvider

    var selectedClass: SeatClass? { didSet { bind() } }
    var dealsOnly: Bool = false { didSet { bind() } }
    var maxCost: Int? { didSet { bind() } }

    var summaryViewModel: any TripBuilderSummaryViewModelProtocol {
        summaryFactory.makeTripBuilderSummaryViewModel(
            title: "How are you flying?",
            summary: summaryProvider.summary(
                seatClass: selectedClass,
                dealsOnly: dealsOnly,
                maxCost: maxCost
            ),
            instruction: "Pick a class and any deal preferences",
            buttonTitle: "Ok"
        )
    }

    weak var viewDelegate: (any TripBuilderClassPickerViewModelViewDelegate)? {
        didSet { bind() }
    }

    init(
        navigator: Navigator,
        summaryFactory: any TripBuilderSummaryViewModelFactory,
        summaryProvider: any ClassSummaryProvider,
        pickerDelegate: any TripBuilderClassPickerDelegate,
        seatClass: SeatClass?,
        dealsOnly: Bool,
        maxCost: Int?
    ) {
        self.navigator = navigator
        self.summaryFactory = summaryFactory
        self.summaryProvider = summaryProvider
        self.pickerDelegate = pickerDelegate
        self.selectedClass = seatClass
        self.dealsOnly = dealsOnly
        self.maxCost = maxCost
    }

    func didSelectClass(_ seatClass: SeatClass) {
        if selectedClass == seatClass {
            selectedClass = nil
        } else {
            selectedClass = seatClass
        }
    }

    func didToggleDealsOnly(_ value: Bool) {
        dealsOnly = value
        if dealsOnly {
            maxCost = nil
        }
    }

    func didChangeMaxCost(_ value: Int?) {
        maxCost = value
    }

    func didTapDone() {
        pickerDelegate?.didUpdateClassSelection(
            seatClass: selectedClass,
            dealsOnly: dealsOnly,
            maxCost: maxCost
        )
        
        navigator.dismiss()
    }

    private func bind() {
        Task { @MainActor in
            viewDelegate?.bind(viewModel: self)
        }
    }
}
