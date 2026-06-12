final class ChannelRepository: ChannelRepositoryProtocol {
    private let apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func fetchFollowedChannels() async throws -> [Channel] {
        let dtos: [ChannelItemDTO] = try await apiClient.request(.followedChannels)
        return dtos.map(ChannelMapper.toEntity)
    }

    func fetchMyChannel() async throws -> Channel {
        let dto: ChannelItemDTO = try await apiClient.request(.myChannel)
        return ChannelMapper.toEntity(dto)
    }

    func updateChannelName(_ name: String) async throws -> Channel {
        let dto: ChannelItemDTO = try await apiClient.request(.updateChannelName(name: name))
        return ChannelMapper.toEntity(dto)
    }
}
