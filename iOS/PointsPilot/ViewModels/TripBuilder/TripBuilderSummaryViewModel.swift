import Foundation

protocol TripBuilderSummaryViewModelProtocol {
    var title: String { get }
    var summary: String { get }
    var instruction: String { get }
    var buttonTitle: String { get }
}

protocol TripBuilderSummaryViewModelFactory: AnyObject {
    func makeTripBuilderSummaryViewModel(
        title: String,
        summary: String,
        instruction: String,
        buttonTitle: String
    ) -> any TripBuilderSummaryViewModelProtocol
}

struct TripBuilderSummaryViewModel: TripBuilderSummaryViewModelProtocol {
    let title: String
    let summary: String
    let instruction: String
    let buttonTitle: String
}
