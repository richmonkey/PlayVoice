package com.beetle.playvoice.feature.settings.blocked

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.beetle.playvoice.core.ui.*

@Composable
fun BlockedUsersRoute(viewModel: BlockedUsersViewModel, onBack: () -> Unit) {
    val state by viewModel.state.collectAsStateWithLifecycle()
    BlockedUsersScreen(state, onBack, viewModel::load, viewModel::unblock)
}

@Composable
fun BlockedUsersScreen(
    state: BlockedUsersUiState,
    onBack: () -> Unit,
    onRetry: () -> Unit,
    onUnblock: (Long) -> Unit,
) {
    Page("Blocked Users", onBack) { padding ->
        LazyColumn(
            Modifier.padding(padding),
            contentPadding = PaddingValues(20.dp),
            verticalArrangement = Arrangement.spacedBy(12.dp),
        ) {
            item {
                if (state.loading) LinearProgressIndicator(Modifier.fillMaxWidth())
                ErrorMessage(state.error, onRetry)
                if (!state.loading && state.users.isEmpty() && state.error == null)
                    Text("No blocked users")
            }
            items(state.users, key = { it.id }) { user ->
                Row(horizontalArrangement = Arrangement.spacedBy(12.dp)) {
                    Avatar(user.name, user.avatarUrl)
                    Text(user.name, Modifier.weight(1f))
                    TextButton(
                        onClick = { onUnblock(user.id) },
                        enabled = user.id !in state.pending,
                    ) {
                        Text("Unblock")
                    }
                }
            }
        }
    }
}
