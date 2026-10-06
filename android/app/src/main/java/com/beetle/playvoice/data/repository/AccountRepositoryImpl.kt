package com.beetle.playvoice.data.repository

import com.beetle.playvoice.core.datastore.PreferencesStorage
import com.beetle.playvoice.core.network.SessionManager
import com.beetle.playvoice.data.mapper.toDomain
import com.beetle.playvoice.data.remote.api.PlayVoiceApi
import com.beetle.playvoice.data.remote.dto.*
import com.beetle.playvoice.domain.model.*
import com.beetle.playvoice.domain.repository.AccountRepository

class AccountRepositoryImpl(
    private val api: PlayVoiceApi,
    private val sessions: SessionManager,
    private val store: PreferencesStorage,
    private val changed: () -> Unit,
) : AccountRepository {
    override val preferences = sessions.preferences

    override suspend fun login(idToken: String) {
        sessions.save(api.login(GoogleRequest(idToken)).toDomain())
    }

    override suspend fun completeOnboarding() = store.completeOnboarding()

    override suspend fun setTheme(theme: ThemeMode) = store.setTheme(theme)

    override suspend fun logout() = sessions.clear().let { Unit }

    override suspend fun deleteAccount() {
        val token = preferences.value.session?.token ?: return
        sessions.authenticated { api.deleteAccount() }
        sessions.clear(token)
    }

    override suspend fun renameUser(name: String) {
        val trimmed = name.trim()
        require(validName(trimmed)) { "2–30 characters. Cannot be blank." }
        val token = preferences.value.session?.token ?: return
        sessions.authenticated { api.renameUser(NameRequest(trimmed)) }
        sessions.rename(token, trimmed)
        changed()
    }
}
