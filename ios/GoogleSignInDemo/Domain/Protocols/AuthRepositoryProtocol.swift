protocol AuthRepositoryProtocol {
    func login(idToken: String) async throws -> Session
}
