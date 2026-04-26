import UIKit

final class TripBuilderLocationPickerViewController: UIViewController {
    private enum Section: Int, CaseIterable {
        case countries
        case airports
    }

    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var summaryBanner: TripBuilderSummary!

    private let viewModel: any TripBuilderLocationPickerViewModelProtocol

    init(viewModel: any TripBuilderLocationPickerViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        summaryBanner.onDone = { [weak self] in
            self?.viewModel.didTapDone()
        }

        collectionView.register(
            UINib(nibName: "SelectablePillCell", bundle: nil),
            forCellWithReuseIdentifier: SelectablePillCell.reuseIdentifier
        )
        collectionView.register(
            PillSectionHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: PillSectionHeaderView.reuseIdentifier
        )
        collectionView.allowsMultipleSelection = true
        collectionView.dataSource = self
        collectionView.delegate = self

        let layout = LeftAlignedFlowLayout()
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
        collectionView.collectionViewLayout = layout

        applyTheme()
        viewModel.viewDelegate = self
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let desired = summaryBanner.bounds.height + 12
        if abs(collectionView.contentInset.bottom - desired) > 0.5 {
            collectionView.contentInset.bottom = desired
            collectionView.verticalScrollIndicatorInsets.bottom = desired
        }
    }

    private func applyTheme() {
        view.backgroundColor = Theme.background
        collectionView.backgroundColor = Theme.background
    }
}

// MARK: - TripBuilderLocationPickerViewModelViewDelegate

extension TripBuilderLocationPickerViewController: TripBuilderLocationPickerViewModelViewDelegate {
    func bind(viewModel: any TripBuilderLocationPickerViewModelProtocol) {
        if viewModel.isLoading {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
        summaryBanner.configure(viewModel: viewModel.summaryViewModel)
        view.setNeedsLayout()
        collectionView.reloadData()
        restoreSelections()
    }

    private func restoreSelections() {
        for (index, country) in viewModel.countries.enumerated() where viewModel.selectedCountries.contains(country) {
            let indexPath = IndexPath(item: index, section: Section.countries.rawValue)
            collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
        }
        for (index, airport) in viewModel.filteredAirports.enumerated() where viewModel.selectedAirportCodes.contains(airport.code) {
            let indexPath = IndexPath(item: index, section: Section.airports.rawValue)
            collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
        }
    }
}

// MARK: - UICollectionViewDataSource

extension TripBuilderLocationPickerViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        Section.allCases.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        switch Section(rawValue: section) {
        case .countries: return viewModel.countries.count
        case .airports: return viewModel.filteredAirports.count
        case .none: return 0
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: SelectablePillCell.reuseIdentifier,
            for: indexPath
        ) as! SelectablePillCell

        switch Section(rawValue: indexPath.section) {
        case .countries:
            cell.configure(title: viewModel.countries[indexPath.item])
        case .airports:
            let airport = viewModel.filteredAirports[indexPath.item]
            cell.configure(title: "\(airport.code) – \(airport.name)")
        case .none:
            break
        }
        return cell
    }

    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: PillSectionHeaderView.reuseIdentifier,
            for: indexPath
        ) as! PillSectionHeaderView

        switch Section(rawValue: indexPath.section) {
        case .countries: header.configure(title: "Pick a region")
        case .airports: header.configure(title: "Or an airport")
        case .none: break
        }
        return header
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension TripBuilderLocationPickerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        CGSize(width: collectionView.bounds.width, height: 36)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        switch Section(rawValue: indexPath.section) {
        case .countries:
            viewModel.didToggleCountry(viewModel.countries[indexPath.item])
        case .airports:
            viewModel.didToggleAirport(at: indexPath.item)
        case .none:
            break
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        didDeselectItemAt indexPath: IndexPath
    ) {
        switch Section(rawValue: indexPath.section) {
        case .countries:
            viewModel.didToggleCountry(viewModel.countries[indexPath.item])
        case .airports:
            viewModel.didToggleAirport(at: indexPath.item)
        case .none:
            break
        }
    }
}
