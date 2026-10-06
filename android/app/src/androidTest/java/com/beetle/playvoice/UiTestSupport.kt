package com.beetle.playvoice

import com.beetle.playvoice.domain.model.*
import com.beetle.playvoice.domain.repository.*
import kotlinx.coroutines.flow.*

val testSession = Session("token", 1, "Player", "player@example.com", null)
val testChannel = Channel(10, "Squad", 1, "Player", null)

open class FakeCommunity : CommunityRepository {
    override val revision = MutableStateFlow(0L)
    var channel = testChannel
    var followed = emptyList<Channel>()
    var users = emptyList<User>()
    var followCalls = 0
    var failFollow = false

    override suspend fun myChannel() = channel

    override suspend fun followedChannels() = followed

    override suspend fun renameChannel(name: String) {
        channel = channel.copy(name = name)
        revision.value++
    }

    override suspend fun search(query: String) = users

    override suspend fun follow(userId: Long, followed: Boolean) {
        followCalls++
        if (failFollow) error("Follow failed")
        this.followed =
            if (followed) listOf(testChannel.copy(id = 20, ownerId = userId)) else emptyList()
        users = users.map { if (it.id == userId) it.copy(followed = followed) else it }
        revision.value++
    }

    override suspend fun report(userId: Long, reason: String) = Unit

    override suspend fun block(userId: Long) {
        users = users.filterNot { it.id == userId }
        revision.value++
    }

    override suspend fun blockedUsers() = emptyList<User>()

    override suspend fun unblock(userId: Long) = Unit
}

class FakeAccount : AccountRepository {
    override val preferences =
        MutableStateFlow(AppPreferences(ready = true, onboarded = true, session = testSession))
    var deleteFailure = false

    override suspend fun login(idToken: String) {
        preferences.update { it.copy(session = testSession) }
    }

    override suspend fun completeOnboarding() {
        preferences.update { it.copy(onboarded = true) }
    }

    override suspend fun setTheme(theme: ThemeMode) {
        preferences.update { it.copy(theme = theme) }
    }

    override suspend fun logout() {
        preferences.update { it.copy(session = null) }
    }

    override suspend fun deleteAccount() {
        if (deleteFailure) error("Deletion failed")
        logout()
    }

    override suspend fun renameUser(name: String) {
        preferences.update { it.copy(session = it.session?.copy(name = name)) }
    }
}
