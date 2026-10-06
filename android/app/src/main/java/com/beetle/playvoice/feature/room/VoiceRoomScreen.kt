package com.beetle.playvoice.feature.room

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.grid.*
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import com.beetle.playvoice.core.ui.*
import com.beetle.playvoice.domain.model.*
import com.beetle.playvoice.feature.room.component.MemberItem

@Composable
fun VoiceRoomScreen(
    state: VoiceRoomUiState,
    voice: VoiceState,
    denied: Boolean,
    currentUserId: Long,
    onBack: () -> Unit,
    onMute: () -> Unit,
    onSpeaker: () -> Unit,
    onSettings: () -> Unit,
    onUserActions: (User) -> Unit,
) {
    Page(state.channel?.name ?: "Voice Room", onBack) { padding ->
        Column(
            Modifier.padding(padding).padding(20.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp),
        ) {
            val status =
                when (voice.connection) {
                    Connection.IDLE ->
                        if (state.loading) "Loading room…" else "Not connected"
                    Connection.CONNECTING -> "Connecting…"
                    Connection.CONNECTED -> "Connected"
                    Connection.RECONNECTING -> "Reconnecting…"
                    Connection.FAILED -> "Connection Failed"
                }
            Text(
                text = status,
                modifier = Modifier.fillMaxWidth(),
                style = MaterialTheme.typography.bodySmall,
                textAlign = TextAlign.Center,
            )
            if (state.loading) LinearProgressIndicator(Modifier.fillMaxWidth())
            ErrorMessage(state.error)
            ErrorMessage(voice.error)
            if (denied) {
                Text("Microphone access denied. Allow it to join voice chat.")
                TextButton(onClick = onSettings) { Text("Open Settings") }
            }
            LazyVerticalGrid(
                columns = GridCells.Fixed(2),
                modifier = Modifier.weight(1f),
            ) {
                items(voice.members, key = { it.id }) { member ->
                    MemberItem(
                        member = member,
                        onClick = {
                            member.id
                                .toLongOrNull()
                                ?.takeIf { it != currentUserId }
                                ?.let {
                                    onUserActions(
                                        User(it, member.name, null, state.channel?.name.orEmpty())
                                    )
                                }
                        },
                    )
                }
            }
            Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                FilledTonalButton(
                    onClick = onMute,
                    enabled = voice.connection == Connection.CONNECTED,
                    modifier = Modifier.weight(1f),
                ) {
                    Text(if (voice.muted) "Unmute" else "Mute")
                }
                FilledTonalButton(
                    onClick = onSpeaker,
                    enabled = voice.connection == Connection.CONNECTED,
                    modifier = Modifier.weight(1f),
                ) {
                    Text(if (voice.speaker) "Earpiece" else "Speaker")
                }
            }
            Button(
                onClick = onBack,
                modifier = Modifier.fillMaxWidth(),
                colors =
                    ButtonDefaults.buttonColors(containerColor = MaterialTheme.colorScheme.error),
            ) {
                Text("Leave")
            }
        }
    }
}
