package com.beetle.playvoice.core.audio

import android.content.Context
import android.media.*
import android.os.Build
import android.os.Handler
import android.os.Looper
import java.util.concurrent.Executor

@Suppress("DEPRECATION")
class AudioRouter(context: Context) {
    private val manager = context.getSystemService(AudioManager::class.java)
    private val handler = Handler(Looper.getMainLooper())
    private val executor = Executor { handler.post(it) }
    private var started = false
    private var previousMode = AudioManager.MODE_NORMAL
    private var previousSpeaker = false
    private var focusRequest: AudioFocusRequest? = null
    var onRouteChanged: (Boolean, String) -> Unit = { _, _ -> }
    var onFocusLost: () -> Unit = {}
    private val focusListener =
        AudioManager.OnAudioFocusChangeListener { change ->
            if (change < 0 && started) onFocusLost()
        }
    private val devices =
        object : AudioDeviceCallback() {
            override fun onAudioDevicesAdded(addedDevices: Array<out AudioDeviceInfo>) =
                publishRoute()

            override fun onAudioDevicesRemoved(removedDevices: Array<out AudioDeviceInfo>) =
                publishRoute()
        }
    private var communicationListener: AudioManager.OnCommunicationDeviceChangedListener? = null

    fun start() {
        if (started) return
        previousMode = manager.mode
        previousSpeaker = manager.isSpeakerphoneOn
        val result =
            if (Build.VERSION.SDK_INT >= 26) {
                val request =
                    AudioFocusRequest.Builder(AudioManager.AUDIOFOCUS_GAIN_TRANSIENT)
                        .setAudioAttributes(
                            AudioAttributes.Builder()
                                .setUsage(AudioAttributes.USAGE_VOICE_COMMUNICATION)
                                .setContentType(AudioAttributes.CONTENT_TYPE_SPEECH)
                                .build()
                        )
                        .setOnAudioFocusChangeListener(focusListener, handler)
                        .build()
                focusRequest = request
                manager.requestAudioFocus(request)
            } else {
                manager.requestAudioFocus(
                    focusListener,
                    AudioManager.STREAM_VOICE_CALL,
                    AudioManager.AUDIOFOCUS_GAIN_TRANSIENT,
                )
            }
        check(result == AudioManager.AUDIOFOCUS_REQUEST_GRANTED) {
            "Audio is in use. Please try again."
        }
        started = true
        manager.mode = AudioManager.MODE_IN_COMMUNICATION
        manager.registerAudioDeviceCallback(devices, handler)
        if (Build.VERSION.SDK_INT >= 31) {
            val listener = AudioManager.OnCommunicationDeviceChangedListener { publishRoute() }
            communicationListener = listener
            manager.addOnCommunicationDeviceChangedListener(executor, listener)
        } else {
            manager.isSpeakerphoneOn = false
        }
        publishRoute()
    }

    fun toggleSpeaker() {
        if (!started) return
        if (Build.VERSION.SDK_INT >= 31) {
            val speaker = manager.communicationDevice?.type == AudioDeviceInfo.TYPE_BUILTIN_SPEAKER
            val type =
                if (speaker) AudioDeviceInfo.TYPE_BUILTIN_EARPIECE
                else AudioDeviceInfo.TYPE_BUILTIN_SPEAKER
            val target = manager.availableCommunicationDevices.firstOrNull { it.type == type }
            if (target == null || !manager.setCommunicationDevice(target)) {
                if (speaker) manager.clearCommunicationDevice()
                else error("Speaker output is unavailable.")
            }
        } else {
            manager.isSpeakerphoneOn = !manager.isSpeakerphoneOn
        }
        publishRoute()
    }

    private fun publishRoute() {
        if (!started) return
        val type =
            if (Build.VERSION.SDK_INT >= 31) manager.communicationDevice?.type
            else
                when {
                    manager.isBluetoothScoOn -> AudioDeviceInfo.TYPE_BLUETOOTH_SCO
                    manager.isWiredHeadsetOn -> AudioDeviceInfo.TYPE_WIRED_HEADSET
                    manager.isSpeakerphoneOn -> AudioDeviceInfo.TYPE_BUILTIN_SPEAKER
                    else -> AudioDeviceInfo.TYPE_BUILTIN_EARPIECE
                }
        val label =
            when (type) {
                AudioDeviceInfo.TYPE_BUILTIN_SPEAKER -> "Speaker"
                AudioDeviceInfo.TYPE_BUILTIN_EARPIECE -> "Earpiece"
                AudioDeviceInfo.TYPE_BLUETOOTH_SCO,
                AudioDeviceInfo.TYPE_BLE_HEADSET -> "Bluetooth"
                AudioDeviceInfo.TYPE_WIRED_HEADSET,
                AudioDeviceInfo.TYPE_WIRED_HEADPHONES,
                AudioDeviceInfo.TYPE_USB_HEADSET -> "Headphones"
                else -> "System output"
            }
        onRouteChanged(type == AudioDeviceInfo.TYPE_BUILTIN_SPEAKER, label)
    }

    fun stop() {
        if (!started && focusRequest == null) return
        started = false
        manager.unregisterAudioDeviceCallback(devices)
        if (Build.VERSION.SDK_INT >= 31) {
            communicationListener?.let { manager.removeOnCommunicationDeviceChangedListener(it) }
            communicationListener = null
            manager.clearCommunicationDevice()
        } else {
            manager.isSpeakerphoneOn = previousSpeaker
        }
        manager.mode = previousMode
        if (Build.VERSION.SDK_INT >= 26) {
            focusRequest?.let { manager.abandonAudioFocusRequest(it) }
        } else {
            manager.abandonAudioFocus(focusListener)
        }
        focusRequest = null
    }
}
