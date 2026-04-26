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

    var selectedClass: SeatClass? { didSet { bind() } }
    var dealsOnly: Bool = false { didSet { bind() } }
    var maxCost: Int? { didSet { bind() } }

    weak var viewDelegate: (any TripBuilderClassPickerViewModelViewDelegate)? {
        didSet { bind() }
    }

    init(
        navigator: Navigator,
        pickerDelegate: any TripBuilderClassPickerDelegate,
        seatClass: SeatClass?,
        dealsOnly: Bool,
        maxCost: Int?
    ) {
        self.navigator = navigator
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
