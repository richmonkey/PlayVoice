package com.beetle.playvoice.data.repository

import com.beetle.playvoice.core.network.SessionManager
import com.beetle.playvoice.data.mapper.toDomain
import com.beetle.playvoice.data.remote.api.PlayVoiceApi
import com.beetle.playvoice.data.remote.dto.*
import com.beetle.playvoice.domain.model.*
import com.beetle.playvoice.domain.repository.CommunityRepository
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update

class CommunityRepositoryImpl(private val api: PlayVoiceApi, private val sessions: SessionManager) :
    CommunityRepository {
    private val changes = MutableStateFlow(0L)
    override val revision = changes.asStateFlow()

    fun changed() {
        changes.update { it + 1 }
    }

    override suspend fun myChannel() = sessions.authenticated { api.myChannel().toDomain() }

    override suspend fun followedChannels() =
        sessions.authenticated { api.followed().map { it.toDomain() } }

    override suspend fun search(query: String) =
        sessions.authenticated { api.search(query).map { it.toDomain() } }

    override suspend fun blockedUsers() =
        sessions.authenticated { api.blocked().map { it.toDomain() } }

    override suspend fun renameChannel(name: String) {
        val trimmed = name.trim()
        require(validName(trimmed)) { "2–30 characters. Cannot be blank." }
        sessions.authenticated { api.renameChannel(ChannelNameRequest(trimmed)).toDomain() }
        changed()
    }

    override suspend fun follow(userId: Long, followed: Boolean) {
        sessions.authenticated { if (followed) api.follow(userId) else api.unfollow(userId) }
        changed()
    }

    override suspend fun report(userId: Long, reason: String) {
        require(reason.isNotBlank()) { "Reason is required." }
        sessions.authenticated { api.report(ReportRequest(userId, reason.trim())) }
    }

    override suspend fun block(userId: Long) {
        sessions.authenticated { api.block(userId, BlockRequest()) }
        changed()
    }

    override suspend fun unblock(userId: Long) {
        sessions.authenticated { api.unblock(userId) }
        changed()
    }
}
