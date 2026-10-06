package com.beetle.playvoice.feature.onboarding

import androidx.compose.foundation.layout.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.beetle.playvoice.core.ui.Page

@Composable
fun OnboardingScreen(onComplete: () -> Unit) {
    var page by rememberSaveable { mutableIntStateOf(0) }
    val titles = listOf("Crystal-Clear Voice", "Your Channel, Your Squad", "Follow & Jump In")
    val descriptions =
        listOf(
            "GameVoice delivers low-latency, high-quality audio built for gaming.",
            "Every GameVoice user gets one exclusive channel. Make it yours.",
            "Search players, follow their channels, and join with a single tap.",
        )
    val icons = listOf(Icons.Default.Headset, Icons.Default.Groups, Icons.Default.Explore)
    Page("GameVoice", actions = { TextButton(onClick = onComplete) { Text("Skip") } }) { padding ->
        Column(
            Modifier.padding(padding).padding(32.dp).fillMaxSize(),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center,
        ) {
            Icon(icons[page], null, Modifier.size(100.dp), tint = MaterialTheme.colorScheme.primary)
            Spacer(Modifier.height(32.dp))
            Text(titles[page], style = MaterialTheme.typography.headlineMedium)
            Spacer(Modifier.height(16.dp))
            Text(descriptions[page])
            Spacer(Modifier.height(40.dp))
            Text("${page + 1} / 3")
            Button(onClick = { if (page == 2) onComplete() else page++ }) {
                Text(if (page == 2) "Get Started" else "Next")
            }
        }
    }
}
