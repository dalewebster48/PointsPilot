import UIKit

final class TripBuilderDatePickerViewController: UIViewController {
    @IBOutlet private weak var modeSegmentedControl: UISegmentedControl!
    @IBOutlet private weak var specificDatesContainer: UIView!
    @IBOutlet private weak var byMonthContainer: UIView!
    @IBOutlet private weak var flexibleRangeContainer: UIView!
    @IBOutlet private weak var dateFromPicker: UIDatePicker!
    @IBOutlet private weak var dateToPicker: UIDatePicker!
    @IBOutlet private weak var monthsCollectionView: UICollectionView!
    @IBOutlet private weak var rangeStartPicker: UIDatePicker!
    @IBOutlet private weak var rangeEndPicker: UIDatePicker!

    private let viewModel: any TripBuilderDatePickerViewModelProtocol

    private let monthNames = Calendar.current.shortMonthSymbols

    init(viewModel: any TripBuilderDatePickerViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "When?"
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Done",
            style: .done,
            target: self,
            action: #selector(didTapDone)
        )

        let pillNib = UINib(nibName: "SelectablePillCell", bundle: nil)
        monthsCollectionView.register(pillNib, forCellWithReuseIdentifier: SelectablePillCell.reuseIdentifier)
        monthsCollectionView.allowsMultipleSelection = true
        monthsCollectionView.dataSource = self
        monthsCollectionView.delegate = self

        if let layout = monthsCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
            layout.minimumInteritemSpacing = 8
            layout.minimumLineSpacing = 8
        }

        dateFromPicker.datePickerMode = .date
        dateToPicker.datePickerMode = .date
        rangeStartPicker.datePickerMode = .date
        rangeEndPicker.datePickerMode = .date

        applyTheme()
        viewModel.viewDelegate = self
    }

    @IBAction private func modeChanged(_ sender: UISegmentedControl) {
        guard let mode = DatePickerMode(rawValue: sender.selectedSegmentIndex) else { return }
        viewModel.didSelectMode(mode)
    }

    @IBAction private func dateFromChanged(_ sender: UIDatePicker) {
        viewModel.didChangeDateFrom(sender.date)
    }

    @IBAction private func dateToChanged(_ sender: UIDatePicker) {
        viewModel.didChangeDateTo(sender.date)
    }

    @IBAction private func rangeStartChanged(_ sender: UIDatePicker) {
        viewModel.didChangeRangeStart(sender.date)
    }

    @IBAction private func rangeEndChanged(_ sender: UIDatePicker) {
        viewModel.didChangeRangeEnd(sender.date)
    }

    @objc private func didTapDone() {
        viewModel.didTapDone()
    }

    private func applyTheme() {
        view.backgroundColor = Theme.background
        monthsCollectionView.backgroundColor = Theme.background
    }

    private func updateContainerVisibility(for mode: DatePickerMode) {
        specificDatesContainer.isHidden = mode != .specificDates
        byMonthContainer.isHidden = mode != .byMonth
        flexibleRangeContainer.isHidden = mode != .flexibleRange
    }
}

// MARK: - TripBuilderDatePickerViewModelViewDelegate

extension TripBuilderDatePickerViewController: TripBuilderDatePickerViewModelViewDelegate {
    func bind(viewModel: any TripBuilderDatePickerViewModelProtocol) {
        modeSegmentedControl.selectedSegmentIndex = viewModel.mode.rawValue
        updateContainerVisibility(for: viewModel.mode)

        if let date = viewModel.dateFrom { dateFromPicker.date = date }
        if let date = viewModel.dateTo { dateToPicker.date = date }
        if let date = viewModel.rangeStartDate { rangeStartPicker.date = date }
        if let date = viewModel.rangeEndDate { rangeEndPicker.date = date }

        monthsCollectionView.reloadData()
        for month in viewModel.selectedMonths {
            let indexPath = IndexPath(item: month - 1, section: 0)
            monthsCollectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
        }
    }
}

// MARK: - UICollectionViewDataSource

extension TripBuilderDatePickerViewController: UICollectionViewDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        12
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: SelectablePillCell.reuseIdentifier,
            for: indexPath
        ) as! SelectablePillCell
        cell.configure(title: monthNames[indexPath.item])
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension TripBuilderDatePickerViewController: UICollectionViewDelegate {
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        viewModel.didToggleMonth(indexPath.item + 1)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        didDeselectItemAt indexPath: IndexPath
    ) {
        viewModel.didToggleMonth(indexPath.item + 1)
    }
}
