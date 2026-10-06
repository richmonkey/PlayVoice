package com.beetle.playvoice.data.mapper

import com.beetle.playvoice.data.remote.dto.*
import com.beetle.playvoice.domain.model.*

fun AuthDto.toDomain(): Session {
    require(!token.isNullOrBlank() && id > 0 && !email.isNullOrBlank()) {
        "Server error. Please try again."
    }
    return Session(token, id, name?.takeIf { it.isNotBlank() } ?: "Me", email, avatar)
}

fun ChannelDto.toDomain(): Channel {
    require(id > 0 && ownerId > 0) { "Server error. Please try again." }
    return Channel(id, name ?: "Unnamed Channel", ownerId, ownerName ?: "Unknown User", avatar)
}

fun UserDto.toDomain() =
    User(id, name ?: "Unknown User", avatar, channel ?: "Unnamed Channel", followed)
