protocol UserRepositoryProtocol {
    func searchUsers(query: String) async throws -> [SearchUser]
    func followUser(userId: Int) async throws
    func unfollowUser(userId: Int) async throws
    func updateDisplayName(_ name: String) async throws
    func deleteAccount() async throws
    func reportUser(userId: Int, reason: String) async throws
    func blockUser(userId: Int, reason: String?) async throws
    func unblockUser(userId: Int) async throws
    func fetchBlockedUsers() async throws -> [BlockedUser]
}
