package com.beetle.playvoice.data.remote.api

import com.beetle.playvoice.data.remote.dto.*
import retrofit2.http.*

interface PlayVoiceApi {
    @POST("auth/google") suspend fun login(@Body body: GoogleRequest): AuthDto

    @GET("channels/me") suspend fun myChannel(): ChannelDto

    @GET("channels/followed") suspend fun followed(): List<ChannelDto>

    @PATCH("channels/me/name") suspend fun renameChannel(@Body body: ChannelNameRequest): ChannelDto

    @PATCH("users/me/name") suspend fun renameUser(@Body body: NameRequest)

    @GET("users/search") suspend fun search(@Query("q") query: String): List<UserDto>

    @POST("follows/{id}") suspend fun follow(@Path("id") id: Long)

    @DELETE("follows/{id}") suspend fun unfollow(@Path("id") id: Long)

    @DELETE("users/me") suspend fun deleteAccount()

    @POST("reports") suspend fun report(@Body body: ReportRequest)

    @POST("blocks/{id}") suspend fun block(@Path("id") id: Long, @Body body: BlockRequest)

    @GET("blocks") suspend fun blocked(): List<UserDto>

    @DELETE("blocks/{id}") suspend fun unblock(@Path("id") id: Long)
}
