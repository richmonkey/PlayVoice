package com.beetle.playvoice.data.repository

import android.content.Context
import android.util.Log
import androidx.core.net.toUri
import com.beetle.playvoice.core.audio.AudioRouter
import com.beetle.playvoice.domain.model.*
import com.beetle.playvoice.domain.repository.VoiceRepository
import com.beetle.room.*
import kotlinx.coroutines.*
import kotlinx.coroutines.flow.*
import org.webrtc.VideoSink

class VoiceRepositoryImpl(
    private val context: Context,
    private val roomUrl: String,
    private val scope: CoroutineScope,
) : VoiceRepository {
    private val mutableState = MutableStateFlow(VoiceState())
    override val state = mutableState.asStateFlow()
    private val audio = AudioRouter(context)
    private var client: RoomClient? = null
    private var detection: Job? = null
    private var generation = 0L
    private val hiddenMembers = mutableSetOf<String>()

    init {
        audio.onRouteChanged = { speaker, route ->
            mutableState.update { it.copy(speaker = speaker, route = route) }
        }
        audio.onFocusLost = { fail("Audio focus was lost. You have left the room.") }
    }

    override fun join(channel: Channel, session: Session) {
        leave()
        hiddenMembers.clear()
        val current = generation
        val self =
            Member(
                session.userId.toString(),
                session.name,
                session.userId == channel.ownerId,
                muted = true,
            )
        mutableState.value = VoiceState(connection = Connection.CONNECTING, members = listOf(self))
        try {
            check(RoomSdk.getInitializationState() == RoomSdk.InitializationState.INITIALIZED) {
                "Voice chat is unavailable on this device. Please use a supported ARM device."
            }
            audio.start()
            val observer =
                object : RoomClientObserver {
                    private fun active() = generation == current && client != null

                    override fun onConnect() = Unit

                    override fun onDisconnect() {
                        if (!active()) return
                        detection?.cancel()
                        mutableState.update {
                            it.copy(
                                connection = Connection.RECONNECTING,
                                members = it.members.filter { member -> member.id == self.id },
                            )
                        }
                    }

                    override fun onError() {
                        if (active()) fail("Unable to join the room. Check your network connection.")
                    }

                    override fun onClose() {
                        if (active()) fail("The room connection was closed.")
                    }

                    override fun onJoined(peers: List<RoomProtocol.Peer>) {
                        if (!active()) return
                        mutableState.update { value ->
                            value.copy(
                                connection = Connection.CONNECTED,
                                error = null,
                                members =
                                    listOf(self.copy(muted = value.muted)) +
                                        peers
                                            .filter { it.id != self.id && it.id !in hiddenMembers }
                                            .map {
                                                Member(
                                                    it.id,
                                                    it.displayName,
                                                    it.id == channel.ownerId.toString(),
                                                )
                                            },
                            )
                        }
                        client?.produceAudio(
                            context,
                            state.value.muted,
                            object : ProduceCallback {
                                override fun onSuccess(producer: Producer) {
                                    // The SDK registers the producer after this callback returns.
                                    scope.launch {
                                        yield()
                                        if (active()) client?.applyMute(state.value.muted)
                                    }
                                }

                                override fun onError() {
                                    if (active())
                                        fail("Unable to start your microphone.")
                                }
                            },
                        )
                        detection?.cancel()
                        detection =
                            scope.launch {
                                while (active()) {
                                    val speaking =
                                        client?.detectActiveSpeakerPeerIds().orEmpty().toSet()
                                    mutableState.update { value ->
                                        value.copy(
                                            members =
                                                value.members.map {
                                                    it.copy(speaking = it.id in speaking)
                                                }
                                        )
                                    }
                                    delay(100)
                                }
                            }
                    }

                    override fun onPeer(peerId: String, displayName: String) {
                        if (!active() || peerId in hiddenMembers || peerId == self.id) return
                        mutableState.update { value ->
                            value.copy(
                                members =
                                    value.members.filterNot { it.id == peerId } +
                                        Member(
                                            peerId,
                                            displayName,
                                            peerId == channel.ownerId.toString(),
                                        )
                            )
                        }
                    }

                    override fun onPeerClosed(peerId: String) {
                        if (active())
                            mutableState.update {
                                it.copy(
                                    members = it.members.filterNot { member -> member.id == peerId }
                                )
                            }
                    }
                }
            val renderer =
                object : VideoRendererDelegate {
                    override fun createRenderer(id: String, isLocal: Boolean) = VideoSink {}

                    override fun removeRenderer(id: String) = Unit
                }
            client = RoomClient(context, observer, renderer, session.token, session.name)
            val url =
                roomUrl
                    .toUri()
                    .buildUpon()
                    .appendQueryParameter("peerId", session.userId.toString())
                    .appendQueryParameter("roomId", channel.id.toString())
                    .appendQueryParameter("mode", "group")
                    .build()
                    .toString()
            client?.start(url)
        } catch (error: Exception) {
            fail(error.message ?: "Unable to connect. Please try again.")
        }
    }

    private fun fail(message: String) {
        leave()
        mutableState.value = VoiceState(connection = Connection.FAILED, error = message)
    }

    override fun leave() {
        generation++
        detection?.cancel()
        detection = null
        val previous = client
        client = null
        try {
            previous?.stop()
        } catch (error: RuntimeException) {
            Log.w("PlayVoice", "Unable to stop voice connection", error)
        } finally {
            try {
                audio.stop()
            } catch (error: RuntimeException) {
                Log.w("PlayVoice", "Unable to restore audio route", error)
            }
            mutableState.value = VoiceState()
        }
    }

    override fun toggleMute() {
        if (state.value.connection != Connection.CONNECTED) return
        val muted = !state.value.muted
        client?.applyMute(muted)
        mutableState.update { value ->
            value.copy(
                muted = muted,
                members =
                    value.members.mapIndexed { index, member ->
                        if (index == 0) member.copy(muted = muted) else member
                    },
            )
        }
    }

    override fun toggleSpeaker() {
        runCatching { audio.toggleSpeaker() }
            .onFailure { error -> mutableState.update { it.copy(error = error.message) } }
    }

    override fun hideMember(userId: Long) {
        hiddenMembers.add(userId.toString())
        mutableState.update {
            it.copy(members = it.members.filterNot { member -> member.id == userId.toString() })
        }
    }
}
