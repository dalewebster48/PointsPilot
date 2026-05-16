import UIKit

final class TripBuilderClassPickerViewController: UIViewController {
    @IBOutlet private weak var classCollectionView: UICollectionView!
    @IBOutlet private weak var maxPointsContainer: UIView!
    @IBOutlet private weak var maxPointsValueLabel: UILabel!
    @IBOutlet private weak var maxPointsSlider: UISlider!
    @IBOutlet private weak var dealsContainer: UIView!
    @IBOutlet private weak var dealsCardButton: UIButton!
    @IBOutlet private weak var dealsOnlySwitch: UISwitch!
    @IBOutlet private weak var summaryBanner: TripBuilderSummary!

    private let viewModel: any TripBuilderClassPickerViewModelProtocol
    private let seatClasses: [SeatClass] = [.economy, .premium, .upper]

    private let pointsMin: Float = 5_000
    private let pointsMax: Float = 250_000
    private let pointsStep: Float = 5_000

    private let cabinSpacing: CGFloat = 10
    private let cabinHorizontalInset: CGFloat = 20

    init(viewModel: any TripBuilderClassPickerViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        summaryBanner.onDone = { [weak self] in self?.viewModel.didTapDone() }

        let pillNib = UINib(nibName: "SelectablePillCell", bundle: nil)
        classCollectionView.register(pillNib, forCellWithReuseIdentifier: SelectablePillCell.reuseIdentifier)
        classCollectionView.dataSource = self
        classCollectionView.delegate = self

        if let layout = classCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.estimatedItemSize = .zero
            layout.minimumInteritemSpacing = cabinSpacing
            layout.minimumLineSpacing = cabinSpacing
        }

        maxPointsSlider.minimumValue = pointsMin
        maxPointsSlider.maximumValue = pointsMax
        maxPointsSlider.value = pointsMax

        dealsCardButton.layer.cornerRadius = 18
        dealsCardButton.clipsToBounds = true

        applyTheme()
        viewModel.viewDelegate = self
    }

    @IBAction private func dealsOnlyChanged(_ sender: UISwitch) {
        viewModel.didToggleDealsOnly(sender.isOn)
        defaultMaxPointsIfNeeded()
    }

    @IBAction private func dealsCardTapped() {
        viewModel.didToggleDealsOnly(!viewModel.dealsOnly)
        defaultMaxPointsIfNeeded()
    }

    @IBAction private func maxPointsSliderChanged(_ sender: UISlider) {
        let rounded = (sender.value / pointsStep).rounded() * pointsStep
        sender.value = rounded
        viewModel.didChangeMaxCost(Int(rounded))
    }

    private func defaultMaxPointsIfNeeded() {
        guard viewModel.selectedClass != nil,
              !viewModel.dealsOnly,
              viewModel.maxCost == nil else { return }
        viewModel.didChangeMaxCost(Int(pointsMax))
    }

    private func applyTheme() {
        view.backgroundColor = Theme.background
        classCollectionView.backgroundColor = Theme.background
        maxPointsSlider.minimumTrackTintColor = Theme.primaryAccent
        dealsCardButton.backgroundColor = Theme.secondaryBackground
    }
}

// MARK: - TripBuilderClassPickerViewModelViewDelegate

extension TripBuilderClassPickerViewController: TripBuilderClassPickerViewModelViewDelegate {
    func bind(viewModel: any TripBuilderClassPickerViewModelProtocol) {
        let hasClass = viewModel.selectedClass != nil
        let dim: CGFloat = hasClass ? 1.0 : 0.4

        maxPointsContainer.alpha = dim
        maxPointsContainer.isUserInteractionEnabled = hasClass
        dealsContainer.alpha = dim
        dealsContainer.isUserInteractionEnabled = hasClass

        maxPointsContainer.isHidden = hasClass && viewModel.dealsOnly

        dealsOnlySwitch.isOn = viewModel.dealsOnly

        let displayCost = viewModel.maxCost ?? Int(pointsMax)
        maxPointsSlider.value = Float(displayCost)
        maxPointsValueLabel.text = "\(displayCost.formatted()) pts"

        classCollectionView.reloadData()
        summaryBanner.configure(viewModel: viewModel.summaryViewModel)
    }
}

// MARK: - UICollectionViewDataSource

extension TripBuilderClassPickerViewController: UICollectionViewDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        seatClasses.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: SelectablePillCell.reuseIdentifier,
            for: indexPath
        ) as! SelectablePillCell
        let seatClass = seatClasses[indexPath.item]
        cell.configure(
            title: seatClass.displayName,
            size: .large
        )
        cell.displayState = viewModel.selectedClass == seatClass ? .selected : .normal
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension TripBuilderClassPickerViewController: UICollectionViewDelegate {
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        collectionView.deselectItem(at: indexPath, animated: false)
        viewModel.didSelectClass(seatClasses[indexPath.item])
        defaultMaxPointsIfNeeded()
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension TripBuilderClassPickerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let width = (collectionView.bounds.width - cabinSpacing) / 2
        return CGSize(width: width.rounded(.down), height: 62)
    }
}

private extension SeatClass {
    var displayName: String {
        switch self {
        case .economy: return "Economy"
        case .premium: return "Premium econ."
        case .upper:   return "Upper"
        }
    }
}
