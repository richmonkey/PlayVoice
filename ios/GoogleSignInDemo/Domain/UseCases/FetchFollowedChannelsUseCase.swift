final class FetchFollowedChannelsUseCase {
    private let repository: ChannelRepositoryProtocol

    init(repository: ChannelRepositoryProtocol) {
        self.repository = repository
    }

    func execute() async throws -> [Channel] {
        try await repository.fetchFollowedChannels()
    }
}
