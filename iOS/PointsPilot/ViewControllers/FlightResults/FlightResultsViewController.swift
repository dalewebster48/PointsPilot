import UIKit

final class FlightResultsViewController: UIViewController {

    // MARK: - State

    enum State {
        case idle
        case loading
        case loaded
        case empty
        case error(message: String)
    }

    // MARK: - Outlets

    @IBOutlet private weak var sortStackView: UIStackView!
    @IBOutlet private weak var economyHeaderLabel: UILabel!
    @IBOutlet private weak var premiumHeaderLabel: UILabel!
    @IBOutlet private weak var upperHeaderLabel: UILabel!
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var emptyLabel: UILabel!
    @IBOutlet private weak var errorLabel: UILabel!
    @IBOutlet private weak var retryButton: UIButton!

    // MARK: - Properties

    private let viewModel: any FlightResultsViewModelProtocol
    private var displayedCellViewModels: [any FlightResultCellViewModelProtocol] = []
    private var pillButtons: [FlightSort.Field: UIButton] = [:]

    private var state: State = .idle {
        didSet { applyState() }
    }

    // MARK: - Init

    init(viewModel: any FlightResultsViewModelProtocol) {
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
        title = "Flight Deals"
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(
            UINib(nibName: "FlightDealCell", bundle: nil),
            forCellWithReuseIdentifier: FlightDealCell.reuseIdentifier
        )
        buildSortPills()
        applyTheme()
        viewModel.viewDelegate = self
    }

    // MARK: - Setup

    private func buildSortPills() {
        for field in FlightSort.Field.allCases {
            let button = makePillButton(field: field)
            sortStackView.addArrangedSubview(button)
            pillButtons[field] = button
        }
    }

    private func makePillButton(field: FlightSort.Field) -> UIButton {
        let button = UIButton(type: .custom)
        button.contentEdgeInsets = UIEdgeInsets(top: 7, left: 14, bottom: 7, right: 14)
        button.titleLabel?.font = .systemFont(ofSize: 13, weight: .semibold)
        button.layer.cornerRadius = 16
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(sortPillTapped(_:)), for: .touchUpInside)
        button.tag = FlightSort.Field.allCases.firstIndex(of: field) ?? 0
        return button
    }

    @objc private func sortPillTapped(_ sender: UIButton) {
        let field = FlightSort.Field.allCases[sender.tag]
        viewModel.didSelectSort(field)
    }

    // MARK: - Actions

    @IBAction private func retryTapped() {
        viewModel.didTapRetry()
    }

    // MARK: - Theme

    private func applyTheme() {
        view.backgroundColor = Theme.background
        collectionView.backgroundColor = Theme.background
        emptyLabel.textColor = Theme.secondaryLabel
        errorLabel.textColor = Theme.secondaryLabel
        retryButton.tintColor = Theme.primaryAccent
    }

    // MARK: - State Machine

    private func applyState() {
        switch state {
        case .idle:
            break

        case .loading:
            collectionView.isHidden = true
            emptyLabel.isHidden = true
            errorLabel.isHidden = true
            retryButton.isHidden = true
            activityIndicator.startAnimating()

        case .loaded:
            collectionView.isHidden = false
            emptyLabel.isHidden = true
            errorLabel.isHidden = true
            retryButton.isHidden = true
            activityIndicator.stopAnimating()
            collectionView.reloadData()

        case .empty:
            collectionView.isHidden = true
            emptyLabel.isHidden = false
            errorLabel.isHidden = true
            retryButton.isHidden = true
            activityIndicator.stopAnimating()

        case .error(let message):
            collectionView.isHidden = true
            emptyLabel.isHidden = true
            errorLabel.isHidden = false
            errorLabel.text = message
            retryButton.isHidden = false
            activityIndicator.stopAnimating()
        }
    }

    // MARK: - Sort UI

    private func updateSortAppearance(activeSort: FlightSort) {
        for (field, button) in pillButtons {
            let isActive = field == activeSort.field
            let title = isActive ? "\(field.label) \(activeSort.direction.arrow)" : field.label
            button.setTitle(title, for: .normal)
            button.backgroundColor = isActive ? Theme.primaryLabel : Theme.secondaryBackground
            button.setTitleColor(isActive ? Theme.background : Theme.secondaryLabel, for: .normal)
        }

        economyHeaderLabel.textColor = activeSort.field == .economy ? Theme.primaryAccent : Theme.secondaryLabel
        premiumHeaderLabel.textColor = activeSort.field == .premium ? Theme.primaryAccent : Theme.secondaryLabel
        upperHeaderLabel.textColor = activeSort.field == .upper ? Theme.primaryAccent : Theme.secondaryLabel
    }
}

// MARK: - UICollectionViewDataSource

extension FlightResultsViewController: UICollectionViewDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        displayedCellViewModels.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: FlightDealCell.reuseIdentifier,
            for: indexPath
        ) as! FlightDealCell
        cell.configure(viewModel: displayedCellViewModels[indexPath.item])
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension FlightResultsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        CGSize(width: collectionView.bounds.width, height: 96)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        if indexPath.item >= displayedCellViewModels.count - 5 {
            viewModel.didScrollNearEnd()
        }
    }
}

// MARK: - FlightResultsViewModelViewDelegate

extension FlightResultsViewController: FlightResultsViewModelViewDelegate {
    func bind(viewModel: any FlightResultsViewModelProtocol) {
        updateSortAppearance(activeSort: viewModel.activeSort)
        displayedCellViewModels = viewModel.cellViewModels

        if viewModel.isLoading && viewModel.cellViewModels.isEmpty {
            state = .loading
        } else if let error = viewModel.error, viewModel.cellViewModels.isEmpty {
            state = .error(message: error)
        } else if viewModel.cellViewModels.isEmpty {
            state = .empty
        } else {
            state = .loaded
        }
    }
}
