import Foundation

struct UserSearchItemDTO: Decodable {
    let userId: Int
    let name: String?
    let avatarUrl: String?
    let channelName: String?
    let isFollowed: Bool

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case name
        case avatarUrl = "avatar_url"
        case channelName = "channel_name"
        case isFollowed = "is_followed"
    }
}
