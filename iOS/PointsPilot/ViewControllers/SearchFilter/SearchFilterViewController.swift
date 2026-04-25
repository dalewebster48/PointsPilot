import UIKit

final class SearchFilterViewController: UIViewController {

    // MARK: - Outlets

    @IBOutlet private weak var originButton: UIButton!
    @IBOutlet private weak var destinationButton: UIButton!
    @IBOutlet private weak var dateFromPicker: UIDatePicker!
    @IBOutlet private weak var dateToPicker: UIDatePicker!
    @IBOutlet private weak var economyMinField: UITextField!
    @IBOutlet private weak var economyMaxField: UITextField!
    @IBOutlet private weak var economyDealSwitch: UISwitch!
    @IBOutlet private weak var premiumMinField: UITextField!
    @IBOutlet private weak var premiumMaxField: UITextField!
    @IBOutlet private weak var premiumDealSwitch: UISwitch!
    @IBOutlet private weak var upperMinField: UITextField!
    @IBOutlet private weak var upperMaxField: UITextField!
    @IBOutlet private weak var upperDealSwitch: UISwitch!
    @IBOutlet private weak var applyButton: UIButton!
    @IBOutlet private weak var clearButton: UIButton!

    // MARK: - Properties

    private let viewModel: any SearchFilterViewModelProtocol

    // MARK: - Init

    init(viewModel: any SearchFilterViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Filters"

        let numberFields = [
            economyMinField, economyMaxField,
            premiumMinField, premiumMaxField,
            upperMinField, upperMaxField
        ]
        numberFields.forEach { $0?.keyboardType = .numberPad }

        applyTheme()
        viewModel.viewDelegate = self
    }

    // MARK: - Actions

    @IBAction private func originTapped() {
        viewModel.didTapOriginAirport()
    }

    @IBAction private func destinationTapped() {
        viewModel.didTapDestinationAirport()
    }

    @IBAction private func dateFromChanged() {
        viewModel.didChangeDateFrom(dateFromPicker.date)
    }

    @IBAction private func dateToChanged() {
        viewModel.didChangeDateTo(dateToPicker.date)
    }

    @IBAction private func economyMinChanged() {
        viewModel.didChangeEconomyCostMin(economyMinField.text.flatMap { Int($0) })
    }

    @IBAction private func economyMaxChanged() {
        viewModel.didChangeEconomyCostMax(economyMaxField.text.flatMap { Int($0) })
    }

    @IBAction private func economyDealChanged() {
        viewModel.didToggleEconomyDealOnly(economyDealSwitch.isOn)
    }

    @IBAction private func premiumMinChanged() {
        viewModel.didChangePremiumCostMin(premiumMinField.text.flatMap { Int($0) })
    }

    @IBAction private func premiumMaxChanged() {
        viewModel.didChangePremiumCostMax(premiumMaxField.text.flatMap { Int($0) })
    }

    @IBAction private func premiumDealChanged() {
        viewModel.didTogglePremiumDealOnly(premiumDealSwitch.isOn)
    }

    @IBAction private func upperMinChanged() {
        viewModel.didChangeUpperCostMin(upperMinField.text.flatMap { Int($0) })
    }

    @IBAction private func upperMaxChanged() {
        viewModel.didChangeUpperCostMax(upperMaxField.text.flatMap { Int($0) })
    }

    @IBAction private func upperDealChanged() {
        viewModel.didToggleUpperDealOnly(upperDealSwitch.isOn)
    }

    @IBAction private func applyTapped() {
        viewModel.didTapApply()
    }

    @IBAction private func clearTapped() {
        viewModel.didTapClear()
    }

    // MARK: - Theme

    private func applyTheme() {
        view.backgroundColor = Theme.background
        originButton.tintColor = Theme.primaryAccent
        destinationButton.tintColor = Theme.primaryAccent
        applyButton.tintColor = Theme.primaryAccent
        clearButton.tintColor = Theme.destructive

        let fields = [
            economyMinField, economyMaxField,
            premiumMinField, premiumMaxField,
            upperMinField, upperMaxField
        ]
        fields.forEach {
            $0?.textColor = Theme.primaryLabel
            $0?.backgroundColor = Theme.secondaryBackground
        }

        economyDealSwitch.onTintColor = Theme.dealHighlight
        premiumDealSwitch.onTintColor = Theme.dealHighlight
        upperDealSwitch.onTintColor = Theme.dealHighlight
    }
}

// MARK: - SearchFilterViewModelViewDelegate

extension SearchFilterViewController: SearchFilterViewModelViewDelegate {
    func bind(viewModel: any SearchFilterViewModelProtocol) {
        originButton.setTitle(
            viewModel.originAirport.map { "\($0.code) – \($0.name)" } ?? "Select origin...",
            for: .normal
        )
        destinationButton.setTitle(
            viewModel.destinationAirport.map { "\($0.code) – \($0.name)" } ?? "Select destination...",
            for: .normal
        )

        if let dateFrom = viewModel.dateFrom {
            dateFromPicker.date = dateFrom
        }
        if let dateTo = viewModel.dateTo {
            dateToPicker.date = dateTo
        }

        economyMinField.text = viewModel.economyCostMin.map { String($0) }
        economyMaxField.text = viewModel.economyCostMax.map { String($0) }
        economyDealSwitch.isOn = viewModel.economyDealOnly
        premiumMinField.text = viewModel.premiumCostMin.map { String($0) }
        premiumMaxField.text = viewModel.premiumCostMax.map { String($0) }
        premiumDealSwitch.isOn = viewModel.premiumDealOnly
        upperMinField.text = viewModel.upperCostMin.map { String($0) }
        upperMaxField.text = viewModel.upperCostMax.map { String($0) }
        upperDealSwitch.isOn = viewModel.upperDealOnly
    }
}
