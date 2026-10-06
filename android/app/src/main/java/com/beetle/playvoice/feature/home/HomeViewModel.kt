package com.beetle.playvoice.feature.home

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.beetle.playvoice.core.network.userMessage
import com.beetle.playvoice.domain.model.Channel
import com.beetle.playvoice.domain.repository.CommunityRepository
import kotlinx.coroutines.*
import kotlinx.coroutines.flow.*

data class HomeUiState(
    val loading: Boolean = true,
    val mine: Channel? = null,
    val followed: List<Channel> = emptyList(),
    val error: String? = null,
)

class HomeViewModel(private val community: CommunityRepository) : ViewModel() {
    private val mutableState = MutableStateFlow(HomeUiState())
    val state = mutableState.asStateFlow()
    private var refresh: Job? = null

    init {
        viewModelScope.launch { community.revision.collect { load() } }
    }

    fun load() {
        refresh?.cancel()
        refresh =
            viewModelScope.launch {
                mutableState.update { it.copy(loading = true, error = null) }
                try {
                    coroutineScope {
                        val mine = async { community.myChannel() }
                        val followed = async { community.followedChannels() }
                        mutableState.value =
                            HomeUiState(
                                loading = false,
                                mine = mine.await(),
                                followed = followed.await(),
                            )
                    }
                } catch (error: CancellationException) {
                    throw error
                } catch (error: Exception) {
                    mutableState.update { it.copy(loading = false, error = error.userMessage()) }
                }
            }
    }
}
