package com.beetle.playvoice.feature.login

import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.LinkAnnotation
import androidx.compose.ui.text.SpanStyle
import androidx.compose.ui.text.TextLinkStyles
import androidx.compose.ui.text.buildAnnotatedString
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextDecoration
import androidx.compose.ui.text.withLink
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.beetle.playvoice.core.ui.ErrorMessage
import com.beetle.playvoice.core.ui.rememberExternalActions

private const val TERMS_URL =
    "https://daibou007.github.io/PrivacyAndSupport/GameVoice/terms.html"

@Composable
fun LoginScreen(state: LoginUiState, onAccept: (Boolean) -> Unit, onSignIn: () -> Unit) {
    val external = rememberExternalActions()
    Surface(
        modifier = Modifier.fillMaxSize(),
        color = MaterialTheme.colorScheme.background,
    ) {
        BoxWithConstraints(
            modifier = Modifier.fillMaxSize().safeDrawingPadding(),
            contentAlignment = Alignment.Center,
        ) {
            val viewportHeight = maxHeight
            Column(
                modifier = Modifier.widthIn(max = 440.dp)
                    .fillMaxWidth()
                    .verticalScroll(rememberScrollState())
                    .heightIn(min = viewportHeight)
                    .padding(horizontal = 28.dp, vertical = 32.dp),
                verticalArrangement = Arrangement.Center,
            ) {
                Surface(
                    shape = RoundedCornerShape(50),
                    color = MaterialTheme.colorScheme.primaryContainer,
                ) {
                    Text(
                        "VOICE CHAT FOR GAMERS",
                        modifier = Modifier.padding(horizontal = 12.dp, vertical = 8.dp),
                        color = MaterialTheme.colorScheme.primary,
                        style = MaterialTheme.typography.labelSmall,
                        letterSpacing = 1.sp,
                    )
                }
                Spacer(Modifier.height(24.dp))
                Text(
                    "Welcome Back",
                    fontSize = 40.sp,
                    lineHeight = 48.sp,
                    fontWeight = FontWeight.Bold,
                    letterSpacing = (-1).sp,
                )
                Spacer(Modifier.height(12.dp))
                Text(
                    "Your squad is one tap away.",
                    style = MaterialTheme.typography.titleLarge,
                    color = MaterialTheme.colorScheme.onBackground,
                )
                Spacer(Modifier.height(12.dp))
                Text(
                    "Sign in with Google to join your friends and start talking.",
                    style = MaterialTheme.typography.bodyLarge,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                )
                Spacer(Modifier.height(40.dp))
                TermsAgreement(
                    accepted = state.acceptedTerms,
                    enabled = !state.busy,
                    onAccept = onAccept,
                    onOpen = external::open,
                )
                Spacer(Modifier.height(20.dp))
                Button(
                    onClick = onSignIn,
                    enabled = state.acceptedTerms && !state.busy,
                    modifier = Modifier.fillMaxWidth().heightIn(min = 56.dp),
                    shape = RoundedCornerShape(18.dp),
                    contentPadding = PaddingValues(horizontal = 20.dp, vertical = 16.dp),
                ) {
                    if (state.busy) {
                        CircularProgressIndicator(
                            modifier = Modifier.size(18.dp),
                            strokeWidth = 2.dp,
                            color = MaterialTheme.colorScheme.onSurfaceVariant,
                        )
                        Spacer(Modifier.width(12.dp))
                    }
                    Text(
                        if (state.busy) "Signing in…" else "Continue with Google",
                        style = MaterialTheme.typography.titleSmall,
                    )
                }
                Spacer(Modifier.height(12.dp))
                Text(
                    "Use your Google account to sign in or get started.",
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                    style = MaterialTheme.typography.bodySmall,
                )
                if (state.error != null || external.error != null) {
                    Spacer(Modifier.height(20.dp))
                    ErrorMessage(state.error)
                    ErrorMessage(external.error)
                }
            }
        }
    }
}

@Composable
private fun TermsAgreement(
    accepted: Boolean,
    enabled: Boolean,
    onAccept: (Boolean) -> Unit,
    onOpen: (String) -> Unit,
) {
    val linkStyle = TextLinkStyles(
        SpanStyle(
            color = MaterialTheme.colorScheme.primary,
            textDecoration = TextDecoration.Underline,
        )
    )
    val agreement = buildAnnotatedString {
        append("I agree to the ")
        withLink(
            LinkAnnotation.Clickable(
                tag = "terms",
                styles = linkStyle,
                linkInteractionListener = { onOpen(TERMS_URL) },
            )
        ) {
            append("Terms of Service")
        }
        append(" and ")
        withLink(
            LinkAnnotation.Clickable(
                tag = "guidelines",
                styles = linkStyle,
                linkInteractionListener = { onOpen("$TERMS_URL#community-guidelines") },
            )
        ) {
            append("Community Guidelines")
        }
        append(".")
    }
    Surface(
        shape = RoundedCornerShape(18.dp),
        color = MaterialTheme.colorScheme.surface,
        border = BorderStroke(1.dp, MaterialTheme.colorScheme.outlineVariant),
        modifier = Modifier.fillMaxWidth(),
    ) {
        Row(
            modifier = Modifier.padding(start = 4.dp, end = 16.dp, top = 12.dp, bottom = 12.dp),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            Checkbox(checked = accepted, onCheckedChange = onAccept, enabled = enabled)
            Text(
                text = agreement,
                modifier = Modifier.weight(1f),
                style = MaterialTheme.typography.bodySmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
            )
        }
    }
}
