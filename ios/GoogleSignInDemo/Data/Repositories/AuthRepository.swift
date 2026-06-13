import Foundation

final class AuthRepository: AuthRepositoryProtocol {
    private let apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func login(idToken: String, name: String?, avatarURL: String?) async throws -> Session {
        try await performAuth(.googleAuth(idToken: idToken, name: name, avatarURL: avatarURL))
    }

    func appleLogin(idToken: String, name: String?, email: String?) async throws -> Session {
        try await performAuth(.appleAuth(idToken: idToken, name: name, email: email))
    }

    private func performAuth(_ endpoint: Endpoint) async throws -> Session {
        let dto: AuthResponseDTO = try await apiClient.request(endpoint)
        let session = AuthMapper.toEntity(dto)
        await MainActor.run {
            let ud = UserDefaults.standard
            ud.set(session.accessToken, forKey: "access_token")
            ud.set(session.name, forKey: "user_name")
            ud.set(session.email, forKey: "user_email")
            ud.set(session.userId, forKey: "user_id")
            ud.set(session.avatarURL?.absoluteString, forKey: "user_avatar_url")
        }
        return session
    }
}
