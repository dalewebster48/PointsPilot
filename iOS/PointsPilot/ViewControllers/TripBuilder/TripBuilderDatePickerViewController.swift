import UIKit

final class TripBuilderDatePickerViewController: UIViewController {
    @IBOutlet private weak var modeSegmentedControl: UISegmentedControl!
    @IBOutlet private weak var specificDatesContainer: UIView!
    @IBOutlet private weak var byMonthContainer: UIView!
    @IBOutlet private weak var flexibleRangeContainer: UIView!
    @IBOutlet private weak var dateFromPicker: UIDatePicker!
    @IBOutlet private weak var dateToPicker: UIDatePicker!
    @IBOutlet private weak var monthsCollectionView: UICollectionView!
    @IBOutlet private weak var rangeSlider: RangeSlider!
    @IBOutlet private weak var rangeLabel: UILabel!
    @IBOutlet private weak var summaryBanner: TripBuilderSummary!

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
        summaryBanner.onDone = { [weak self] in
            self?.viewModel.didTapDone()
        }

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

        rangeSlider.minimumValue = 0
        rangeSlider.maximumValue = Double(Self.maxDaysOut)
        rangeSlider.lowerValue = 0
        rangeSlider.upperValue = Double(Self.maxDaysOut)
        
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

    @IBAction private func rangeSliderChanged(_ sender: RangeSlider) {
        let startDate = Self.date(daysFromToday: Int(sender.lowerValue.rounded()))
        let endDate = Self.date(daysFromToday: Int(sender.upperValue.rounded()))
        viewModel.didChangeRangeStart(startDate)
        viewModel.didChangeRangeEnd(endDate)
        updateRangeLabel(start: startDate, end: endDate)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let desired = summaryBanner.bounds.height + 12
        if abs(monthsCollectionView.contentInset.bottom - desired) > 0.5 {
            monthsCollectionView.contentInset.bottom = desired
            monthsCollectionView.verticalScrollIndicatorInsets.bottom = desired
        }
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

    private func updateRangeLabel(start: Date, end: Date) {
        rangeLabel.text = "\(Self.displayFormatter.string(from: start)) – \(Self.displayFormatter.string(from: end))"
    }

    private static let maxDaysOut = 364

    private static let calendar = Calendar.current

    private static var today: Date {
        calendar.startOfDay(for: Date())
    }

    private static func date(daysFromToday days: Int) -> Date {
        calendar.date(byAdding: .day, value: days, to: today) ?? today
    }

    private static func days(from date: Date) -> Int {
        calendar.dateComponents([.day], from: today, to: calendar.startOfDay(for: date)).day ?? 0
    }

    private static let displayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
}

// MARK: - TripBuilderDatePickerViewModelViewDelegate

extension TripBuilderDatePickerViewController: TripBuilderDatePickerViewModelViewDelegate {
    func bind(viewModel: any TripBuilderDatePickerViewModelProtocol) {
        modeSegmentedControl.selectedSegmentIndex = viewModel.mode.rawValue
        updateContainerVisibility(for: viewModel.mode)
        summaryBanner.configure(viewModel: viewModel.summaryViewModel)
        view.setNeedsLayout()

        if let date = viewModel.dateFrom { dateFromPicker.date = date }
        if let date = viewModel.dateTo { dateToPicker.date = date }

        let lowerDays = viewModel.rangeStartDate.map { Self.days(from: $0) } ?? 0
        let upperDays = viewModel.rangeEndDate.map { Self.days(from: $0) } ?? Self.maxDaysOut
        rangeSlider.lowerValue = Double(max(0, min(Self.maxDaysOut, lowerDays)))
        rangeSlider.upperValue = Double(max(0, min(Self.maxDaysOut, upperDays)))
        updateRangeLabel(
            start: Self.date(daysFromToday: Int(rangeSlider.lowerValue.rounded())),
            end: Self.date(daysFromToday: Int(rangeSlider.upperValue.rounded()))
        )

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
