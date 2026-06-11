import Foundation

struct Session {
    let accessToken: String
    let userId: Int
    let name: String
    let email: String
    let avatarURL: URL?
    let isNewUser: Bool
}
