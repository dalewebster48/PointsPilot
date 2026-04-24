import Foundation

protocol Navigator: AnyObject {
    func navigate(to destination: AppDestination)
    func dismiss(completion: (() -> Void)?)
}