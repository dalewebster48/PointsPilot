import UIKit

final class TripBuilderViewController: UIViewController {
    @IBOutlet private weak var originSectionView: TripBuilderSectionView!
    @IBOutlet private weak var destinationSectionView: TripBuilderSectionView!
    @IBOutlet private weak var dateSectionView: TripBuilderSectionView!
    @IBOutlet private weak var classSectionView: TripBuilderSectionView!
    @IBOutlet private weak var searchButton: UIButton!

    private let viewModel: any TripBuilderViewModelProtocol

    init(viewModel: any TripBuilderViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Trip Builder"
        searchButton.layer.cornerRadius = 12
        applyTheme()
        viewModel.viewDelegate = self
    }

    @IBAction private func didTapSearch() {
        viewModel.didTapSearch()
    }

    private func applyTheme() {
        view.backgroundColor = Theme.background
        searchButton.backgroundColor = Theme.primaryAccent
        searchButton.setTitleColor(.white, for: .normal)
    }
}

// MARK: - TripBuilderViewModelViewDelegate

extension TripBuilderViewController: TripBuilderViewModelViewDelegate {
    func bind(viewModel: any TripBuilderViewModelProtocol) {
        originSectionView.bind(viewModel: viewModel.originSection)
        destinationSectionView.bind(viewModel: viewModel.destinationSection)
        dateSectionView.bind(viewModel: viewModel.dateSection)
        classSectionView.bind(viewModel: viewModel.classSection)
    }
}
