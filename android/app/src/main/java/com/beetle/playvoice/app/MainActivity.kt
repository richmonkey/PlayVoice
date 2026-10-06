package com.beetle.playvoice.app

import android.content.res.Configuration
import android.graphics.Color
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.SystemBarStyle
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.lifecycleScope
import androidx.lifecycle.repeatOnLifecycle
import com.beetle.playvoice.domain.model.ThemeMode
import kotlinx.coroutines.launch

class MainActivity : ComponentActivity() {
    private val container
        get() = (application as PlayVoiceApplication).container

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        lifecycleScope.launch {
            repeatOnLifecycle(Lifecycle.State.STARTED) {
                container.account.preferences.collect { preferences ->
                    val dark =
                        when (preferences.theme) {
                            ThemeMode.SYSTEM ->
                                resources.configuration.uiMode and
                                    Configuration.UI_MODE_NIGHT_MASK ==
                                    Configuration.UI_MODE_NIGHT_YES
                            ThemeMode.DARK -> true
                            ThemeMode.LIGHT -> false
                        }
                    val style =
                        if (dark) SystemBarStyle.dark(Color.TRANSPARENT)
                        else SystemBarStyle.light(Color.TRANSPARENT, Color.TRANSPARENT)
                    enableEdgeToEdge(statusBarStyle = style, navigationBarStyle = style)
                }
            }
        }
        setContent { PlayVoiceApp(container.account, container.community, container.voice) }
    }

    override fun onStop() {
        super.onStop()
        if (!isChangingConfigurations) container.voice.leave()
    }
}
