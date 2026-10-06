package com.beetle.playvoice.core.datastore

import android.content.Context
import androidx.datastore.preferences.core.*
import androidx.datastore.preferences.preferencesDataStore
import com.beetle.playvoice.domain.model.*
import java.io.IOException
import kotlinx.coroutines.flow.catch
import kotlinx.coroutines.flow.map

private val Context.playVoiceStore by preferencesDataStore("playvoice")

interface PreferencesStorage {
    val preferences: kotlinx.coroutines.flow.Flow<AppPreferences>

    suspend fun saveSession(session: Session?)

    suspend fun completeOnboarding()

    suspend fun setTheme(mode: ThemeMode)
}

class PreferenceStore(context: Context) : PreferencesStorage {
    private val store = context.playVoiceStore
    private val token = stringPreferencesKey("token")
    private val id = longPreferencesKey("id")
    private val name = stringPreferencesKey("name")
    private val email = stringPreferencesKey("email")
    private val avatar = stringPreferencesKey("avatar")
    private val onboarded = booleanPreferencesKey("onboarded")
    private val theme = stringPreferencesKey("theme")

    override val preferences =
        store.data
            .catch { if (it is IOException) emit(emptyPreferences()) else throw it }
            .map { values ->
                val session =
                    values[token]
                        ?.takeIf { it.isNotBlank() && (values[id] ?: 0) > 0 }
                        ?.let {
                            Session(
                                it,
                                values[id] ?: 0,
                                values[name] ?: "Me",
                                values[email] ?: "",
                                values[avatar],
                            )
                        }
                AppPreferences(
                    ready = true,
                    onboarded = values[onboarded] ?: false,
                    session = session,
                    theme =
                        ThemeMode.entries.firstOrNull { it.name == values[theme] }
                            ?: ThemeMode.SYSTEM,
                )
            }

    override suspend fun saveSession(session: Session?) {
        store.edit { values ->
            listOf(token, name, email, avatar).forEach { values.remove(it) }
            values.remove(id)
            session?.let {
                values[token] = it.token
                values[id] = it.userId
                values[name] = it.name
                values[email] = it.email
                it.avatarUrl?.let { url -> values[avatar] = url }
            }
        }
    }

    override suspend fun completeOnboarding() {
        store.edit { it[onboarded] = true }
    }

    override suspend fun setTheme(mode: ThemeMode) {
        store.edit { it[theme] = mode.name }
    }
}
