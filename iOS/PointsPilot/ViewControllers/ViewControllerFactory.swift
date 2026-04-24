import UIKit

final class ViewControllerFactory {
    private let viewModelFactory: ViewModelFactory

    init(viewModelFactory: ViewModelFactory) {
        self.viewModelFactory = viewModelFactory
    }

    func makeHomeViewController() -> HomeViewController {
        let viewModel = viewModelFactory.makeHomeViewModel()
        return HomeViewController(viewModel: viewModel)
    }
}