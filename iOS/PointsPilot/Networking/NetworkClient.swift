import Foundation

protocol NetworkClient: AnyObject {
    func get<Request: Encodable, Response: Decodable>(url: URL, query: Request) async throws -> Response
    func get<Response: Decodable>(url: URL) async throws -> Response
}

final class URLSessionNetworkClient: NetworkClient {
    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    init(session: URLSession = .shared) {
        self.session = session
        self.decoder = JSONDecoder()
        self.encoder = JSONEncoder()
    }

    func get<Response: Decodable>(url: URL) async throws -> Response {
        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.httpError(statusCode: httpResponse.statusCode)
        }

        return try decoder.decode(Response.self, from: data)
    }

    func get<Request: Encodable, Response: Decodable>(url: URL, query: Request) async throws -> Response {
        let finalURL = try appendQueryItems(to: url, from: query)
        return try await get(url: finalURL)
    }

    private func appendQueryItems(to url: URL, from encodable: some Encodable) throws -> URL {
        let data = try encoder.encode(encodable)
        let dict = try JSONSerialization.jsonObject(with: data) as? [String: Any] ?? [:]

        guard !dict.isEmpty else { return url }

        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        components?.queryItems = dict.map { key, value in
            URLQueryItem(name: key, value: "\(value)")
        }

        guard let finalURL = components?.url else {
            throw NetworkError.invalidURL
        }

        return finalURL
    }
}

enum NetworkError: Error {
    case invalidResponse
    case invalidURL
    case httpError(statusCode: Int)
}

extension URL {
    static var base: URL { PropertyListProvider.serverBaseURL }
}
