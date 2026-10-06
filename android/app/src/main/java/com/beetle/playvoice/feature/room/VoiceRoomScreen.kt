package com.beetle.playvoice.feature.room

import androidx.compose.foundation.border
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.grid.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import com.beetle.playvoice.core.ui.*
import com.beetle.playvoice.domain.model.*

@Composable
fun VoiceRoomScreen(
    state: VoiceRoomUiState,
    voice: VoiceState,
    denied: Boolean,
    currentUserId: Long,
    onBack: () -> Unit,
    onJoin: () -> Unit,
    onReload: () -> Unit,
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
                    Connection.IDLE -> "You have left the room"
                    Connection.CONNECTING -> "Connecting…"
                    Connection.CONNECTED -> "Connected"
                    Connection.RECONNECTING -> "Reconnecting…"
                    Connection.FAILED -> "Connection Failed"
                }
            Text(status, style = MaterialTheme.typography.titleMedium)
            if (state.loading) LinearProgressIndicator(Modifier.fillMaxWidth())
            ErrorMessage(state.error, onReload)
            ErrorMessage(voice.error)
            if (denied) {
                Text("Microphone access denied. Allow it to join voice chat.")
                Row {
                    TextButton(onClick = onJoin) { Text("Retry permission") }
                    TextButton(onClick = onSettings) { Text("Open Settings") }
                }
            } else if (
                state.channel != null &&
                    voice.connection in listOf(Connection.IDLE, Connection.FAILED)
            ) {
                Button(onClick = onJoin) { Text("Rejoin") }
            }
            LazyVerticalGrid(
                columns = GridCells.Adaptive(140.dp),
                modifier = Modifier.weight(1f),
                verticalArrangement = Arrangement.spacedBy(12.dp),
                horizontalArrangement = Arrangement.spacedBy(12.dp),
            ) {
                items(voice.members, key = { it.id }) { member ->
                    Card(
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
                        modifier =
                            Modifier.border(
                                2.dp,
                                if (member.speaking) Color(0xFF00C48C) else Color.Transparent,
                                RoundedCornerShape(12.dp),
                            ),
                    ) {
                        Column(
                            Modifier.padding(16.dp),
                            verticalArrangement = Arrangement.spacedBy(8.dp),
                        ) {
                            Avatar(member.name, null)
                            Text(member.name, style = MaterialTheme.typography.titleMedium)
                            if (member.owner)
                                Text("Host", color = MaterialTheme.colorScheme.primary)
                            Icon(
                                if (member.muted) Icons.Default.MicOff else Icons.Default.Mic,
                                if (member.muted) "Muted" else "Microphone on",
                            )
                            if (member.speaking) Text("Speaking", color = Color(0xFF00C48C))
                        }
                    }
                }
            }
            Text("Output: ${voice.route}", style = MaterialTheme.typography.bodySmall)
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
