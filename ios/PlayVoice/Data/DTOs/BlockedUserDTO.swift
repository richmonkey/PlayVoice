import Foundation

struct BlockedUserDTO: Decodable {
    let userId: Int
    let name: String?
    let avatarUrl: String?
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case name
        case avatarUrl = "avatar_url"
        case createdAt = "created_at"
    }
}
