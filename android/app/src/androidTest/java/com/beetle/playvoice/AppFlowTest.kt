package com.beetle.playvoice

import androidx.compose.ui.test.*
import androidx.compose.ui.test.junit4.createComposeRule
import com.beetle.playvoice.app.PlayVoiceApp
import com.beetle.playvoice.domain.model.*
import com.beetle.playvoice.domain.repository.VoiceRepository
import kotlinx.coroutines.flow.MutableStateFlow
import org.junit.Assert.*
import org.junit.Rule
import org.junit.Test

class AppFlowTest {
    @get:Rule val compose = createComposeRule()
    private val account = FakeAccount()
    private val voice =
        object : VoiceRepository {
            override val state = MutableStateFlow(VoiceState())

            override fun join(channel: Channel, session: Session) = Unit

            override fun leave() = Unit

            override fun toggleMute() = Unit

            override fun toggleSpeaker() = Unit

            override fun hideMember(userId: Long) = Unit
        }

    private fun start(community: FakeCommunity = FakeCommunity()) {
        compose.setContent { PlayVoiceApp(account, community, voice) }
    }

    private fun settingsClick(label: String) {
        compose.onNode(hasScrollToIndexAction()).performScrollToNode(hasText(label))
        compose.onNodeWithText(label).performClick()
    }

    @Test
    fun startupOnboardingAndTermsGate() {
        account.preferences.value = AppPreferences(ready = false)
        start()
        compose.onNodeWithText("Home").assertDoesNotExist()
        compose.runOnIdle { account.preferences.value = AppPreferences(ready = true) }
        compose.onNodeWithText("Crystal-Clear Voice").assertIsDisplayed()
        compose.onNodeWithText("Next").performClick()
        compose.onNodeWithText("Your Channel, Your Squad").assertIsDisplayed()
        compose.onNodeWithText("Next").performClick()
        compose.onNodeWithText("Follow & Jump In").assertIsDisplayed()
        compose.onNodeWithText("Get Started").performClick()
        compose.onNodeWithText("Continue with Google").assertIsNotEnabled()
        compose.onNode(isToggleable()).performClick()
        compose.onNodeWithText("Continue with Google").assertIsEnabled()
        assertTrue(account.preferences.value.onboarded)
    }

    @Test
    fun searchFollowAndHomeSynchronization() {
        val community = FakeCommunity().apply { users = listOf(User(2, "Friend", null, "Squad")) }
        start(community)
        compose.onNodeWithText("Search").performClick()
        compose.onNodeWithText("Search by name or channel").performTextInput("Friend")
        compose.waitUntil(5000) {
            compose.onAllNodesWithText("Follow").fetchSemanticsNodes().isNotEmpty()
        }
        compose.onNodeWithText("Follow").performClick()
        compose.waitUntil(5000) {
            compose.onAllNodesWithText("Following").fetchSemanticsNodes().isNotEmpty()
        }
        compose.onNodeWithContentDescription("Back").performClick()
        compose.onAllNodesWithText("Squad").assertCountEquals(2)
        assertEquals(1, community.followCalls)
    }

    @Test
    fun editValidationAndProfileRefresh() {
        start()
        compose.onNodeWithContentDescription("Profile").performClick()
        compose.onNodeWithText("Channel Name: Squad").performClick()
        compose.onNodeWithText("Channel Name").performTextReplacement("x")
        compose.onNodeWithText("Save").assertIsNotEnabled()
        compose.onNodeWithText("Channel Name").performTextReplacement("New Squad")
        compose.onNodeWithText("Save").performClick()
        compose.onNodeWithText("Channel Name: New Squad").assertIsDisplayed()
    }

    @Test
    fun deleteConfirmationFailureAndSuccess() {
        account.deleteFailure = true
        start()
        compose.onNodeWithContentDescription("Settings").performClick()
        settingsClick("Delete Account")
        compose.onNodeWithText("Delete Account?").assertIsDisplayed()
        assertNotNull(account.preferences.value.session)
        compose.onNodeWithText("Delete").performClick()
        compose.onNodeWithText("Deletion failed").assertIsDisplayed()
        assertNotNull(account.preferences.value.session)
        compose.runOnIdle { account.deleteFailure = false }
        compose.onNodeWithText("Delete").performClick()
        compose.onNodeWithText("Welcome Back").assertIsDisplayed()
        compose.onNodeWithText("Home").assertDoesNotExist()
    }

    @Test
    fun blockedUsersCanBeUnblocked() {
        val community =
            object : FakeCommunity() {
                private var blocked = listOf(User(2, "Blocked Player", null, "Squad"))

                override suspend fun blockedUsers() = blocked

                override suspend fun unblock(userId: Long) {
                    blocked = blocked.filterNot { it.id == userId }
                    revision.value++
                }
            }
        start(community)
        compose.onNodeWithContentDescription("Settings").performClick()
        compose.onNodeWithText("Blocked Users").performScrollTo().performClick()
        compose.onNodeWithText("Blocked Player").assertIsDisplayed()
        compose.onNodeWithText("Unblock").performClick()
        compose.onNodeWithText("No blocked users").assertIsDisplayed()
    }

    @Test
    fun themeSwitchAndSignOut() {
        start()
        compose.onNodeWithContentDescription("Settings").performClick()
        compose.onNodeWithText("Dark").performClick()
        compose.runOnIdle { assertEquals(ThemeMode.DARK, account.preferences.value.theme) }
        compose.onNodeWithText("Light").performClick()
        compose.runOnIdle { assertEquals(ThemeMode.LIGHT, account.preferences.value.theme) }
        settingsClick("Sign Out")
        compose.onNodeWithText("Sign Out?").assertIsDisplayed()
        compose.onNodeWithText("Cancel").performClick()
        assertNotNull(account.preferences.value.session)
        settingsClick("Sign Out")
        compose.onAllNodesWithText("Sign Out").onLast().performClick()
        compose.onNodeWithText("Welcome Back").assertIsDisplayed()
        compose.onNodeWithText("Continue with Google").assertIsNotEnabled()
    }
}
