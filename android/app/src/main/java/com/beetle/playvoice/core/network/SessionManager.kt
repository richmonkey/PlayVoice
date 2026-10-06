package com.beetle.playvoice.core.network

import com.beetle.playvoice.core.datastore.PreferencesStorage
import com.beetle.playvoice.domain.model.*
import kotlinx.coroutines.*
import kotlinx.coroutines.flow.*
import kotlinx.coroutines.sync.Mutex
import kotlinx.coroutines.sync.withLock
import retrofit2.HttpException

class SessionManager(private val store: PreferencesStorage, scope: CoroutineScope) {
    val preferences = store.preferences.stateIn(scope, SharingStarted.Eagerly, AppPreferences())
    private val mutex = Mutex()
    var onSessionEnded: () -> Unit = {}

    suspend fun save(session: Session) =
        mutex.withLock {
            store.saveSession(session)
            preferences.first { it.session == session }
        }

    suspend fun rename(expectedToken: String, name: String) =
        mutex.withLock {
            val session = preferences.value.session
            if (session?.token == expectedToken) {
                val updated = session.copy(name = name)
                store.saveSession(updated)
                preferences.first { it.session == updated }
            }
        }

    suspend fun clear(expectedToken: String? = preferences.value.session?.token) =
        mutex.withLock {
            if (expectedToken != null && preferences.value.session?.token == expectedToken) {
                withContext(NonCancellable) {
                    withContext(Dispatchers.Main.immediate) { onSessionEnded() }
                    store.saveSession(null)
                    preferences.first { it.session == null }
                }
            }
        }

    suspend fun <T> authenticated(block: suspend () -> T): T {
        val token = preferences.value.session?.token ?: throw CancellationException("Signed out")
        try {
            val result = block()
            if (preferences.value.session?.token != token)
                throw CancellationException("Session changed")
            return result
        } catch (error: HttpException) {
            if (error.code() == 401) clear(token)
            throw error
        }
    }
}
