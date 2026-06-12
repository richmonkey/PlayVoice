import Foundation

final class AuthRepository: AuthRepositoryProtocol {
    private let apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func login(idToken: String) async throws -> Session {
        let dto: AuthResponseDTO = try await apiClient.request(.googleAuth(idToken: idToken))
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
