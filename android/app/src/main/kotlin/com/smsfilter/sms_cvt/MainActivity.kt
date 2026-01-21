package com.smsfilter.sms_cvt

import android.content.IntentFilter
import android.os.Build
import android.os.Bundle
import android.provider.Telephony
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val SMS_CHANNEL = "com.smsfilter.sms_cvt/sms"
    private val SMS_EVENT_CHANNEL = "com.smsfilter.sms_cvt/sms_events"
    
    private var smsBroadcastReceiver: SmsBroadcastReceiver? = null
    private var eventSink: EventChannel.EventSink? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Method Channel for commands
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SMS_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "startListening" -> {
                    startSmsListener()
                    result.success(true)
                }
                "stopListening" -> {
                    stopSmsListener()
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }

        // Event Channel for SMS events
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, SMS_EVENT_CHANNEL).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    eventSink = events
                }

                override fun onCancel(arguments: Any?) {
                    eventSink = null
                }
            }
        )
    }

    private fun startSmsListener() {
        if (smsBroadcastReceiver == null) {
            smsBroadcastReceiver = SmsBroadcastReceiver()
            SmsBroadcastReceiver.onSmsReceived = { sender, body, timestamp ->
                runOnUiThread {
                    eventSink?.success(mapOf(
                        "sender" to sender,
                        "body" to body,
                        "timestamp" to timestamp
                    ))
                }
            }
            
            val filter = IntentFilter(Telephony.Sms.Intents.SMS_RECEIVED_ACTION)
            filter.priority = IntentFilter.SYSTEM_HIGH_PRIORITY
            
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                registerReceiver(smsBroadcastReceiver, filter, RECEIVER_NOT_EXPORTED)
            } else {
                registerReceiver(smsBroadcastReceiver, filter)
            }
        }
    }

    private fun stopSmsListener() {
        smsBroadcastReceiver?.let {
            unregisterReceiver(it)
            smsBroadcastReceiver = null
            SmsBroadcastReceiver.onSmsReceived = null
        }
    }

    override fun onDestroy() {
        stopSmsListener()
        super.onDestroy()
    }
}
