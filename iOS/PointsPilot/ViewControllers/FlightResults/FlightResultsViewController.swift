import UIKit

final class FlightResultsViewController: UIViewController {

    // MARK: - State

    enum State {
        case idle
        case loading
        case loaded(flights: [Flight], hasMore: Bool)
        case empty
        case error(message: String)
    }

    // MARK: - Outlets

    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var emptyLabel: UILabel!
    @IBOutlet private weak var errorLabel: UILabel!
    @IBOutlet private weak var retryButton: UIButton!

    // MARK: - Properties

    private let viewModel: any FlightResultsViewModelProtocol
    private var displayedFlights: [Flight] = []

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
        applyTheme()
        viewModel.viewDelegate = self
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

        case .loaded(let flights, let hasMore):
            displayedFlights = flights
            collectionView.isHidden = false
            emptyLabel.isHidden = true
            errorLabel.isHidden = true
            retryButton.isHidden = true
            activityIndicator.stopAnimating()
            collectionView.reloadData()

        case .empty:
            displayedFlights = []
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
}

// MARK: - UICollectionViewDataSource

extension FlightResultsViewController: UICollectionViewDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        displayedFlights.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: FlightDealCell.reuseIdentifier,
            for: indexPath
        ) as! FlightDealCell
        cell.configure(with: displayedFlights[indexPath.item])
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
        CGSize(width: collectionView.bounds.width, height: 120)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        if indexPath.item >= displayedFlights.count - 5 {
            viewModel.didScrollNearEnd()
        }
    }
}

// MARK: - FlightResultsViewModelViewDelegate

extension FlightResultsViewController: FlightResultsViewModelViewDelegate {
    func bind(viewModel: any FlightResultsViewModelProtocol) {
        if viewModel.isLoading && viewModel.flights.isEmpty {
            state = .loading
        } else if let error = viewModel.error, viewModel.flights.isEmpty {
            state = .error(message: error)
        } else if viewModel.flights.isEmpty {
            state = .empty
        } else {
            state = .loaded(
                flights: viewModel.flights,
                hasMore: viewModel.hasMorePages
            )
        }
    }
}
