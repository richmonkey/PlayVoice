package com.beetle.playvoice.app

import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.lifecycle.ViewModelStore
import androidx.lifecycle.ViewModelStoreOwner
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.lifecycle.viewmodel.compose.LocalViewModelStoreOwner
import com.beetle.playvoice.app.navigation.AppNavHost
import com.beetle.playvoice.core.ui.*
import com.beetle.playvoice.domain.repository.*
import com.beetle.playvoice.feature.login.*
import com.beetle.playvoice.feature.onboarding.OnboardingScreen

@Composable
fun PlayVoiceApp(
    account: AccountRepository,
    community: CommunityRepository,
    voice: VoiceRepository,
) {
    val model = injectedViewModel { AppViewModel(account) }
    val preferences by model.preferences.collectAsStateWithLifecycle()
    val sessionStore =
        injectedViewModel<SessionViewModelStore>(key = "sessionStore") { SessionViewModelStore() }
    val owner = sessionStore.owner(preferences.session?.token)
    PlayVoiceTheme(preferences.theme) {
        Surface(Modifier.fillMaxSize(), color = MaterialTheme.colorScheme.background) {
            when {
                !preferences.ready ->
                    Box(Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                        CircularProgressIndicator()
                    }
                !preferences.onboarded -> OnboardingScreen(model::completeOnboarding)
                preferences.session == null -> {
                    CompositionLocalProvider(LocalViewModelStoreOwner provides owner) {
                        LoginRoute(injectedViewModel { LoginViewModel(account) })
                    }
                }
                else -> {
                    val sessionKey = preferences.session!!.token
                    // The store belongs to the signed-in session and survives Activity recreation.
                    key(sessionKey) {
                        CompositionLocalProvider(LocalViewModelStoreOwner provides owner) {
                            AppNavHost(account, community, voice, sessionKey)
                        }
                    }
                }
            }
        }
    }
    LaunchedEffect(preferences.session?.token) {
        if (preferences.ready && preferences.session == null) {
            voice.leave()
        }
    }
}

class SessionViewModelStore : androidx.lifecycle.ViewModel() {
    private var currentKey: String? = null
    private val store = ViewModelStore()
    private val owner =
        object : ViewModelStoreOwner {
            override val viewModelStore = store
        }

    fun owner(key: String?): ViewModelStoreOwner {
        if (currentKey != key) {
            store.clear()
            currentKey = key
        }
        return owner
    }

    override fun onCleared() = store.clear()
}
