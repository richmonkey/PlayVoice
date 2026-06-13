protocol AuthRepositoryProtocol {
    func login(idToken: String, name: String?, avatarURL: String?) async throws -> Session
    func appleLogin(idToken: String, name: String?, email: String?) async throws -> Session
}
