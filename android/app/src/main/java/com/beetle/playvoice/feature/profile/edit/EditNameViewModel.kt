package com.beetle.playvoice.feature.profile.edit

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.beetle.playvoice.core.network.userMessage
import com.beetle.playvoice.domain.model.validName
import com.beetle.playvoice.domain.repository.*
import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.flow.*
import kotlinx.coroutines.launch

data class EditNameUiState(
    val value: String = "",
    val loading: Boolean = true,
    val saving: Boolean = false,
    val error: String? = null,
    val done: Boolean = false,
) {
    val valid: Boolean
        get() = validName(value)
}

class EditNameViewModel(
    val channel: Boolean,
    private val account: AccountRepository,
    private val community: CommunityRepository,
) : ViewModel() {
    private val mutableState = MutableStateFlow(EditNameUiState())
    val state = mutableState.asStateFlow()

    init {
        load()
    }

    fun load() {
        viewModelScope.launch {
            try {
                val name =
                    if (channel) community.myChannel().name
                    else account.preferences.value.session?.name.orEmpty()
                mutableState.value = EditNameUiState(value = name, loading = false)
            } catch (error: CancellationException) {
                throw error
            } catch (error: Exception) {
                mutableState.update { it.copy(error = error.userMessage(), loading = false) }
            }
        }
    }

    fun edit(value: String) {
        mutableState.update { it.copy(value = value, error = null) }
    }

    fun save() {
        if (!state.value.valid || state.value.saving || state.value.loading) return
        val name = state.value.value.trim()
        mutableState.update { it.copy(saving = true, error = null) }
        viewModelScope.launch {
            try {
                if (channel) community.renameChannel(name) else account.renameUser(name)
                mutableState.update { it.copy(saving = false, done = true) }
            } catch (error: CancellationException) {
                throw error
            } catch (error: Exception) {
                mutableState.update { it.copy(saving = false, error = error.userMessage()) }
            }
        }
    }
}
