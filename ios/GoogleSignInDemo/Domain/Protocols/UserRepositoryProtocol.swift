protocol UserRepositoryProtocol {
    func searchUsers(query: String) async throws -> [SearchUser]
    func followUser(userId: Int) async throws
    func unfollowUser(userId: Int) async throws
    func updateDisplayName(_ name: String) async throws
}
