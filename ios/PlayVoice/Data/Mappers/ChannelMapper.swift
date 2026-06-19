import Foundation

struct ChannelMapper {
    static func toEntity(_ dto: ChannelItemDTO) -> Channel {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let date = formatter.date(from: dto.updatedAt)
            ?? ISO8601DateFormatter().date(from: dto.updatedAt)
            ?? Date()
        return Channel(
            channelId: dto.channelId,
            channelName: dto.channelName,
            ownerUserId: dto.ownerUserId,
            ownerName: dto.ownerName ?? "Unknown User",
            ownerAvatarURL: dto.ownerAvatarUrl.flatMap(URL.init),
            updatedAt: date
        )
    }
}
