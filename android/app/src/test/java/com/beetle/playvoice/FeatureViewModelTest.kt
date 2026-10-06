package com.beetle.playvoice

import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelStore
import com.beetle.playvoice.domain.model.User
import com.beetle.playvoice.feature.home.HomeViewModel
import com.beetle.playvoice.feature.login.LoginViewModel
import com.beetle.playvoice.feature.profile.edit.EditNameViewModel
import com.beetle.playvoice.feature.search.SearchViewModel
import com.beetle.playvoice.feature.settings.SettingsViewModel
import kotlinx.coroutines.*
import kotlinx.coroutines.test.*
import org.junit.*
import org.junit.Assert.*

@OptIn(ExperimentalCoroutinesApi::class)
class FeatureViewModelTest {
    @get:Rule val main = MainDispatcherRule()
    private val store = ViewModelStore()
    private var count = 0

    private fun <T : ViewModel> retain(model: T): T {
        store.put((count++).toString(), model)
        return model
    }

    @After fun clear() = store.clear()

    @Test
    fun searchDebouncesAndOldSuccessCannotReplaceNewQuery() = runTest {
        val oldResponse = CompletableDeferred<List<User>>()
        var calls = 0
        val community =
            object : FakeCommunity() {
                override suspend fun search(query: String): List<User> {
                    calls++
                    if (query == "old") return withContext(NonCancellable) { oldResponse.await() }
                    return listOf(User(3, query, null, "Channel"))
                }
            }
        val model = retain(SearchViewModel(community))
        model.search("discard")
        advanceTimeBy(200)
        model.search("old")
        advanceTimeBy(300)
        runCurrent()
        assertEquals(1, calls)
        model.search("new")
        advanceTimeBy(300)
        runCurrent()
        assertEquals("new", model.state.value.users.single().name)
        oldResponse.complete(listOf(User(2, "old", null, "Channel")))
        runCurrent()
        assertEquals("new", model.state.value.users.single().name)
    }

    @Test
    fun staleSearchErrorCannotReplaceCurrentResults() = runTest {
        val barrier = CompletableDeferred<Unit>()
        val community =
            object : FakeCommunity() {
                override suspend fun search(query: String): List<User> {
                    if (query == "old")
                        withContext(NonCancellable) {
                            barrier.await()
                            error("Old failure")
                        }
                    return listOf(User(3, query, null, "Channel"))
                }
            }
        val model = retain(SearchViewModel(community))
        model.search("old")
        advanceTimeBy(300)
        runCurrent()
        model.search("new")
        advanceTimeBy(300)
        runCurrent()
        barrier.complete(Unit)
        runCurrent()
        assertNull(model.state.value.error)
        assertEquals("new", model.state.value.users.single().name)
    }

    @Test
    fun followDeduplicatesSubmissionAndRefreshesHome() = runTest {
        val community = FakeCommunity()
        val user = User(2, "Friend", null, "Squad")
        community.users = listOf(user)
        val home = retain(HomeViewModel(community))
        val search = retain(SearchViewModel(community))
        runCurrent()
        search.search("Friend")
        advanceTimeBy(300)
        runCurrent()
        search.toggleFollow(user)
        search.toggleFollow(user)
        runCurrent()
        advanceTimeBy(300)
        runCurrent()
        assertEquals(1, community.followCalls)
        assertEquals(2L, home.state.value.followed.single().ownerId)
        assertTrue(search.state.value.users.single().followed)
        assertTrue(search.state.value.pending.isEmpty())
    }

    @Test
    fun failedFollowPreservesResultAndAllowsRetry() = runTest {
        val community =
            FakeCommunity().apply {
                users = listOf(User(2, "Friend", null, "Squad"))
                failFollow = true
            }
        val search = retain(SearchViewModel(community))
        search.search("Friend")
        advanceTimeBy(300)
        runCurrent()
        search.toggleFollow(search.state.value.users.single())
        runCurrent()
        assertFalse(search.state.value.users.single().followed)
        assertEquals("Follow failed", search.state.value.error)
        assertTrue(search.state.value.pending.isEmpty())
    }

    @Test
    fun profileValidationTrimsUnicodeNamesAndUpdatesHome() = runTest {
        val account = FakeAccount()
        val community = FakeCommunity()
        val home = retain(HomeViewModel(community))
        val edit = retain(EditNameViewModel(true, account, community))
        runCurrent()
        edit.edit("😀")
        assertFalse(edit.state.value.valid)
        edit.save()
        assertFalse(edit.state.value.done)
        edit.edit("  😀😀  ")
        edit.save()
        runCurrent()
        assertTrue(edit.state.value.done)
        assertEquals("😀😀", home.state.value.mine?.name)
    }

    @Test
    fun loginRequiresTermsAndCancellationAllowsRetry() {
        val model = retain(LoginViewModel(FakeAccount()))
        assertFalse(model.begin())
        model.acceptTerms(true)
        assertTrue(model.begin())
        assertFalse(model.begin())
        model.cancelled()
        assertFalse(model.state.value.busy)
        assertNull(model.state.value.error)
        assertTrue(model.begin())
        model.failed("Try again")
        assertFalse(model.state.value.busy)
        assertEquals("Try again", model.state.value.error)
    }

    @Test
    fun profileSaveFailurePreservesInput() = runTest {
        val community =
            object : FakeCommunity() {
                override suspend fun renameChannel(name: String) {
                    error("Save failed")
                }
            }
        val edit = retain(EditNameViewModel(true, FakeAccount(), community))
        runCurrent()
        edit.edit("  My New Channel  ")
        edit.save()
        runCurrent()
        assertEquals("  My New Channel  ", edit.state.value.value)
        assertEquals("Save failed", edit.state.value.error)
        assertFalse(edit.state.value.saving)
        assertFalse(edit.state.value.done)
    }

    @Test
    fun deletionNeedsConfirmationAndFailureKeepsSession() = runTest {
        val account = FakeAccount().apply { deleteFailure = true }
        val settings = retain(SettingsViewModel(account))
        settings.perform()
        runCurrent()
        assertNotNull(account.preferences.value.session)
        settings.confirm("delete")
        settings.perform()
        runCurrent()
        assertNotNull(account.preferences.value.session)
        assertEquals("Deletion failed", settings.state.value.error)
        assertEquals("delete", settings.state.value.confirmation)
    }
}
