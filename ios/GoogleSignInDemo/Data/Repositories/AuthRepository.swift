import Foundation

final class AuthRepository: AuthRepositoryProtocol {
    private let apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func login(idToken: String) async throws -> Session {
        let dto: AuthResponseDTO = try await apiClient.request(.googleAuth(idToken: idToken))
        let session = AuthMapper.toEntity(dto)
        // TODO: move to KeychainService
        await MainActor.run {
            UserDefaults.standard.set(session.accessToken, forKey: "access_token")
        }
        return session
    }
}
