package com.beetle.playvoice.core.network

import com.google.gson.JsonParseException
import com.google.gson.JsonParser
import java.io.IOException
import retrofit2.HttpException

fun Throwable.userMessage(): String =
    when (this) {
        is HttpException -> {
            val detail =
                runCatching {
                        JsonParser.parseString(response()?.errorBody()?.string())
                            .asJsonObject["detail"]
                            ?.takeIf { it.isJsonPrimitive }
                            ?.asString
                    }
                    .getOrNull()
            if (code() == 401) "Your session has expired. Please sign in again."
            else detail ?: "Request failed (${code()}). Please try again."
        }
        is NullPointerException -> "Server error. Please try again."
        is JsonParseException -> "Failed to parse response. Please try again."
        is IOException -> "Network error. Check your connection and try again."
        else -> message ?: "Server error. Please try again."
    }
