package com.beetle.playvoice.app

import android.app.Application
import android.util.Log
import com.beetle.room.RoomSdk

class PlayVoiceApplication : Application() {
    lateinit var container: AppContainer
        private set

    override fun onCreate() {
        super.onCreate()
        try {
            RoomSdk.initialize(this)
        } catch (error: IllegalStateException) {
            Log.w("PlayVoice", "Voice SDK initialization failed", error)
        }
        container = AppContainer(this)
    }
}
