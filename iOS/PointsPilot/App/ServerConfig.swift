import Foundation

enum ServerConfig {
    static let baseURL: URL = {
        guard let url = URL(string: baseURLString) else {
            fatalError("ServerConfig.plist contains an invalid ServerBaseURL: \(baseURLString)")
        }
        return url
    }()

    private static let baseURLString: String = {
        guard let path = Bundle.main.path(forResource: "ServerConfig", ofType: "plist") else {
            fatalError("ServerConfig.plist is missing from the app bundle. Copy ServerConfig.example.plist to ServerConfig.plist and set your local server URL.")
        }
        guard let dict = NSDictionary(contentsOfFile: path),
              let value = dict["ServerBaseURL"] as? String,
              !value.isEmpty
        else {
            fatalError("ServerConfig.plist is missing the ServerBaseURL key.")
        }
        return value
    }()
}
