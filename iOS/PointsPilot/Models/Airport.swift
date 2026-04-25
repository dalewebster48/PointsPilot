import Foundation

struct Airport: Decodable, Equatable {
    let code: String
    let name: String
    let country: String
    let destinations: [String]
}
