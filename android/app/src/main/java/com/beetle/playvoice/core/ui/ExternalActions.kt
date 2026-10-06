package com.beetle.playvoice.core.ui

import android.content.ActivityNotFoundException
import android.content.Context
import android.content.Intent
import androidx.compose.runtime.*
import androidx.compose.ui.platform.LocalContext
import androidx.core.net.toUri

class ExternalActions(private val context: Context) {
    var error by mutableStateOf<String?>(null)
        private set

    fun open(url: String) {
        launch(Intent(Intent.ACTION_VIEW, url.toUri()))
    }

    fun share(text: String) {
        val intent =
            Intent(Intent.ACTION_SEND).setType("text/plain").putExtra(Intent.EXTRA_TEXT, text)
        launch(Intent.createChooser(intent, "Share GameVoice"))
    }

    private fun launch(intent: Intent) {
        error = null
        try {
            context.startActivity(intent)
        } catch (_: ActivityNotFoundException) {
            error = "No app is available to open this link."
        } catch (_: SecurityException) {
            error = "Unable to open this link."
        }
    }
}

@Composable
fun rememberExternalActions(): ExternalActions {
    val context = LocalContext.current
    return remember(context) { ExternalActions(context) }
}
