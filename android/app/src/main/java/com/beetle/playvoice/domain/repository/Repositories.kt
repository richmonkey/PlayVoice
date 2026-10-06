package com.beetle.playvoice.domain.repository

import com.beetle.playvoice.domain.model.*
import kotlinx.coroutines.flow.StateFlow

interface AccountRepository {
    val preferences: StateFlow<AppPreferences>

    suspend fun login(idToken: String)

    suspend fun completeOnboarding()

    suspend fun setTheme(theme: ThemeMode)

    suspend fun logout()

    suspend fun deleteAccount()

    suspend fun renameUser(name: String)
}

interface CommunityRepository {
    val revision: StateFlow<Long>

    suspend fun myChannel(): Channel

    suspend fun followedChannels(): List<Channel>

    suspend fun renameChannel(name: String)

    suspend fun search(query: String): List<User>

    suspend fun follow(userId: Long, followed: Boolean)

    suspend fun report(userId: Long, reason: String)

    suspend fun block(userId: Long)

    suspend fun blockedUsers(): List<User>

    suspend fun unblock(userId: Long)
}

interface VoiceRepository {
    val state: StateFlow<VoiceState>

    fun join(channel: Channel, session: Session)

    fun leave()

    fun toggleMute()

    fun toggleSpeaker()

    fun hideMember(userId: Long)
}
