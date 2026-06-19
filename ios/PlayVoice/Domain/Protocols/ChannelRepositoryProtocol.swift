protocol ChannelRepositoryProtocol {
    func fetchFollowedChannels() async throws -> [Channel]
    func fetchMyChannel() async throws -> Channel
    func updateChannelName(_ name: String) async throws -> Channel
}
