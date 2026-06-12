import Foundation
import Combine
import AVFoundation

enum VoiceRoomConnectionState {
    case connecting
    case connected
    case disconnected
    case failed(String)
}

final class VoiceRoomViewModel: NSObject, ObservableObject {

    @Published private(set) var connectionState: VoiceRoomConnectionState = .connecting
    @Published private(set) var members: [RoomMember] = []
    @Published private(set) var isMuted = true
    @Published private(set) var isSpeaker = false

    let channelName: String
    private let ownerUserId: Int
    private let currentUserId: Int
    let roomClient: RoomClient

    init(channel: Channel) {
        channelName = channel.channelName
        ownerUserId = channel.ownerUserId
        currentUserId = UserDefaults.standard.integer(forKey: "user_id")

        let client = RoomClient()
        client.currentUID = Int64(UserDefaults.standard.integer(forKey: "user_id"))
        client.channelID = String(channel.channelId)
        client.token = UserDefaults.standard.string(forKey: "access_token") ?? ""
        client.displayName = UserDefaults.standard.string(forKey: "user_name") ?? ""
        client.microphoneOn = true
        client.muted = true//same as isMuted
        client.cameraOn = false
        roomClient = client

        let myId = UserDefaults.standard.integer(forKey: "user_id")
        let myName = UserDefaults.standard.string(forKey: "user_name") ?? "我"

        super.init()
        client.delegate = self

        members = [RoomMember(
            id: String(myId),
            displayName: myName,
            isOwner: myId == channel.ownerUserId,
            isMuted: true,
            isSpeaking: false,
            colorIndex: 0
        )]
    }

    func start() {
        let audioSession = AVAudioSession.sharedInstance()
        try? audioSession.setCategory(.playAndRecord, mode: .voiceChat,
                                      options: [.defaultToSpeaker, .allowBluetooth])
        try? audioSession.setActive(true)

        audioSession.requestRecordPermission { [weak self] granted in
            DispatchQueue.main.async {
                guard let self else { return }
                if granted {
                    self.roomClient.start()
                } else {
                    self.connectionState = .failed("麦克风权限被拒绝，请在「设置 › 隐私与安全性」中开启")
                }
            }
        }
    }

    func stop() {
        roomClient.stop()
        try? AVAudioSession.sharedInstance().setActive(false)
    }

    func toggleMute() {
        isMuted.toggle()
        roomClient.applyMuted(isMuted)
        mutateMember(id: String(currentUserId)) { $0.isMuted = self.isMuted }
    }

    func toggleSpeaker() {
        isSpeaker.toggle()
        let port: AVAudioSession.PortOverride = isSpeaker ? .speaker : .none
        try? AVAudioSession.sharedInstance().overrideOutputAudioPort(port)
    }

    func reconnect() {
        connectionState = .connecting
        roomClient.stop()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak self] in
            self?.roomClient.start()
        }
    }

    private func mutateMember(id: String, _ mutate: (inout RoomMember) -> Void) {
        guard let idx = members.firstIndex(where: { $0.id == id }) else { return }
        var m = members[idx]
        mutate(&m)
        members[idx] = m
    }
}

// MARK: - RoomClientDelegate

extension VoiceRoomViewModel: RoomClientDelegate {

    func roomClientDidConnect(_ client: RoomClient) {
        connectionState = .connected
    }

    func roomClientDidDisconnect(_ client: RoomClient) {
        connectionState = .disconnected
    }

    func roomClientDidFail(_ client: RoomClient) {
        connectionState = .failed("连接失败，请检查网络后点击「重连」")
    }

    func roomClient(_ client: RoomClient, didJoinWithPeers peers: [Any]) {
        let selfMember = members.first(where: { $0.id == String(currentUserId) })
        var updated: [RoomMember] = selfMember.map { [$0] } ?? []

        let dicts = peers.compactMap { $0 as? [String: Any] }
        for (i, peer) in dicts.enumerated() {
            guard let peerId = peer["id"] as? String else { continue }
            let name = (peer["displayName"] as? String) ?? peerId
            updated.append(RoomMember(
                id: peerId,
                displayName: name,
                isOwner: (Int(peerId) ?? -1) == ownerUserId,
                isMuted: false,
                isSpeaking: false,
                colorIndex: i + 1
            ))
        }
        members = updated
    }

    func roomClient(_ client: RoomClient, peerJoined peerInfo: [AnyHashable: Any]) {
        guard let peerId = peerInfo["id"] as? String,
              !members.contains(where: { $0.id == peerId }) else { return }
        let name = (peerInfo["displayName"] as? String) ?? peerId
        members.append(RoomMember(
            id: peerId,
            displayName: name,
            isOwner: (Int(peerId) ?? -1) == ownerUserId,
            isMuted: false,
            isSpeaking: false,
            colorIndex: members.count
        ))
    }

    func roomClient(_ client: RoomClient, peerLeft peerId: String) {
        print("peer left:\(peerId) \(members)")
        members.removeAll { $0.id == peerId }
        print("members:\(members)")
    }
}
