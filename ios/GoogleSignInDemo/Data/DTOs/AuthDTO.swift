struct AuthResponseDTO: Decodable {
    let accessToken: String
    let isNewUser: Bool
    let userId: Int
    let name: String?
    let email: String
    let avatarUrl: String?

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case isNewUser   = "is_new_user"
        case userId      = "user_id"
        case name, email
        case avatarUrl   = "avatar_url"
    }
}
