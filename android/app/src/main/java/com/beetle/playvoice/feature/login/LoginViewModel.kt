package com.beetle.playvoice.feature.login

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.beetle.playvoice.core.network.userMessage
import com.beetle.playvoice.domain.repository.AccountRepository
import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.flow.*
import kotlinx.coroutines.launch

data class LoginUiState(
    val acceptedTerms: Boolean = false,
    val busy: Boolean = false,
    val error: String? = null,
)

class LoginViewModel(private val account: AccountRepository) : ViewModel() {
    private val mutableState = MutableStateFlow(LoginUiState())
    val state = mutableState.asStateFlow()

    fun acceptTerms(accepted: Boolean) {
        mutableState.update { it.copy(acceptedTerms = accepted) }
    }

    fun begin(): Boolean {
        if (!state.value.acceptedTerms || state.value.busy) return false
        mutableState.update { it.copy(busy = true, error = null) }
        return true
    }

    fun cancelled() {
        mutableState.update { it.copy(busy = false, error = null) }
    }

    fun failed(message: String) {
        mutableState.update { it.copy(busy = false, error = message) }
    }

    fun login(idToken: String) {
        viewModelScope.launch {
            try {
                account.login(idToken)
                cancelled()
            } catch (error: CancellationException) {
                cancelled()
                throw error
            } catch (error: Exception) {
                failed(error.userMessage())
            }
        }
    }
}
