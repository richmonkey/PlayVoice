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
                name: dto.name ?? "未知用户",
                avatarURL: dto.avatarUrl.flatMap(URL.init),
                channelName: dto.channelName ?? "未命名频道",
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
}
