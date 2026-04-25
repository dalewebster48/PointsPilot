import UIKit

final class AirportPickerViewController: UIViewController {

    // MARK: - Outlets

    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var emptyLabel: UILabel!

    // MARK: - Properties

    private let viewModel: any AirportPickerViewModelProtocol
    private var displayedAirports: [Airport] = []
    private let searchController = UISearchController(searchResultsController: nil)

    // MARK: - Init

    init(viewModel: any AirportPickerViewModelProtocol) {
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
        title = "Select Airport"

        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search airports..."
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(
            UINib(nibName: "AirportCell", bundle: nil),
            forCellReuseIdentifier: AirportCell.reuseIdentifier
        )

        applyTheme()
        viewModel.viewDelegate = self
    }

    // MARK: - Theme

    private func applyTheme() {
        view.backgroundColor = Theme.background
        tableView.backgroundColor = Theme.background
        emptyLabel.textColor = Theme.secondaryLabel
    }
}

// MARK: - UISearchResultsUpdating

extension AirportPickerViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        viewModel.didUpdateSearchText(searchController.searchBar.text ?? "")
    }
}

// MARK: - UITableViewDataSource

extension AirportPickerViewController: UITableViewDataSource {
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        displayedAirports.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: AirportCell.reuseIdentifier,
            for: indexPath
        ) as! AirportCell
        cell.configure(with: displayedAirports[indexPath.row])
        return cell
    }
}

// MARK: - UITableViewDelegate

extension AirportPickerViewController: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        tableView.deselectRow(at: indexPath, animated: true)
        viewModel.didSelectAirport(at: indexPath.row)
    }
}

// MARK: - AirportPickerViewModelViewDelegate

extension AirportPickerViewController: AirportPickerViewModelViewDelegate {
    func bind(viewModel: any AirportPickerViewModelProtocol) {
        if viewModel.isLoading && viewModel.airports.isEmpty {
            displayedAirports = []
            tableView.isHidden = true
            emptyLabel.isHidden = true
            activityIndicator.startAnimating()
        } else if viewModel.airports.isEmpty {
            displayedAirports = []
            tableView.isHidden = true
            emptyLabel.isHidden = false
            activityIndicator.stopAnimating()
        } else {
            displayedAirports = viewModel.airports
            tableView.isHidden = false
            emptyLabel.isHidden = true
            activityIndicator.stopAnimating()
            tableView.reloadData()
        }
    }
}
