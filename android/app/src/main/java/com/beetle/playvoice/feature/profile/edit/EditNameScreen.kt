package com.beetle.playvoice.feature.profile.edit

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.focus.FocusRequester
import androidx.compose.ui.focus.focusRequester
import androidx.compose.ui.platform.LocalSoftwareKeyboardController
import androidx.compose.ui.unit.dp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.beetle.playvoice.core.ui.*

@Composable
fun EditNameRoute(viewModel: EditNameViewModel, onBack: () -> Unit) {
    val state by viewModel.state.collectAsStateWithLifecycle()
    LaunchedEffect(state.done) { if (state.done) onBack() }
    EditNameScreen(state, viewModel.channel, viewModel::edit, viewModel::save, onBack)
}

@Composable
fun EditNameScreen(
    state: EditNameUiState,
    channel: Boolean,
    onEdit: (String) -> Unit,
    onSave: () -> Unit,
    onBack: () -> Unit,
) {
    val focus = remember { FocusRequester() }
    val keyboard = LocalSoftwareKeyboardController.current
    Page(if (channel) "Edit Channel Name" else "Edit Display Name", onBack) { padding ->
        Column(
            Modifier.padding(padding)
                .padding(24.dp)
                .imePadding()
                .verticalScroll(rememberScrollState()),
            verticalArrangement = Arrangement.spacedBy(16.dp),
        ) {
            val enabled = !state.loading && !state.saving
            OutlinedTextField(
                value = state.value,
                onValueChange = onEdit,
                label = { Text(if (channel) "Channel Name" else "Display Name") },
                enabled = enabled,
                singleLine = true,
                isError = state.value.isNotEmpty() && !state.valid,
                modifier = Modifier.fillMaxWidth().focusRequester(focus),
            )
            LaunchedEffect(focus, enabled) {
                if (enabled) {
                    withFrameNanos {}
                    focus.requestFocus()
                    keyboard?.show()
                }
            }
            Text("2–30 characters. Cannot be blank.")
            ErrorMessage(state.error)
            if (state.loading || state.saving) LinearProgressIndicator(Modifier.fillMaxWidth())
            Button(
                onClick = onSave,
                enabled = enabled && state.valid,
                modifier = Modifier.fillMaxWidth(),
            ) {
                Text("Save")
            }
        }
    }
}
