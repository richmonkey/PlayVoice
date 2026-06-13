import Foundation

enum HTTPMethod: String {
    case get    = "GET"
    case post   = "POST"
    case patch  = "PATCH"
    case delete = "DELETE"
}

enum Endpoint {
    case googleAuth(idToken: String, name: String?, avatarURL: String?)
    case followedChannels
    case myChannel
    case updateChannelName(name: String)
    case searchUsers(query: String)
    case followUser(userId: Int)
    case unfollowUser(userId: Int)
}

extension Endpoint {
    var path: String {
        switch self {
        case .googleAuth:              return "auth/google"
        case .followedChannels:        return "channels/followed"
        case .myChannel:               return "channels/me"
        case .updateChannelName:       return "channels/me/name"
        case .searchUsers:             return "users/search"
        case .followUser(let id):      return "follows/\(id)"
        case .unfollowUser(let id):    return "follows/\(id)"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .googleAuth:        return .post
        case .followedChannels:  return .get
        case .myChannel:         return .get
        case .updateChannelName: return .patch
        case .searchUsers:       return .get
        case .followUser:        return .post
        case .unfollowUser:      return .delete
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
        case .updateChannelName(let name):
            return try JSONEncoder().encode(["channel_name": name])
        default:
            return nil
        }
    }
}
