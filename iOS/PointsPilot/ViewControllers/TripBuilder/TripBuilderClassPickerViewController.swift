import UIKit

final class TripBuilderClassPickerViewController: UIViewController {
    @IBOutlet private weak var classCollectionView: UICollectionView!
    @IBOutlet private weak var optionsContainer: UIView!
    @IBOutlet private weak var dealsOnlySwitch: UISwitch!
    @IBOutlet private weak var maxCostTextField: UITextField!
    @IBOutlet private weak var maxCostContainer: UIView!

    private let viewModel: any TripBuilderClassPickerViewModelProtocol
    private let seatClasses: [SeatClass] = [.economy, .premium, .upper]

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
        title = "How?"
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Done",
            style: .done,
            target: self,
            action: #selector(didTapDone)
        )

        let pillNib = UINib(nibName: "SelectablePillCell", bundle: nil)
        classCollectionView.register(pillNib, forCellWithReuseIdentifier: SelectablePillCell.reuseIdentifier)
        classCollectionView.dataSource = self
        classCollectionView.delegate = self

        if let layout = classCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
            layout.minimumInteritemSpacing = 8
            layout.minimumLineSpacing = 8
        }

        maxCostTextField.keyboardType = .numberPad
        maxCostTextField.addTarget(self, action: #selector(maxCostChanged), for: .editingChanged)

        applyTheme()
        viewModel.viewDelegate = self
    }

    @IBAction private func dealsOnlyChanged(_ sender: UISwitch) {
        viewModel.didToggleDealsOnly(sender.isOn)
    }

    @objc private func maxCostChanged() {
        let value = maxCostTextField.text.flatMap { Int($0) }
        viewModel.didChangeMaxCost(value)
    }

    @objc private func didTapDone() {
        viewModel.didTapDone()
    }

    private func applyTheme() {
        view.backgroundColor = Theme.background
        classCollectionView.backgroundColor = Theme.background
    }
}

// MARK: - TripBuilderClassPickerViewModelViewDelegate

extension TripBuilderClassPickerViewController: TripBuilderClassPickerViewModelViewDelegate {
    func bind(viewModel: any TripBuilderClassPickerViewModelProtocol) {
        optionsContainer.isHidden = viewModel.selectedClass == nil
        dealsOnlySwitch.isOn = viewModel.dealsOnly
        maxCostContainer.isHidden = viewModel.dealsOnly

        if let maxCost = viewModel.maxCost {
            maxCostTextField.text = String(maxCost)
        } else {
            maxCostTextField.text = nil
        }

        classCollectionView.reloadData()
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
        cell.configure(title: seatClass.rawValue.capitalized)
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
    }
}
