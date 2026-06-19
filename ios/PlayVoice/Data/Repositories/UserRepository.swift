import Foundation

final class UserRepository: UserRepositoryProtocol {
    private let apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func searchUsers(query: String) async throws -> [SearchUser] {
        let dtos: [UserSearchItemDTO] = try await apiClient.request(.searchUsers(query: query))
        return dtos.map { dto in
            SearchUser(
                userId: dto.userId,
                name: dto.name ?? "Unknown User",
                avatarURL: dto.avatarUrl.flatMap(URL.init),
                channelName: dto.channelName ?? "Unnamed Channel",
                isFollowed: dto.isFollowed
            )
        }
    }

    func followUser(userId: Int) async throws {
        try await apiClient.requestEmpty(.followUser(userId: userId))
    }

    func unfollowUser(userId: Int) async throws {
        try await apiClient.requestEmpty(.unfollowUser(userId: userId))
    }

    func updateDisplayName(_ name: String) async throws {
        try await apiClient.requestEmpty(.updateDisplayName(name: name))
    }

    func deleteAccount() async throws {
        try await apiClient.requestEmpty(.deleteAccount)
    }

    func reportUser(userId: Int, reason: String) async throws {
        try await apiClient.requestEmpty(.reportUser(userId: userId, reason: reason))
    }

    func blockUser(userId: Int, reason: String?) async throws {
        try await apiClient.requestEmpty(.blockUser(userId: userId, reason: reason))
    }

    func unblockUser(userId: Int) async throws {
        try await apiClient.requestEmpty(.unblockUser(userId: userId))
    }

    func fetchBlockedUsers() async throws -> [BlockedUser] {
        let dtos: [BlockedUserDTO] = try await apiClient.request(.blockedUsers)
        return dtos.map { dto in
            BlockedUser(
                userId: dto.userId,
                name: dto.name ?? "Unknown User",
                avatarURL: dto.avatarUrl.flatMap(URL.init)
            )
        }
    }
}
