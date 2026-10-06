package com.beetle.playvoice.feature.moderation

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.beetle.playvoice.core.network.userMessage
import com.beetle.playvoice.domain.model.User
import com.beetle.playvoice.domain.repository.*
import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.flow.*
import kotlinx.coroutines.launch

data class ModerationUiState(
    val target: User? = null,
    val action: String? = null,
    val reason: String = "",
    val busy: Boolean = false,
    val error: String? = null,
    val submitted: Boolean = false,
)

class ModerationViewModel(
    private val community: CommunityRepository,
    private val voice: VoiceRepository,
) : ViewModel() {
    private val mutableState = MutableStateFlow(ModerationUiState())
    val state = mutableState.asStateFlow()

    fun select(user: User?) {
        if (!state.value.busy) mutableState.value = ModerationUiState(target = user)
    }

    fun action(action: String) {
        mutableState.update { it.copy(action = action, error = null) }
    }

    fun reason(reason: String) {
        mutableState.update { it.copy(reason = reason) }
    }

    fun submit() {
        val value = state.value
        val user = value.target ?: return
        if (value.busy || (value.action == "report" && value.reason.isBlank())) return
        mutableState.update { it.copy(busy = true, error = null) }
        viewModelScope.launch {
            try {
                when (value.action) {
                    "report" -> community.report(user.id, value.reason)
                    "block" -> {
                        community.block(user.id)
                        voice.hideMember(user.id)
                    }
                    "unfollow" -> community.follow(user.id, false)
                }
                mutableState.value =
                    if (value.action == "report") value.copy(submitted = true)
                    else ModerationUiState()
            } catch (error: CancellationException) {
                throw error
            } catch (error: Exception) {
                mutableState.update { it.copy(busy = false, error = error.userMessage()) }
            }
        }
    }
}
