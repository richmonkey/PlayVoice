package com.beetle.playvoice.feature.home

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.beetle.playvoice.core.ui.*
import com.beetle.playvoice.domain.model.*

@Composable
fun HomeRoute(
    viewModel: HomeViewModel,
    onChannel: (Long) -> Unit,
    onSearch: () -> Unit,
    onProfile: () -> Unit,
    onUserActions: (User) -> Unit,
) {
    val state by viewModel.state.collectAsStateWithLifecycle()
    HomeScreen(state, viewModel::load, onChannel, onSearch, onProfile, onUserActions)
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun HomeScreen(
    state: HomeUiState,
    onRefresh: () -> Unit,
    onChannel: (Long) -> Unit,
    onSearch: () -> Unit,
    onProfile: () -> Unit,
    onUserActions: (User) -> Unit,
) {
    Page(
        "Home",
        actions = {
            IconButton(onClick = onSearch) { Icon(Icons.Default.Search, "Search") }
            IconButton(onClick = onProfile) { Icon(Icons.Default.Person, "Profile") }
        },
    ) { padding ->
        androidx.compose.material3.pulltorefresh.PullToRefreshBox(
            isRefreshing = state.loading,
            onRefresh = onRefresh,
            modifier = Modifier.padding(padding).fillMaxSize(),
        ) {
            LazyColumn(
                contentPadding = PaddingValues(20.dp),
                verticalArrangement = Arrangement.spacedBy(16.dp),
            ) {
                item {
                    Text("My Channel", style = MaterialTheme.typography.titleLarge)
                }
                item {
                    state.mine?.let { channel -> ChannelCard(channel, onChannel, null) }
                        ?: Text(if (state.loading) "Loading…" else "Load failed")
                }
                if (state.error != null) {
                    item { ErrorMessage(state.error, onRefresh) }
                }
                item { Text("Followed Channels", style = MaterialTheme.typography.titleLarge) }
                if (!state.loading && state.followed.isEmpty() && state.error == null) {
                    item { Text("No followed channels yet. Tap Search to discover users.") }
                }
                items(state.followed, key = { it.id }) { channel ->
                    ChannelCard(channel, onChannel) {
                        onUserActions(
                            User(
                                channel.ownerId,
                                channel.ownerName,
                                channel.avatarUrl,
                                channel.name,
                                followed = true,
                            )
                        )
                    }
                }
            }
        }
    }
}

@Composable
private fun ChannelCard(channel: Channel, onChannel: (Long) -> Unit, onMore: (() -> Unit)?) {
    Card(onClick = { onChannel(channel.id) }, modifier = Modifier.fillMaxWidth()) {
        Row(Modifier.padding(16.dp), horizontalArrangement = Arrangement.spacedBy(12.dp)) {
            Avatar(channel.ownerName, channel.avatarUrl)
            Column(Modifier.weight(1f)) {
                Text(channel.name, style = MaterialTheme.typography.titleMedium)
                Text(channel.ownerName, color = MaterialTheme.colorScheme.onSurfaceVariant)
            }
            if (onMore != null)
                IconButton(onClick = onMore) { Icon(Icons.Default.MoreVert, "User actions") }
        }
    }
}
