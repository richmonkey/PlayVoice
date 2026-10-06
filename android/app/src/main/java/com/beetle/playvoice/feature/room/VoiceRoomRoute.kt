package com.beetle.playvoice.feature.room

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.provider.Settings
import androidx.activity.compose.BackHandler
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.runtime.*
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.ui.platform.LocalContext
import androidx.core.content.ContextCompat
import androidx.core.net.toUri
import androidx.lifecycle.compose.LocalLifecycleOwner
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.lifecycle.withResumed
import com.beetle.playvoice.domain.model.User
import kotlinx.coroutines.launch

@Composable
fun VoiceRoomRoute(
    viewModel: VoiceRoomViewModel,
    onBack: () -> Unit,
    onUserActions: (User) -> Unit,
) {
    val state by viewModel.state.collectAsStateWithLifecycle()
    val voice by viewModel.voiceState.collectAsStateWithLifecycle()
    val context = LocalContext.current
    val lifecycle = LocalLifecycleOwner.current.lifecycle
    val scope = rememberCoroutineScope()
    var asked by rememberSaveable { mutableStateOf(false) }
    var denied by rememberSaveable { mutableStateOf(false) }
    val permission =
        rememberLauncherForActivityResult(ActivityResultContracts.RequestPermission()) { granted ->
            denied = !granted
            if (granted) scope.launch { lifecycle.withResumed { viewModel.join() } }
        }
    LaunchedEffect(state.channel, lifecycle) {
        if (state.channel != null && !asked) {
            lifecycle.withResumed {
                asked = true
                if (
                    ContextCompat.checkSelfPermission(context, Manifest.permission.RECORD_AUDIO) ==
                        PackageManager.PERMISSION_GRANTED
                ) {
                    viewModel.join()
                } else {
                    permission.launch(Manifest.permission.RECORD_AUDIO)
                }
            }
        }
    }
    val leave: () -> Unit = {
        viewModel.leave()
        onBack()
    }
    BackHandler(onBack = leave)
    VoiceRoomScreen(
        state = state,
        voice = voice,
        denied = denied,
        currentUserId = viewModel.currentUserId,
        onBack = leave,
        onMute = viewModel::toggleMute,
        onSpeaker = viewModel::toggleSpeaker,
        onSettings = {
            context.startActivity(
                Intent(
                    Settings.ACTION_APPLICATION_DETAILS_SETTINGS,
                    "package:${context.packageName}".toUri(),
                )
            )
        },
        onUserActions = onUserActions,
    )
}
