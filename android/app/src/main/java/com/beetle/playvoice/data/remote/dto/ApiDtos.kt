package com.beetle.playvoice.data.remote.dto

import com.google.gson.annotations.SerializedName

data class AuthDto(
    @SerializedName("access_token") val token: String?,
    @SerializedName("user_id") val id: Long,
    val name: String?,
    val email: String?,
    @SerializedName("avatar_url") val avatar: String?,
)

data class ChannelDto(
    @SerializedName("channel_id") val id: Long,
    @SerializedName("channel_name") val name: String?,
    @SerializedName("owner_user_id") val ownerId: Long,
    @SerializedName("owner_name") val ownerName: String?,
    @SerializedName("owner_avatar_url") val avatar: String?,
)

data class UserDto(
    @SerializedName("user_id") val id: Long,
    val name: String?,
    @SerializedName("avatar_url") val avatar: String?,
    @SerializedName("channel_name") val channel: String?,
    @SerializedName("is_followed") val followed: Boolean,
)

data class GoogleRequest(@SerializedName("id_token") val token: String)

data class NameRequest(val name: String)

data class ChannelNameRequest(@SerializedName("channel_name") val name: String)

data class ReportRequest(@SerializedName("reported_user_id") val userId: Long, val reason: String)

data class BlockRequest(val reason: String? = null)
