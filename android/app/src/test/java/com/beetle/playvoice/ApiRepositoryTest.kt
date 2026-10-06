package com.beetle.playvoice

import com.beetle.playvoice.core.network.*
import com.beetle.playvoice.data.mapper.toDomain
import com.beetle.playvoice.data.remote.api.PlayVoiceApi
import com.beetle.playvoice.data.remote.dto.*
import com.beetle.playvoice.data.repository.*
import com.beetle.playvoice.domain.model.*
import kotlinx.coroutines.*
import kotlinx.coroutines.test.*
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.ResponseBody.Companion.toResponseBody
import okhttp3.mockwebserver.*
import org.junit.*
import org.junit.Assert.*
import retrofit2.HttpException
import retrofit2.Response

@OptIn(ExperimentalCoroutinesApi::class)
class ApiRepositoryTest {
    @get:Rule val main = MainDispatcherRule()
    private val server = MockWebServer()

    @Before fun start() = server.start()

    @After fun stop() = server.shutdown()

    @Test
    fun dtoMappingHandlesMissingNamesAndRejectsInvalidSessions() {
        assertEquals("Unknown User", UserDto(2, null, null, null, false).toDomain().name)
        assertEquals("Unnamed Channel", ChannelDto(10, null, 2, null, null).toDomain().name)
        assertThrows(IllegalArgumentException::class.java) {
            AuthDto(null, 1, null, "x@y.com", null).toDomain()
        }
        assertFalse(validName("  a  "))
        assertTrue(validName("😀😀"))
        assertFalse(validName("😀".repeat(31)))
    }

    @Test
    fun noContentEndpointsAndBearerHeaderMatchBackendContract() = runTest {
        val storage = FakeStorage()
        val sessions = SessionManager(storage, backgroundScope)
        runCurrent()
        val api =
            createRetrofit(server.url("/").toString(), sessions).create(PlayVoiceApi::class.java)
        val community = CommunityRepositoryImpl(api, sessions)
        val account = AccountRepositoryImpl(api, sessions, storage, community::changed)
        server.enqueue(MockResponse().setResponseCode(204))
        community.follow(2, true)
        val follow = server.takeRequest()
        assertEquals("POST", follow.method)
        assertEquals("/follows/2", follow.path)
        assertEquals("Bearer token", follow.getHeader("Authorization"))
        assertEquals(1L, community.revision.value)
        server.enqueue(MockResponse().setResponseCode(204))
        account.renameUser("  New Player  ")
        assertEquals("New Player", account.preferences.value.session?.name)
        assertEquals("{\"name\":\"New Player\"}", server.takeRequest().body.readUtf8())
        assertEquals(2L, community.revision.value)
        server.enqueue(MockResponse().setResponseCode(204))
        account.deleteAccount()
        assertNull(account.preferences.value.session)
    }

    @Test
    fun failedAccountDeletionPreservesSessionAndExposesServerDetail() = runTest {
        val storage = FakeStorage()
        val sessions = SessionManager(storage, backgroundScope)
        runCurrent()
        val api =
            createRetrofit(server.url("/").toString(), sessions).create(PlayVoiceApi::class.java)
        val account = AccountRepositoryImpl(api, sessions, storage) {}
        server.enqueue(
            MockResponse().setResponseCode(503).setBody("{\"detail\":\"Please try later\"}")
        )
        val error = runCatching { account.deleteAccount() }.exceptionOrNull()!!
        assertEquals("Please try later", error.userMessage())
        assertEquals(testSession, account.preferences.value.session)
    }

    @Test
    fun concurrentUnauthorizedRequestsClearSessionAndVoiceOnlyOnce() = runTest {
        val storage = FakeStorage()
        val sessions = SessionManager(storage, backgroundScope)
        runCurrent()
        var stops = 0
        sessions.onSessionEnded = { stops++ }
        val barrier = CompletableDeferred<Unit>()
        val failures =
            List(8) {
                async {
                    runCatching {
                        sessions.authenticated {
                            barrier.await()
                            throw unauthorized()
                        }
                    }
                }
            }
        runCurrent()
        barrier.complete(Unit)
        failures.awaitAll()
        assertNull(sessions.preferences.value.session)
        assertEquals(1, storage.clears)
        assertEquals(1, stops)
        assertEquals(ThemeMode.SYSTEM, sessions.preferences.value.theme)
        assertTrue(sessions.preferences.value.onboarded)
    }

    @Test
    fun oldUnauthorizedResponseCannotClearNewSession() = runTest {
        val storage = FakeStorage()
        val sessions = SessionManager(storage, backgroundScope)
        runCurrent()
        val barrier = CompletableDeferred<Unit>()
        val request = async {
            runCatching {
                sessions.authenticated {
                    barrier.await()
                    throw unauthorized()
                }
            }
        }
        runCurrent()
        val replacement = testSession.copy(token = "replacement")
        sessions.save(replacement)
        barrier.complete(Unit)
        request.await()
        assertEquals(replacement, sessions.preferences.value.session)
        sessions.rename("token", "Old Name")
        assertEquals(replacement, sessions.preferences.value.session)
    }

    @Test
    fun emptyRequiredResponseIsReportedAsServerError() = runTest {
        val storage = FakeStorage()
        val sessions = SessionManager(storage, backgroundScope)
        runCurrent()
        val api =
            createRetrofit(server.url("/").toString(), sessions).create(PlayVoiceApi::class.java)
        val community = CommunityRepositoryImpl(api, sessions)
        server.enqueue(MockResponse().setResponseCode(204))
        val error = runCatching { community.myChannel() }.exceptionOrNull()!!
        assertEquals("Server error. Please try again.", error.userMessage())
        assertEquals(testSession, sessions.preferences.value.session)
    }

    private fun unauthorized() =
        HttpException(
            Response.error<Unit>(401, "{}".toResponseBody("application/json".toMediaType()))
        )
}
