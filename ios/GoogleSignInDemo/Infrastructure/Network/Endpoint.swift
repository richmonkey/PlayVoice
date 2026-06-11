import Foundation

enum HTTPMethod: String {
    case get    = "GET"
    case post   = "POST"
    case patch  = "PATCH"
    case delete = "DELETE"
}

enum Endpoint {
    case googleAuth(idToken: String)
}

extension Endpoint {
    var path: String {
        switch self {
        case .googleAuth: return "auth/google"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .googleAuth: return .post
        }
    }

    func encodeBody() throws -> Data? {
        switch self {
        case .googleAuth(let idToken):
            return try JSONEncoder().encode(["id_token": idToken])
        }
    }
}
