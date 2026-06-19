struct RoomMember {
    let id: String
    var displayName: String
    var isOwner: Bool
    var isMuted: Bool
    var isSpeaking: Bool
    let colorIndex: Int

    var initials: String {
        let words = displayName.split(separator: " ")
        if words.count >= 2 {
            return (String(words[0].prefix(1)) + String(words[1].prefix(1))).uppercased()
        }
        return String(displayName.prefix(2)).uppercased()
    }
}
