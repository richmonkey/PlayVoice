import Foundation

enum AppError: Error, LocalizedError {
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingError(Error)
    case network(Error)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:           return "服务器响应异常，请重试。"
        case .httpError(let code):       return "请求失败（\(code)），请重试。"
        case .decodingError:             return "数据解析失败，请重试。"
        case .network:                   return "网络错误，请检查连接后重试。"
        }
    }
}
