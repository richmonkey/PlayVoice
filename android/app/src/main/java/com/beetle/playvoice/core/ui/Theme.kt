package com.beetle.playvoice.core.ui

import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import com.beetle.playvoice.domain.model.ThemeMode

@Composable
fun PlayVoiceTheme(mode: ThemeMode = ThemeMode.SYSTEM, content: @Composable () -> Unit) {
    val dark =
        when (mode) {
            ThemeMode.SYSTEM -> isSystemInDarkTheme()
            ThemeMode.LIGHT -> false
            ThemeMode.DARK -> true
        }
    val colors =
        if (dark)
            darkColorScheme(
                primary = Color(0xFF3B82FF),
                secondary = Color(0xFF3B82FF),
                secondaryContainer = Color(0xFF1A2545),
                onSecondaryContainer = Color(0xFFC9CDD4),
                surfaceContainerLowest = Color(0xFF0F1118),
                surfaceContainerLow = Color(0xFF1C1F2E),
                surfaceContainer = Color(0xFF1C1F2E),
                surfaceContainerHigh = Color(0xFF232741),
                surfaceContainerHighest = Color(0xFF1C1F2E),
                onSurfaceVariant = Color(0xFFC9CDD4),
                outline = Color(0xFF2C2F3E),
                outlineVariant = Color(0xFF2C2F3E),
                error = Color(0xFFF75656),
                errorContainer = Color(0xFF2D1616),
                background = Color(0xFF0F1118),
                surface = Color(0xFF1C1F2E),
                primaryContainer = Color(0xFF1A2545),
                onBackground = Color.White,
                onSurface = Color.White,
            )
        else
            lightColorScheme(
                primary = Color(0xFF2570FF),
                secondary = Color(0xFF2570FF),
                secondaryContainer = Color(0xFFE8F0FF),
                onSecondaryContainer = Color(0xFF2570FF),
                surfaceContainerLowest = Color.White,
                surfaceContainerLow = Color.White,
                surfaceContainer = Color.White,
                surfaceContainerHigh = Color(0xFFF0F4FF),
                surfaceContainerHighest = Color.White,
                onSurfaceVariant = Color(0xFF4E5969),
                outline = Color(0xFFE5E6EB),
                outlineVariant = Color(0xFFE5E6EB),
                error = Color(0xFFF53F3F),
                errorContainer = Color(0xFFFFF0F0),
                background = Color(0xFFF6F7FA),
                surface = Color.White,
                primaryContainer = Color(0xFFE8F0FF),
                onBackground = Color(0xFF1D2129),
                onSurface = Color(0xFF1D2129),
            )
    MaterialTheme(colorScheme = colors, content = content)
}
