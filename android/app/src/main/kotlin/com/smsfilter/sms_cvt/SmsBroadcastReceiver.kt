package com.smsfilter.sms_cvt

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.provider.Telephony
import android.util.Log

class SmsBroadcastReceiver : BroadcastReceiver() {
    companion object {
        const val TAG = "SmsBroadcastReceiver"
        var onSmsReceived: ((String, String, Long) -> Unit)? = null
    }

    override fun onReceive(context: Context?, intent: Intent?) {
        if (intent?.action == Telephony.Sms.Intents.SMS_RECEIVED_ACTION) {
            val messages = Telephony.Sms.Intents.getMessagesFromIntent(intent)
            
            val senderMap = mutableMapOf<String, StringBuilder>()
            var timestamp = System.currentTimeMillis()
            
            for (message in messages) {
                val sender = message.originatingAddress ?: ""
                val body = message.messageBody ?: ""
                timestamp = message.timestampMillis
                
                if (senderMap.containsKey(sender)) {
                    senderMap[sender]?.append(body)
                } else {
                    senderMap[sender] = StringBuilder(body)
                }
            }
            
            for ((sender, bodyBuilder) in senderMap) {
                val body = bodyBuilder.toString()
                Log.d(TAG, "SMS received from: $sender, body: $body")
                onSmsReceived?.invoke(sender, body, timestamp)
            }
        }
    }
}
