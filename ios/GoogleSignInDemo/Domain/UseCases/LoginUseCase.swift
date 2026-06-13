final class LoginUseCase {
    private let repository: AuthRepositoryProtocol

    init(repository: AuthRepositoryProtocol) {
        self.repository = repository
    }

    func execute(idToken: String, name: String?, avatarURL: String?) async throws -> Session {
        try await repository.login(idToken: idToken, name: name, avatarURL: avatarURL)
    }

    func executeWithApple(idToken: String, name: String?, email: String?) async throws -> Session {
        try await repository.appleLogin(idToken: idToken, name: name, email: email)
    }
}
