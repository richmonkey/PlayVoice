package com.beetle.playvoice.feature.login

import androidx.compose.foundation.Image
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.unit.dp
import com.beetle.playvoice.R
import com.beetle.playvoice.core.ui.*

@Composable
fun LoginScreen(state: LoginUiState, onAccept: (Boolean) -> Unit, onSignIn: () -> Unit) {
    val external = rememberExternalActions()
    Page("GameVoice") { padding ->
        Column(
            Modifier.padding(padding)
                .padding(24.dp)
                .verticalScroll(rememberScrollState())
                .fillMaxSize(),
            verticalArrangement =
                Arrangement.spacedBy(20.dp, androidx.compose.ui.Alignment.CenterVertically),
        ) {
            Image(painterResource(R.drawable.gamevoice_logo), "GameVoice", Modifier.size(88.dp))
            Text("SIGN IN", color = MaterialTheme.colorScheme.primary)
            Text("Welcome Back", style = MaterialTheme.typography.headlineLarge)
            Text("Voice Chat for Gamers", style = MaterialTheme.typography.titleMedium)
            Text("Sign in with your Google account.")
            Row {
                Checkbox(
                    checked = state.acceptedTerms,
                    onCheckedChange = onAccept,
                    enabled = !state.busy,
                )
                Text(
                    "I agree to the Terms of Service and Community Guidelines.",
                    Modifier.padding(top = 12.dp),
                )
            }
            Row {
                TextButton(
                    onClick = {
                        external.open(
                            "https://daibou007.github.io/PrivacyAndSupport/GameVoice/terms.html"
                        )
                    }
                ) {
                    Text("Terms of Service")
                }
                TextButton(
                    onClick = {
                        external.open(
                            "https://daibou007.github.io/PrivacyAndSupport/GameVoice/terms.html#community-guidelines"
                        )
                    }
                ) {
                    Text("Community Guidelines")
                }
            }
            Button(
                onClick = onSignIn,
                enabled = state.acceptedTerms && !state.busy,
                modifier = Modifier.fillMaxWidth(),
            ) {
                Text(if (state.busy) "Signing in…" else "Continue with Google")
            }
            if (state.busy) LinearProgressIndicator(Modifier.fillMaxWidth())
            ErrorMessage(state.error)
            ErrorMessage(external.error)
        }
    }
}
