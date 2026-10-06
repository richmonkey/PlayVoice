package com.beetle.playvoice.feature.login

import androidx.compose.runtime.*
import androidx.compose.ui.platform.LocalContext
import androidx.credentials.*
import androidx.credentials.exceptions.GetCredentialCancellationException
import androidx.credentials.exceptions.NoCredentialException
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.beetle.playvoice.BuildConfig
import com.google.android.libraries.identity.googleid.*
import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.launch

@Composable
fun LoginRoute(viewModel: LoginViewModel) {
    val state by viewModel.state.collectAsStateWithLifecycle()
    val context = LocalContext.current
    val scope = rememberCoroutineScope()
    LoginScreen(state, viewModel::acceptTerms) {
        if (!viewModel.begin()) return@LoginScreen
        if (BuildConfig.GOOGLE_SERVER_CLIENT_ID.isBlank()) {
            viewModel.failed("Google sign-in is not configured. Please contact support.")
            return@LoginScreen
        }
        scope.launch {
            try {
                val option =
                    GetSignInWithGoogleOption.Builder(BuildConfig.GOOGLE_SERVER_CLIENT_ID).build()
                val result =
                    CredentialManager.create(context)
                        .getCredential(
                            context,
                            GetCredentialRequest.Builder().addCredentialOption(option).build(),
                        )
                val credential = result.credential
                check(
                    credential is CustomCredential &&
                        credential.type == GoogleIdTokenCredential.TYPE_GOOGLE_ID_TOKEN_CREDENTIAL
                ) {
                    "Unable to sign in with Google. Please try again."
                }
                viewModel.login(GoogleIdTokenCredential.createFrom(credential.data).idToken)
            } catch (_: NoCredentialException) {
                viewModel.failed(
                    "No Google account is available. Add an account on this device and try again."
                )
            } catch (_: GetCredentialCancellationException) {
                viewModel.cancelled()
            } catch (error: CancellationException) {
                viewModel.cancelled()
                throw error
            } catch (error: Exception) {
                viewModel.failed(error.message ?: "Unable to sign in. Please try again.")
            }
        }
    }
}
