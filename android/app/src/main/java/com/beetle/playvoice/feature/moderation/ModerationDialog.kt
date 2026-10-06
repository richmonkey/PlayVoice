package com.beetle.playvoice.feature.moderation

import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.beetle.playvoice.core.ui.*

@Composable
fun ModerationRoute(viewModel: ModerationViewModel) {
    val state by viewModel.state.collectAsStateWithLifecycle()
    val target = state.target ?: return
    when {
        state.submitted ->
            AlertDialog(
                onDismissRequest = { viewModel.select(null) },
                title = { Text("Report Submitted") },
                text = { Text("Thanks — our team will review this within 24 hours.") },
                confirmButton = { TextButton(onClick = { viewModel.select(null) }) { Text("OK") } },
            )
        state.action == null ->
            AlertDialog(
                onDismissRequest = { viewModel.select(null) },
                title = { Text(target.name) },
                text = {
                    Column {
                        TextButton(onClick = { viewModel.action("report") }) { Text("Report User") }
                        TextButton(onClick = { viewModel.action("block") }) { Text("Block User") }
                        if (target.followed)
                            TextButton(onClick = { viewModel.action("unfollow") }) {
                                Text("Unfollow")
                            }
                    }
                },
                confirmButton = {
                    TextButton(onClick = { viewModel.select(null) }) { Text("Cancel") }
                },
            )
        state.action == "report" ->
            AlertDialog(
                onDismissRequest = { viewModel.select(null) },
                title = { Text("Report ${target.name}") },
                text = {
                    Column {
                        Text(
                            "Tell us what's wrong. Our team reviews reports and acts within 24 hours."
                        )
                        OutlinedTextField(
                            value = state.reason,
                            onValueChange = viewModel::reason,
                            label = { Text("Reason (e.g. harassment, hate speech)") },
                            enabled = !state.busy,
                        )
                        ErrorMessage(state.error)
                        if (state.busy) LinearProgressIndicator(Modifier.fillMaxWidth())
                    }
                },
                confirmButton = {
                    TextButton(
                        onClick = viewModel::submit,
                        enabled = !state.busy && state.reason.isNotBlank(),
                    ) {
                        Text("Submit")
                    }
                },
                dismissButton = {
                    TextButton(onClick = { viewModel.select(null) }, enabled = !state.busy) {
                        Text("Cancel")
                    }
                },
            )
        else ->
            Confirmation(
                title =
                    if (state.action == "block") "Block ${target.name}?"
                    else "Unfollow ${target.name}?",
                message =
                    if (state.action == "block")
                        "They'll be removed from your list immediately. This also reports them to our moderation team for review."
                    else "Their channel will be removed from your followed channels.",
                action = if (state.action == "block") "Block" else "Unfollow",
                busy = state.busy,
                error = state.error,
                onDismiss = { viewModel.select(null) },
                onConfirm = viewModel::submit,
            )
    }
}
