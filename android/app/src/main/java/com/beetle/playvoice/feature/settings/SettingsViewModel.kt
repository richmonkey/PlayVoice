package com.beetle.playvoice.feature.settings

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.beetle.playvoice.core.network.userMessage
import com.beetle.playvoice.domain.model.ThemeMode
import com.beetle.playvoice.domain.repository.AccountRepository
import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.flow.*
import kotlinx.coroutines.launch

data class SettingsUiState(
    val busy: Boolean = false,
    val error: String? = null,
    val confirmation: String? = null,
)

class SettingsViewModel(private val account: AccountRepository) : ViewModel() {
    val preferences = account.preferences
    private val mutableState = MutableStateFlow(SettingsUiState())
    val state = mutableState.asStateFlow()

    fun confirm(action: String?) {
        if (!state.value.busy) mutableState.value = SettingsUiState(confirmation = action)
    }

    fun setTheme(theme: ThemeMode) {
        viewModelScope.launch {
            try {
                account.setTheme(theme)
            } catch (error: CancellationException) {
                throw error
            } catch (error: Exception) {
                mutableState.update { it.copy(error = error.userMessage()) }
            }
        }
    }

    fun perform() {
        if (state.value.busy) return
        val action = state.value.confirmation ?: return
        mutableState.update { it.copy(busy = true, error = null) }
        viewModelScope.launch {
            try {
                if (action == "delete") account.deleteAccount() else account.logout()
                mutableState.value = SettingsUiState()
            } catch (error: CancellationException) {
                throw error
            } catch (error: Exception) {
                mutableState.update { it.copy(busy = false, error = error.userMessage()) }
            }
        }
    }
}
