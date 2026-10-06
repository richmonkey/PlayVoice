package com.beetle.playvoice

import android.Manifest
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.compose.ui.test.onNodeWithText
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleOwner
import androidx.lifecycle.LifecycleRegistry
import androidx.lifecycle.ViewModelStore
import androidx.lifecycle.compose.LocalLifecycleOwner
import androidx.test.filters.SdkSuppress
import androidx.test.platform.app.InstrumentationRegistry
import com.beetle.playvoice.core.ui.PlayVoiceTheme
import com.beetle.playvoice.domain.model.Channel
import com.beetle.playvoice.domain.model.Connection
import com.beetle.playvoice.domain.model.Session
import com.beetle.playvoice.domain.model.ThemeMode
import com.beetle.playvoice.domain.model.VoiceState
import com.beetle.playvoice.domain.repository.VoiceRepository
import com.beetle.playvoice.feature.room.VoiceRoomRoute
import com.beetle.playvoice.feature.room.VoiceRoomViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import org.junit.Assert.assertEquals
import org.junit.Rule
import org.junit.Test

@SdkSuppress(minSdkVersion = 28)
class VoiceRoomFlowTest {
    @get:Rule val compose = createComposeRule()

    @Test
    fun enteringBeforeResumedAutomaticallyJoinsOnceAndFailureOnlyShowsMessage() {
        val instrumentation = InstrumentationRegistry.getInstrumentation()
        instrumentation.uiAutomation.grantRuntimePermission(
            instrumentation.targetContext.packageName,
            Manifest.permission.RECORD_AUDIO,
        )
        val voice = FailedVoice()
        val store = ViewModelStore()
        lateinit var owner: RoomLifecycleOwner
        lateinit var model: VoiceRoomViewModel
        compose.runOnUiThread {
            owner = RoomLifecycleOwner()
            owner.registry.currentState = Lifecycle.State.STARTED
            model = VoiceRoomViewModel(testChannel.id, FakeCommunity(), FakeAccount(), voice)
            store.put("room", model)
        }
        try {
            compose.setContent {
                CompositionLocalProvider(LocalLifecycleOwner provides owner) {
                    PlayVoiceTheme(ThemeMode.SYSTEM) {
                        VoiceRoomRoute(model, onBack = {}, onUserActions = {})
                    }
                }
            }
            compose.waitUntil(5000) { model.state.value.channel != null }
            compose.waitForIdle()
            compose.runOnIdle { assertEquals(0, voice.joinCalls) }

            compose.runOnIdle { owner.registry.currentState = Lifecycle.State.RESUMED }
            compose.waitUntil(5000) { voice.joinCalls == 1 }
            compose.onNodeWithText("Unable to join the room.").assertIsDisplayed()
            compose.onNodeWithText("Rejoin").assertDoesNotExist()
            compose.onNodeWithText("Retry").assertDoesNotExist()

            compose.runOnIdle { owner.registry.currentState = Lifecycle.State.STARTED }
            compose.runOnIdle { owner.registry.currentState = Lifecycle.State.RESUMED }
            compose.runOnIdle {
                model.join()
                assertEquals(1, voice.joinCalls)
            }
        } finally {
            compose.runOnUiThread {
                store.clear()
                owner.registry.currentState = Lifecycle.State.DESTROYED
            }
        }
    }

    private class RoomLifecycleOwner : LifecycleOwner {
        val registry = LifecycleRegistry(this)
        override val lifecycle: Lifecycle = registry
    }

    private class FailedVoice : VoiceRepository {
        override val state = MutableStateFlow(VoiceState())
        var joinCalls = 0
            private set

        override fun join(channel: Channel, session: Session) {
            joinCalls++
            state.value = VoiceState(
                connection = Connection.FAILED,
                error = "Unable to join the room.",
            )
        }

        override fun leave() {
            state.value = VoiceState()
        }

        override fun toggleMute() = Unit

        override fun toggleSpeaker() = Unit

        override fun hideMember(userId: Long) = Unit
    }
}
