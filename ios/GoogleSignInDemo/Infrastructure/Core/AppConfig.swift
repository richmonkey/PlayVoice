import Foundation

@objcMembers
final class AppConfig: NSObject {
//    static let apiBaseURL = "http://192.168.1.6:8000"
//    static let roomServerBaseURL = "ws://192.168.1.198:4444"
    
    static let apiBaseURL = "https://gobelieve.xyz"
    static let roomServerBaseURL = "wss://gobelieve.xyz/room"

    static let logNetworkRequests = true
}
