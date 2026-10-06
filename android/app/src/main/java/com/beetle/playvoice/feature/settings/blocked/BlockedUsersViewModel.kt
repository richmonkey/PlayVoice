package com.beetle.playvoice.feature.settings.blocked

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.beetle.playvoice.core.network.userMessage
import com.beetle.playvoice.domain.model.User
import com.beetle.playvoice.domain.repository.CommunityRepository
import kotlinx.coroutines.*
import kotlinx.coroutines.flow.*

data class BlockedUsersUiState(
    val users: List<User> = emptyList(),
    val loading: Boolean = true,
    val pending: Set<Long> = emptySet(),
    val error: String? = null,
)

class BlockedUsersViewModel(private val community: CommunityRepository) : ViewModel() {
    private val mutableState = MutableStateFlow(BlockedUsersUiState())
    val state = mutableState.asStateFlow()
    private var loadJob: Job? = null

    init {
        load()
    }

    fun load() {
        loadJob?.cancel()
        loadJob =
            viewModelScope.launch {
                mutableState.update { it.copy(loading = true, error = null) }
                try {
                    val users = community.blockedUsers()
                    mutableState.update { it.copy(users = users, loading = false) }
                } catch (error: CancellationException) {
                    throw error
                } catch (error: Exception) {
                    mutableState.update { it.copy(loading = false, error = error.userMessage()) }
                }
            }
    }

    fun unblock(id: Long) {
        if (id in state.value.pending) return
        mutableState.update { it.copy(pending = it.pending + id, error = null) }
        viewModelScope.launch {
            try {
                community.unblock(id)
                mutableState.update {
                    it.copy(users = it.users.filterNot { user -> user.id == id })
                }
            } catch (error: CancellationException) {
                throw error
            } catch (error: Exception) {
                mutableState.update { it.copy(error = error.userMessage()) }
            } finally {
                mutableState.update { it.copy(pending = it.pending - id) }
            }
        }
    }
}
