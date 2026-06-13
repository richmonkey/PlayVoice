import Foundation

enum AppError: Error, LocalizedError {
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingError(Error)
    case network(Error)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:           return "Server error. Please try again."
        case .httpError(let code):       return "Request failed (\(code)). Please try again."
        case .decodingError:             return "Failed to parse response. Please try again."
        case .network:                   return "Network error. Check your connection and try again."
        }
    }
}
