package com.beetle.playvoice.feature.search

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.beetle.playvoice.core.network.userMessage
import com.beetle.playvoice.domain.model.User
import com.beetle.playvoice.domain.repository.CommunityRepository
import kotlinx.coroutines.*
import kotlinx.coroutines.flow.*

data class SearchUiState(
    val query: String = "",
    val loading: Boolean = false,
    val users: List<User> = emptyList(),
    val pending: Set<Long> = emptySet(),
    val error: String? = null,
)

class SearchViewModel(private val community: CommunityRepository) : ViewModel() {
    private val mutableState = MutableStateFlow(SearchUiState())
    val state = mutableState.asStateFlow()
    private var searchJob: Job? = null
    private var sequence = 0L

    init {
        viewModelScope.launch { community.revision.drop(1).collect { search(state.value.query) } }
    }

    fun search(query: String) {
        val current = ++sequence
        searchJob?.cancel()
        mutableState.update {
            it.copy(query = query, loading = query.isNotBlank(), users = emptyList(), error = null)
        }
        if (query.isBlank()) return
        searchJob =
            viewModelScope.launch {
                delay(300)
                try {
                    val users = community.search(query.trim())
                    if (current == sequence)
                        mutableState.update { it.copy(loading = false, users = users) }
                } catch (error: CancellationException) {
                    throw error
                } catch (error: Exception) {
                    if (current == sequence)
                        mutableState.update {
                            it.copy(loading = false, error = error.userMessage())
                        }
                }
            }
    }

    fun toggleFollow(user: User) {
        if (user.id in state.value.pending) return
        mutableState.update { it.copy(pending = it.pending + user.id, error = null) }
        viewModelScope.launch {
            try {
                community.follow(user.id, !user.followed)
                mutableState.update { value ->
                    value.copy(
                        users =
                            value.users.map {
                                if (it.id == user.id) it.copy(followed = !user.followed) else it
                            }
                    )
                }
            } catch (error: CancellationException) {
                throw error
            } catch (error: Exception) {
                mutableState.update { it.copy(error = error.userMessage()) }
            } finally {
                mutableState.update { it.copy(pending = it.pending - user.id) }
            }
        }
    }
}
