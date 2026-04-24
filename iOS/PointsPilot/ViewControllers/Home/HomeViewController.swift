import UIKit

final class HomeViewController: UIViewController {

    // MARK: - State

    enum State {
        case idle
        case loaded(title: String)
    }

    // MARK: - Properties

    private let viewModel: HomeViewModel
    private let titleLabel = UILabel()

    private var state: State = .idle {
        didSet { applyState() }
    }

    // MARK: - Init

    init(viewModel: HomeViewModel) {
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
        setupUI()
        viewModel.viewDelegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        bind(viewModel: viewModel)
    }

    // MARK: - UI Setup

    private func setupUI() {
        view.backgroundColor = .systemBackground

        titleLabel.font = .preferredFont(forTextStyle: .largeTitle)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    // MARK: - State Machine

    private func applyState() {
        switch state {
        case .idle:
            break
        case .loaded(let title):
            titleLabel.text = title
        }
    }
}

// MARK: - HomeViewModelViewDelegate

extension HomeViewController: HomeViewModelViewDelegate {
    func bind(viewModel: HomeViewModel) {
        state = .loaded(title: viewModel.title)
    }
}