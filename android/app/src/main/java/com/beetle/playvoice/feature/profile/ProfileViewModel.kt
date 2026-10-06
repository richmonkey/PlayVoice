package com.beetle.playvoice.feature.profile

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.beetle.playvoice.core.network.userMessage
import com.beetle.playvoice.domain.model.*
import com.beetle.playvoice.domain.repository.*
import kotlinx.coroutines.*
import kotlinx.coroutines.flow.*

data class ProfileUiState(
    val session: Session? = null,
    val channel: Channel? = null,
    val loading: Boolean = true,
    val error: String? = null,
)

class ProfileViewModel(account: AccountRepository, private val community: CommunityRepository) :
    ViewModel() {
    private val mutableState = MutableStateFlow(ProfileUiState())
    val state = mutableState.asStateFlow()
    private var refresh: Job? = null

    init {
        viewModelScope.launch {
            account.preferences.collect { preferences ->
                mutableState.update { it.copy(session = preferences.session) }
            }
        }
        viewModelScope.launch { community.revision.collect { load() } }
    }

    fun load() {
        refresh?.cancel()
        refresh =
            viewModelScope.launch {
                mutableState.update { it.copy(loading = true, error = null) }
                try {
                    val channel = community.myChannel()
                    mutableState.update { it.copy(channel = channel, loading = false) }
                } catch (error: CancellationException) {
                    throw error
                } catch (error: Exception) {
                    mutableState.update { it.copy(loading = false, error = error.userMessage()) }
                }
            }
    }
}
