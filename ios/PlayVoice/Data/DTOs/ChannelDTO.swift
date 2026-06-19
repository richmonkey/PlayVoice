import Foundation

struct ChannelItemDTO: Decodable {
    let channelId: Int
    let channelName: String
    let ownerUserId: Int
    let ownerName: String?
    let ownerAvatarUrl: String?
    let updatedAt: String

    enum CodingKeys: String, CodingKey {
        case channelId = "channel_id"
        case channelName = "channel_name"
        case ownerUserId = "owner_user_id"
        case ownerName = "owner_name"
        case ownerAvatarUrl = "owner_avatar_url"
        case updatedAt = "updated_at"
    }
}
