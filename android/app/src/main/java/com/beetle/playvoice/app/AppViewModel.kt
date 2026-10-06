package com.beetle.playvoice.app

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.beetle.playvoice.domain.repository.AccountRepository
import kotlinx.coroutines.launch

class AppViewModel(private val account: AccountRepository) : ViewModel() {
    val preferences = account.preferences

    fun completeOnboarding() {
        viewModelScope.launch { account.completeOnboarding() }
    }
}
