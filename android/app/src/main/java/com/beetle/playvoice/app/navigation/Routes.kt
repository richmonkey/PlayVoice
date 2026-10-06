package com.beetle.playvoice.app.navigation

import kotlinx.serialization.Serializable

@Serializable data object Home

@Serializable data object Search

@Serializable data object Profile

@Serializable data object Settings

@Serializable data object BlockedUsers

@Serializable data class EditName(val field: String)

@Serializable data class VoiceRoom(val channelId: Long)
