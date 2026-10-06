package com.beetle.playvoice.feature.profile

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Settings
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.beetle.playvoice.core.ui.*

@Composable
fun ProfileRoute(
    viewModel: ProfileViewModel,
    onBack: () -> Unit,
    onEdit: (String) -> Unit,
    onSettings: () -> Unit,
) {
    val state by viewModel.state.collectAsStateWithLifecycle()
    ProfileScreen(state, onBack, onEdit, viewModel::load, onSettings)
}

@Composable
fun ProfileScreen(
    state: ProfileUiState,
    onBack: () -> Unit,
    onEdit: (String) -> Unit,
    onRetry: () -> Unit,
    onSettings: () -> Unit,
) {
    Page(
        "Profile",
        onBack,
        actions = {
            IconButton(onClick = onSettings) {
                Icon(Icons.Default.Settings, "Settings")
            }
        },
    ) { padding ->
        Column(
            Modifier.padding(padding).padding(24.dp).verticalScroll(rememberScrollState()),
            verticalArrangement = Arrangement.spacedBy(20.dp),
        ) {
            state.session?.let { session ->
                Avatar(session.name, session.avatarUrl, Modifier.size(80.dp))
                Text(session.name, style = MaterialTheme.typography.headlineMedium)
                Text(session.email)
                Text("General", style = MaterialTheme.typography.titleLarge)
                OutlinedButton(onClick = { onEdit("name") }, modifier = Modifier.fillMaxWidth()) {
                    Text("Display Name: ${session.name}")
                }
                Text("Email: ${session.email}")
            }
            Text("Channel", style = MaterialTheme.typography.titleLarge)
            if (state.loading) LinearProgressIndicator(Modifier.fillMaxWidth())
            ErrorMessage(state.error, onRetry)
            state.channel?.let { channel ->
                OutlinedButton(
                    onClick = { onEdit("channel") },
                    modifier = Modifier.fillMaxWidth(),
                ) {
                    Text("Channel Name: ${channel.name}")
                }
            }
        }
    }
}
