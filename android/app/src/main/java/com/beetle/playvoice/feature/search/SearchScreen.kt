package com.beetle.playvoice.feature.search

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.MoreVert
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.beetle.playvoice.core.ui.*
import com.beetle.playvoice.domain.model.User

@Composable
fun SearchRoute(viewModel: SearchViewModel, onBack: () -> Unit, onUserActions: (User) -> Unit) {
    val state by viewModel.state.collectAsStateWithLifecycle()
    SearchScreen(state, viewModel::search, viewModel::toggleFollow, onBack, onUserActions)
}

@Composable
fun SearchScreen(
    state: SearchUiState,
    onQuery: (String) -> Unit,
    onFollow: (User) -> Unit,
    onBack: () -> Unit,
    onUserActions: (User) -> Unit,
) {
    Page("Search", onBack) { padding ->
        Column(
            Modifier.padding(padding).padding(20.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp),
        ) {
            OutlinedTextField(
                value = state.query,
                onValueChange = onQuery,
                label = { Text("Search by name or channel") },
                singleLine = true,
                modifier = Modifier.fillMaxWidth(),
            )
            if (state.loading) LinearProgressIndicator(Modifier.fillMaxWidth())
            ErrorMessage(state.error) { onQuery(state.query) }
            if (!state.loading && state.users.isEmpty() && state.error == null) {
                Text(
                    if (state.query.isBlank()) "Enter a name or channel to search and follow users"
                    else "No users found"
                )
            }
            LazyColumn(verticalArrangement = Arrangement.spacedBy(12.dp)) {
                items(state.users, key = { it.id }) { user ->
                    Card(Modifier.fillMaxWidth()) {
                        Row(
                            Modifier.padding(12.dp),
                            horizontalArrangement = Arrangement.spacedBy(8.dp),
                        ) {
                            Avatar(user.name, user.avatarUrl)
                            Column(Modifier.weight(1f)) {
                                Text(user.name, style = MaterialTheme.typography.titleMedium)
                                Text(
                                    "Channel: ${user.channelName}",
                                    style = MaterialTheme.typography.bodySmall,
                                )
                            }
                            TextButton(
                                onClick = { onFollow(user) },
                                enabled = user.id !in state.pending,
                            ) {
                                Text(if (user.followed) "Following" else "Follow")
                            }
                            IconButton(onClick = { onUserActions(user) }) {
                                Icon(Icons.Default.MoreVert, "User actions")
                            }
                        }
                    }
                }
            }
        }
    }
}
