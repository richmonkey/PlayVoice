import Foundation

extension Notification.Name {
    static let unauthorized = Notification.Name("com.app.unauthorized")
}

final class APIClient {
    static let shared = APIClient()

    private let baseURL: URL
    private let session: URLSession

    init(baseURL: URL = URL(string: AppConfig.apiBaseURL)!,
         session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session
    }

    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        let urlRequest = try buildRequest(for: endpoint)
        logRequest(urlRequest)
        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(for: urlRequest)
        } catch {
            throw AppError.network(error)
        }
        guard let http = response as? HTTPURLResponse else {
            throw AppError.invalidResponse
        }
        logResponse(http, data: data)
        guard (200..<300).contains(http.statusCode) else {
            if http.statusCode == 401 {
                NotificationCenter.default.post(name: .unauthorized, object: nil)
            }
            throw AppError.httpError(statusCode: http.statusCode)
        }
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw AppError.decodingError(error)
        }
    }

    func requestEmpty(_ endpoint: Endpoint) async throws {
        let urlRequest = try buildRequest(for: endpoint)
        logRequest(urlRequest)
        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(for: urlRequest)
        } catch {
            throw AppError.network(error)
        }
        guard let http = response as? HTTPURLResponse else {
            throw AppError.invalidResponse
        }
        logResponse(http, data: data)
        guard (200..<300).contains(http.statusCode) else {
            if http.statusCode == 401 {
                NotificationCenter.default.post(name: .unauthorized, object: nil)
            }
            throw AppError.httpError(statusCode: http.statusCode)
        }
    }

    private func logRequest(_ request: URLRequest) {
        guard AppConfig.logNetworkRequests else { return }
        var lines = ["→ \(request.httpMethod ?? "?") \(request.url?.absoluteString ?? "")"]
        if let body = request.httpBody,
           let str = String(data: body, encoding: .utf8) {
            lines.append("  body: \(str)")
        }
        print(lines.joined(separator: "\n"))
    }

    private func logResponse(_ response: HTTPURLResponse, data: Data) {
        guard AppConfig.logNetworkRequests else { return }
        let body = String(data: data, encoding: .utf8) ?? "<binary \(data.count) bytes>"
        print("← \(response.statusCode) \(response.url?.absoluteString ?? "")\n  body: \(body)")
    }

    private func buildRequest(for endpoint: Endpoint) throws -> URLRequest {
        let baseWithPath = baseURL.appendingPathComponent(endpoint.path)
        let url: URL
        if let items = endpoint.queryItems, !items.isEmpty {
            var comps = URLComponents(url: baseWithPath, resolvingAgainstBaseURL: false)!
            comps.queryItems = items
            url = comps.url ?? baseWithPath
        } else {
            url = baseWithPath
        }
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try endpoint.encodeBody()
        if let token = UserDefaults.standard.string(forKey: "access_token"), !token.isEmpty {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        return request
    }
}
