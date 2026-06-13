protocol AuthRepositoryProtocol {
    func login(idToken: String, name: String?, avatarURL: String?) async throws -> Session
}
