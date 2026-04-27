import UIKit

final class TripBuilderDatePickerViewController: UIViewController {
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var summaryBanner: TripBuilderSummary!

    private let viewModel: any TripBuilderDatePickerViewModelProtocol
    private let pageDotsView = PageDotsView(dotCount: DatePickerPanel.allCases.count)
    private let panels: [DatePickerPanel] = DatePickerPanel.allCases

    private lazy var panelViews: [UIView] = panels.map(makePanelView(for:))

    private var lastReportedPanel: DatePickerPanel = .months

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
        applyTheme()
        setupCollectionView()
        setupPageDots()
        summaryBanner.onDone = { [weak self] in self?.viewModel.didTapDone() }
        viewModel.viewDelegate = self
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let bannerInset = summaryBanner.bounds.height + 12
        if abs(collectionView.contentInset.bottom - bannerInset) > 0.5 {
            collectionView.contentInset.bottom = bannerInset
            collectionView.verticalScrollIndicatorInsets.bottom = bannerInset
        }
    }

    private func applyTheme() {
        view.backgroundColor = Theme.background
        collectionView.backgroundColor = Theme.background
    }

    private func setupCollectionView() {
        collectionView.register(
            DatePickerPanelCell.self,
            forCellWithReuseIdentifier: DatePickerPanelCell.reuseIdentifier
        )
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.decelerationRate = .fast
        collectionView.showsVerticalScrollIndicator = false
        collectionView.alwaysBounceVertical = true
    }

    private func setupPageDots() {
        pageDotsView.translatesAutoresizingMaskIntoConstraints = false
        pageDotsView.onTap = { [weak self] index in
            self?.scrollToPanel(at: index, animated: true)
        }
        view.addSubview(pageDotsView)
        NSLayoutConstraint.activate([
            pageDotsView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            pageDotsView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 80)
        ])
    }

    private func makePanelView(for panel: DatePickerPanel) -> UIView {
        switch panel {
        case .months:
            let view = MonthGridInputView()
            view.configure(viewModel: viewModel.monthInputViewModel)
            return view
        case .range:
            let view = RangeSliderInputView()
            view.configure(viewModel: viewModel.rangeInputViewModel)
            return view
        case .calendar:
            let view = CalendarInputView()
            view.configure(viewModel: viewModel.calendarInputViewModel)
            return view
        }
    }

    private func title(for panel: DatePickerPanel) -> String {
        switch panel {
        case .months: return "Be vague"
        case .range: return "Be flexible"
        case .calendar: return "Be specific"
        }
    }

    private func panelOffsets() -> [CGFloat] {
        (0..<panels.count).compactMap { index in
            collectionView
                .layoutAttributesForItem(at: IndexPath(item: index, section: 0))?
                .frame
                .origin
                .y
        }
    }

    private func scrollToPanel(at index: Int, animated: Bool) {
        let offsets = panelOffsets()
        guard index < offsets.count else { return }
        collectionView.setContentOffset(CGPoint(x: 0, y: offsets[index]), animated: animated)
    }

    private func updateFocus(for currentY: CGFloat) {
        let offsets = panelOffsets()
        guard !offsets.isEmpty else { return }

        // Use the cell height as the fade reference, so the next panel reaches
        // the dim floor right as it disappears off the top of the screen.
        let pageHeight = max(collectionView.bounds.height, 1)

        var bestDistance = CGFloat.infinity
        var activeIndex = 0
        for (index, offset) in offsets.enumerated() {
            let distance = abs(offset - currentY)
            let normalised = min(distance / pageHeight, 1)
            let alpha = 0.28 + 0.72 * (1 - normalised)
            if let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? DatePickerPanelCell {
                cell.setFocusOpacity(alpha)
            }
            if distance < bestDistance {
                bestDistance = distance
                activeIndex = index
            }
        }

        let activePanel = panels[activeIndex]
        if activePanel != lastReportedPanel {
            lastReportedPanel = activePanel
            viewModel.didChangeFocusedPanel(activePanel)
            pageDotsView.activeIndex = activeIndex
        }
    }
}

// MARK: - TripBuilderDatePickerViewModelViewDelegate

extension TripBuilderDatePickerViewController: TripBuilderDatePickerViewModelViewDelegate {
    func bind(viewModel: any TripBuilderDatePickerViewModelProtocol) {
        summaryBanner.configure(viewModel: viewModel.summaryViewModel)
        pageDotsView.activeIndex = viewModel.focusedPanel.rawValue
        view.setNeedsLayout()
    }
}

// MARK: - UICollectionViewDataSource

extension TripBuilderDatePickerViewController: UICollectionViewDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        panels.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: DatePickerPanelCell.reuseIdentifier,
            for: indexPath
        ) as! DatePickerPanelCell
        let panel = panels[indexPath.item]
        cell.embed(panelView: panelViews[indexPath.item], title: title(for: panel))
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension TripBuilderDatePickerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let availableWidth = collectionView.bounds.width
        let horizontalInset: CGFloat = 40 // 20 left + 20 right (cell.embed padding)
        let panelView = panelViews[indexPath.item]
        let measuredHeight = panelView.systemLayoutSizeFitting(
            CGSize(width: max(availableWidth - horizontalInset, 1), height: 0),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        ).height
        let titleHeight: CGFloat = 40
        let titleToPanelSpacing: CGFloat = 16
        return CGSize(width: availableWidth, height: titleHeight + titleToPanelSpacing + measuredHeight)
    }
}

// MARK: - UIScrollViewDelegate (custom snap + fade)

extension TripBuilderDatePickerViewController {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateFocus(for: scrollView.contentOffset.y)
    }

    func scrollViewWillEndDragging(
        _ scrollView: UIScrollView,
        withVelocity velocity: CGPoint,
        targetContentOffset: UnsafeMutablePointer<CGPoint>
    ) {
        let offsets = panelOffsets()
        guard !offsets.isEmpty else { return }
        let proposedY = targetContentOffset.pointee.y

        // Pick the nearest panel anchor by default…
        var nearestIndex = 0
        var nearestDistance = CGFloat.infinity
        for (index, offset) in offsets.enumerated() {
            let distance = abs(offset - proposedY)
            if distance < nearestDistance {
                nearestDistance = distance
                nearestIndex = index
            }
        }

        // …then nudge in the velocity direction if the user flicked decisively
        // and the next/previous anchor is reachable.
        let velocityThreshold: CGFloat = 0.3
        if velocity.y > velocityThreshold,
           nearestIndex < offsets.count - 1,
           proposedY < offsets[nearestIndex + 1] {
            nearestIndex += 1
        } else if velocity.y < -velocityThreshold,
                  nearestIndex > 0,
                  proposedY > offsets[nearestIndex - 1] {
            nearestIndex -= 1
        }

        targetContentOffset.pointee.y = offsets[nearestIndex]
    }
}
