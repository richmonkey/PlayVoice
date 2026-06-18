import Foundation

enum HTTPMethod: String {
    case get    = "GET"
    case post   = "POST"
    case patch  = "PATCH"
    case delete = "DELETE"
}

enum Endpoint {
    case googleAuth(idToken: String, name: String?, avatarURL: String?)
    case appleAuth(identityToken: String, name: String?)
    case followedChannels
    case myChannel
    case updateChannelName(name: String)
    case updateDisplayName(name: String)
    case searchUsers(query: String)
    case followUser(userId: Int)
    case unfollowUser(userId: Int)
    case deleteAccount
    case reportUser(userId: Int, reason: String)
    case blockUser(userId: Int, reason: String?)
    case unblockUser(userId: Int)
    case blockedUsers
}

extension Endpoint {
    var path: String {
        switch self {
        case .googleAuth:              return "auth/google"
        case .appleAuth:               return "auth/apple"
        case .followedChannels:        return "channels/followed"
        case .myChannel:               return "channels/me"
        case .updateChannelName:       return "channels/me/name"
        case .updateDisplayName:       return "users/me/name"
        case .searchUsers:             return "users/search"
        case .followUser(let id):      return "follows/\(id)"
        case .unfollowUser(let id):    return "follows/\(id)"
        case .deleteAccount:           return "users/me"
        case .reportUser:              return "reports"
        case .blockUser(let id, _):    return "blocks/\(id)"
        case .unblockUser(let id):     return "blocks/\(id)"
        case .blockedUsers:            return "blocks"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .googleAuth:        return .post
        case .appleAuth:         return .post
        case .followedChannels:  return .get
        case .myChannel:         return .get
        case .updateChannelName: return .patch
        case .updateDisplayName: return .patch
        case .searchUsers:       return .get
        case .followUser:        return .post
        case .unfollowUser:      return .delete
        case .deleteAccount:     return .delete
        case .reportUser:        return .post
        case .blockUser:         return .post
        case .unblockUser:       return .delete
        case .blockedUsers:      return .get
        }
    }

    var queryItems: [URLQueryItem]? {
        switch self {
        case .searchUsers(let query):
            return [URLQueryItem(name: "q", value: query)]
        default:
            return nil
        }
    }

    func encodeBody() throws -> Data? {
        switch self {
        case .googleAuth(let idToken, let name, let avatarURL):
            var body: [String: String] = ["id_token": idToken]
            if let name { body["name"] = name }
            if let avatarURL { body["avatar_url"] = avatarURL }
            return try JSONEncoder().encode(body)
        case .appleAuth(let identityToken, let name):
            var body: [String: String] = ["identity_token": identityToken]
            if let name { body["name"] = name }
            return try JSONEncoder().encode(body)
        case .updateChannelName(let name):
            return try JSONEncoder().encode(["channel_name": name])
        case .updateDisplayName(let name):
            return try JSONEncoder().encode(["name": name])
        case .reportUser(let userId, let reason):
            struct ReportBody: Encodable { let reportedUserId: Int; let reason: String
                enum CodingKeys: String, CodingKey { case reportedUserId = "reported_user_id"; case reason }
            }
            return try JSONEncoder().encode(ReportBody(reportedUserId: userId, reason: reason))
        case .blockUser(_, let reason):
            return try JSONEncoder().encode(["reason": reason])
        default:
            return nil
        }
    }
}
