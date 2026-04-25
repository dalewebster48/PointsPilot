import Foundation

struct SearchResult<T: Decodable>: Decodable {
    let data: [T]
    let total: Int?
}
