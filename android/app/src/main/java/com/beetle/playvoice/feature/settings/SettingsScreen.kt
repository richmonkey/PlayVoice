package com.beetle.playvoice.feature.settings

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.beetle.playvoice.BuildConfig
import com.beetle.playvoice.core.ui.*
import com.beetle.playvoice.domain.model.ThemeMode

const val SUPPORT_URL = "https://daibou007.github.io/PrivacyAndSupport/GameVoice/support.html"

@Composable
fun SettingsRoute(viewModel: SettingsViewModel, onBack: () -> Unit, onBlocked: () -> Unit) {
    val state by viewModel.state.collectAsStateWithLifecycle()
    val preferences by viewModel.preferences.collectAsStateWithLifecycle()
    SettingsScreen(
        state,
        preferences.theme,
        viewModel::setTheme,
        viewModel::confirm,
        viewModel::perform,
        onBack,
        onBlocked,
    )
}

@Composable
fun SettingsScreen(
    state: SettingsUiState,
    theme: ThemeMode,
    onTheme: (ThemeMode) -> Unit,
    onConfirmation: (String?) -> Unit,
    onPerform: () -> Unit,
    onBack: () -> Unit,
    onBlocked: () -> Unit,
) {
    val external = rememberExternalActions()
    Page("Settings", onBack) { padding ->
        LazyColumn(
            Modifier.padding(padding),
            contentPadding = PaddingValues(24.dp),
            verticalArrangement = Arrangement.spacedBy(12.dp),
        ) {
            item { Text("Appearance", style = MaterialTheme.typography.titleLarge) }
            items(ThemeMode.entries.size) { index ->
                val mode = ThemeMode.entries[index]
                Row {
                    RadioButton(selected = theme == mode, onClick = { onTheme(mode) })
                    TextButton(onClick = { onTheme(mode) }) {
                        Text(mode.name.lowercase().replaceFirstChar { it.uppercase() })
                    }
                }
            }
            item { Text("Safety", style = MaterialTheme.typography.titleLarge) }
            item { SettingsButton("Blocked Users", onBlocked) }
            item { Text("Support", style = MaterialTheme.typography.titleLarge) }
            item { SettingsButton("Help Center") { external.open(SUPPORT_URL) } }
            item {
                SettingsButton("Contact Support · daibou007@gmail.com") {
                    external.open("mailto:daibou007@gmail.com")
                }
            }
            item { SettingsButton("Share GameVoice") { external.share(SUPPORT_URL) } }
            item { Text("Legal", style = MaterialTheme.typography.titleLarge) }
            item {
                SettingsButton("Privacy Policy") {
                    external.open(
                        "https://daibou007.github.io/PrivacyAndSupport/GameVoice/privacy.html"
                    )
                }
            }
            item {
                SettingsButton("Terms of Service") {
                    external.open(
                        "https://daibou007.github.io/PrivacyAndSupport/GameVoice/terms.html"
                    )
                }
            }
            item {
                Text(
                    "GameVoice · ${BuildConfig.VERSION_NAME}",
                    style = MaterialTheme.typography.titleLarge,
                )
            }
            item {
                Text(
                    "Real-time voice chat for gaming squads. Low-latency WebRTC audio, a personal voice channel, and players to follow and join."
                )
            }
            item { ErrorMessage(external.error) }
            item { ErrorMessage(if (state.confirmation == null) state.error else null) }
            item { SettingsButton("Sign Out") { onConfirmation("logout") } }
            item { SettingsButton("Delete Account") { onConfirmation("delete") } }
        }
    }
    state.confirmation?.let { action ->
        Confirmation(
            title = if (action == "delete") "Delete Account?" else "Sign Out?",
            message =
                if (action == "delete")
                    "This permanently deletes your account and its data. This cannot be undone."
                else "You can sign in again with your Google account.",
            action = if (action == "delete") "Delete" else "Sign Out",
            busy = state.busy,
            error = state.error,
            onDismiss = { onConfirmation(null) },
            onConfirm = onPerform,
        )
    }
}

@Composable
private fun SettingsButton(label: String, onClick: () -> Unit) {
    OutlinedButton(onClick = onClick, modifier = Modifier.fillMaxWidth()) { Text(label) }
}
