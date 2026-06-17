package com.example.sample

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

class RestDayNotificationReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent?) {
        when (intent?.action) {
            RestDayNotificationHelper.ACTION_CHECK,
            Intent.ACTION_BOOT_COMPLETED,
            Intent.ACTION_DATE_CHANGED,
            Intent.ACTION_TIME_CHANGED,
            Intent.ACTION_TIMEZONE_CHANGED -> {
                RestDayNotificationHelper.handleCheck(context)
            }
        }
    }
}
