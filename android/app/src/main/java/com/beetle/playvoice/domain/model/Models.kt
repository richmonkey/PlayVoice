package com.beetle.playvoice.domain.model

data class Session(
    val token: String,
    val userId: Long,
    val name: String,
    val email: String,
    val avatarUrl: String?,
)

data class Channel(
    val id: Long,
    val name: String,
    val ownerId: Long,
    val ownerName: String,
    val avatarUrl: String?,
)

data class User(
    val id: Long,
    val name: String,
    val avatarUrl: String?,
    val channelName: String,
    val followed: Boolean = false,
)

enum class ThemeMode {
    SYSTEM,
    LIGHT,
    DARK,
}

data class AppPreferences(
    val ready: Boolean = false,
    val onboarded: Boolean = false,
    val session: Session? = null,
    val theme: ThemeMode = ThemeMode.SYSTEM,
)

enum class Connection {
    IDLE,
    CONNECTING,
    CONNECTED,
    RECONNECTING,
    FAILED,
}

data class Member(
    val id: String,
    val name: String,
    val owner: Boolean = false,
    val muted: Boolean = false,
    val speaking: Boolean = false,
)

data class VoiceState(
    val connection: Connection = Connection.IDLE,
    val members: List<Member> = emptyList(),
    val muted: Boolean = true,
    val speaker: Boolean = false,
    val route: String = "Earpiece",
    val error: String? = null,
)

fun validName(value: String): Boolean {
    val trimmed = value.trim()
    return trimmed.codePointCount(0, trimmed.length) in 2..30
}
