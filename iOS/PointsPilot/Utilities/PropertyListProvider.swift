import Foundation

final class PropertyListProvider {
    static let serverBaseURL: URL = {
        guard
            let url = Bundle.main.url(forResource: "ServerConfig", withExtension: "plist"),
            let data = try? Data(contentsOf: url),
            let dict = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any],
            let urlString = dict["ServerBaseURL"] as? String,
            let baseURL = URL(string: urlString)
        else {
            fatalError("ServerConfig.plist missing or 'ServerBaseURL' key not set")
        }
        return baseURL
    }()

    private init() {}
}
