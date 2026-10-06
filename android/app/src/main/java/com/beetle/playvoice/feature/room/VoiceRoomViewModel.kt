package com.beetle.playvoice.feature.room

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.beetle.playvoice.core.network.userMessage
import com.beetle.playvoice.domain.model.*
import com.beetle.playvoice.domain.repository.*
import kotlinx.coroutines.*
import kotlinx.coroutines.flow.*

data class VoiceRoomUiState(
    val channel: Channel? = null,
    val loading: Boolean = true,
    val error: String? = null,
)

class VoiceRoomViewModel(
    private val channelId: Long,
    private val community: CommunityRepository,
    private val account: AccountRepository,
    private val voice: VoiceRepository,
) : ViewModel() {
    private val mutableState = MutableStateFlow(VoiceRoomUiState())
    val state = mutableState.asStateFlow()
    val voiceState = voice.state
    val currentUserId: Long
        get() = account.preferences.value.session?.userId ?: 0

    private var joining: Job? = null
    private var blocked: Set<Long> = emptySet()

    init {
        load()
    }

    fun load() {
        joining?.cancel()
        joining =
            viewModelScope.launch {
                mutableState.update { it.copy(loading = true, error = null) }
                try {
                    val channel = coroutineScope {
                        val mine = async { community.myChannel() }
                        val followed = async { community.followedChannels() }
                        val blocks = async { community.blockedUsers() }
                        val channels = listOf(mine.await()) + followed.await()
                        blocked = blocks.await().map { it.id }.toSet()
                        channels.firstOrNull { it.id == channelId }
                            ?: error(
                                "This channel is no longer available. Return Home and refresh."
                            )
                    }
                    mutableState.value = VoiceRoomUiState(channel = channel, loading = false)
                } catch (error: CancellationException) {
                    throw error
                } catch (error: Exception) {
                    mutableState.update { it.copy(loading = false, error = error.userMessage()) }
                }
            }
    }

    fun join() {
        val channel = state.value.channel ?: return
        val session = account.preferences.value.session ?: return
        if (
            voiceState.value.connection in
                listOf(Connection.CONNECTING, Connection.CONNECTED, Connection.RECONNECTING)
        )
            return
        voice.join(channel, session)
        blocked.forEach(voice::hideMember)
    }

    fun toggleMute() = voice.toggleMute()

    fun toggleSpeaker() = voice.toggleSpeaker()

    fun leave() = voice.leave()

    override fun onCleared() {
        voice.leave()
    }
}
