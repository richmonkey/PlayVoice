package com.beetle.playvoice

import androidx.test.platform.app.InstrumentationRegistry
import com.beetle.room.RoomSdk
import org.junit.Assert.assertEquals
import org.junit.Test

class NativeRuntimeTest {
    @Test
    fun initializesWebRtcAndMediasoup() {
        val context = InstrumentationRegistry.getInstrumentation().targetContext.applicationContext
        RoomSdk.initialize(context)
        assertEquals(RoomSdk.InitializationState.INITIALIZED, RoomSdk.getInitializationState())
        // Initialization remains idempotent for subsequent calls.
        RoomSdk.initialize(context)
        assertEquals(RoomSdk.InitializationState.INITIALIZED, RoomSdk.getInitializationState())
    }
}
