package com.example.ui.theme

import android.os.Build
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.dynamicDarkColorScheme
import androidx.compose.material3.dynamicLightColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext

private val DarkColorScheme = darkColorScheme(
    primary = ShipTealAccent,
    onPrimary = Color.Black,
    primaryContainer = ShipNavySecondary,
    onPrimaryContainer = Color.White,
    secondary = ShipTealAccent,
    background = ShipNavyPrimary,
    surface = ShipNavySecondary,
    onBackground = Color.White,
    onSurface = Color.White,
)

private val LightColorScheme = lightColorScheme(
    primary = ShipNavyPrimary,
    onPrimary = Color.White,
    primaryContainer = ShipTealContainer,
    onPrimaryContainer = ShipNavyPrimary,
    secondary = ShipTealAccent,
    onSecondary = Color.White,
    background = ShipSurfaceLight,
    surface = Color.White,
    onBackground = ShipNavyPrimary,
    onSurface = ShipNavyPrimary,
)

@Composable
fun MyApplicationTheme(
    darkTheme: Boolean = isSystemInDarkTheme(),
    dynamicColor: Boolean = false, // Use intentional GJandAsher palette
    content: @Composable () -> Unit,
) {
    val colorScheme = when {
        dynamicColor && Build.VERSION.SDK_INT >= Build.VERSION_CODES.S -> {
            val context = LocalContext.current
            if (darkTheme) dynamicDarkColorScheme(context) else dynamicLightColorScheme(context)
        }
        darkTheme -> DarkColorScheme
        else -> LightColorScheme
    }

    MaterialTheme(
        colorScheme = colorScheme,
        typography = Typography,
        content = content
    )
}
