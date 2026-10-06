package com.beetle.playvoice.app

import android.content.Context
import android.util.Log
import androidx.credentials.ClearCredentialStateRequest
import androidx.credentials.CredentialManager
import com.beetle.playvoice.BuildConfig
import com.beetle.playvoice.core.datastore.PreferenceStore
import com.beetle.playvoice.core.network.*
import com.beetle.playvoice.data.remote.api.PlayVoiceApi
import com.beetle.playvoice.data.repository.*
import com.beetle.playvoice.domain.repository.*
import kotlinx.coroutines.*

class AppContainer(context: Context) {
    private val scope = CoroutineScope(SupervisorJob() + Dispatchers.Main.immediate)
    private val store = PreferenceStore(context)
    private val sessions = SessionManager(store, scope)
    private val api =
        createRetrofit(BuildConfig.API_BASE_URL, sessions).create(PlayVoiceApi::class.java)
    private val communityImpl = CommunityRepositoryImpl(api, sessions)
    val community: CommunityRepository = communityImpl
    val voice: VoiceRepository = VoiceRepositoryImpl(context, BuildConfig.ROOM_BASE_URL, scope)
    val account: AccountRepository =
        AccountRepositoryImpl(api, sessions, store, communityImpl::changed)

    init {
        sessions.onSessionEnded = {
            voice.leave()
            scope.launch {
                runCatching {
                        CredentialManager.create(context)
                            .clearCredentialState(ClearCredentialStateRequest())
                    }
                    .onFailure { Log.w("PlayVoice", "Unable to clear Google credential state", it) }
            }
        }
    }
}
