package com.beetle.playvoice.core.network

import java.util.concurrent.TimeUnit
import okhttp3.OkHttpClient
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory

fun createRetrofit(baseUrl: String, sessions: SessionManager): Retrofit {
    val client =
        OkHttpClient.Builder()
            .connectTimeout(20, TimeUnit.SECONDS)
            .readTimeout(30, TimeUnit.SECONDS)
            .addInterceptor { chain ->
                val request = chain.request().newBuilder()
                if (chain.request().url.encodedPath != "/auth/google") {
                    sessions.preferences.value.session?.token?.let {
                        request.header("Authorization", "Bearer $it")
                    }
                }
                chain.proceed(request.build())
            }
            .build()
    return Retrofit.Builder()
        .baseUrl(baseUrl.trimEnd('/') + "/")
        .client(client)
        .addConverterFactory(GsonConverterFactory.create())
        .build()
}
