protocol AuthRepositoryProtocol {
    func login(idToken: String, name: String?, avatarURL: String?) async throws -> Session
    func loginWithApple(identityToken: String, name: String?) async throws -> Session
}
