import Foundation

protocol HomeViewModelViewDelegate: AnyObject {
    func bind(viewModel: HomeViewModel)
}

final class HomeViewModel {
    private let navigator: any Navigator

    weak var viewDelegate: (any HomeViewModelViewDelegate)?

    private(set) var title: String = "PointsPilot" {
        didSet { bind() }
    }

    init(navigator: any Navigator) {
        self.navigator = navigator
    }

    private func bind() {
        Task { @MainActor in
            viewDelegate?.bind(viewModel: self)
        }
    }
}