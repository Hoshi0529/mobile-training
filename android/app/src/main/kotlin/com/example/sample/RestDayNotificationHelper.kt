package com.example.sample

import android.Manifest
import android.app.AlarmManager
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import java.util.Calendar

object RestDayNotificationHelper {
    private const val PREFS_NAME = "rest_day_notification"
    private const val KEY_ENABLED = "enabled"
    private const val KEY_REST_DAYS = "rest_days"
    private const val CHANNEL_ID = "rest_day_status"
    private const val NOTIFICATION_ID = 20250617
    private const val ALARM_REQUEST_CODE = 20250618

    const val ACTION_CHECK = "com.example.sample.REST_DAY_NOTIFICATION_CHECK"

    fun configure(context: Context, enabled: Boolean, restDays: List<Boolean>) {
        val normalizedRestDays = BooleanArray(7) { index ->
            restDays.getOrNull(index) == true
        }

        context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            .edit()
            .putBoolean(KEY_ENABLED, enabled)
            .putString(KEY_REST_DAYS, serializeRestDays(normalizedRestDays))
            .apply()

        updateNotificationForToday(context)

        if (enabled) {
            scheduleNextCheck(context)
        } else {
            cancelNextCheck(context)
        }
    }

    fun handleCheck(context: Context) {
        updateNotificationForToday(context)

        if (isEnabled(context)) {
            scheduleNextCheck(context)
        } else {
            cancelNextCheck(context)
        }
    }

    fun updateNotificationForToday(context: Context) {
        createNotificationChannel(context)

        if (shouldShowToday(context)) {
            showRestDayNotification(context)
        } else {
            cancelRestDayNotification(context)
        }
    }

    private fun scheduleNextCheck(context: Context) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val pendingIntent = restDayCheckPendingIntent(context)
        val nextMidnight = nextMidnightMillis()

        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S &&
                !alarmManager.canScheduleExactAlarms()
            ) {
                scheduleInexactCheck(alarmManager, nextMidnight, pendingIntent)
                return
            }

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                alarmManager.setExactAndAllowWhileIdle(
                    AlarmManager.RTC_WAKEUP,
                    nextMidnight,
                    pendingIntent
                )
            } else {
                alarmManager.setExact(
                    AlarmManager.RTC_WAKEUP,
                    nextMidnight,
                    pendingIntent
                )
            }
        } catch (_: SecurityException) {
            scheduleInexactCheck(alarmManager, nextMidnight, pendingIntent)
        }
    }

    private fun scheduleInexactCheck(
        alarmManager: AlarmManager,
        triggerAtMillis: Long,
        pendingIntent: PendingIntent
    ) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            alarmManager.setAndAllowWhileIdle(
                AlarmManager.RTC_WAKEUP,
                triggerAtMillis,
                pendingIntent
            )
        } else {
            alarmManager.set(
                AlarmManager.RTC_WAKEUP,
                triggerAtMillis,
                pendingIntent
            )
        }
    }

    private fun cancelNextCheck(context: Context) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        alarmManager.cancel(restDayCheckPendingIntent(context))
    }

    private fun shouldShowToday(context: Context): Boolean {
        if (!isEnabled(context)) {
            return false
        }

        val todayIndex = Calendar.getInstance().get(Calendar.DAY_OF_WEEK) - Calendar.SUNDAY
        return restDays(context).getOrElse(todayIndex) { false }
    }

    private fun isEnabled(context: Context): Boolean {
        return context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            .getBoolean(KEY_ENABLED, false)
    }

    private fun restDays(context: Context): BooleanArray {
        val raw = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            .getString(KEY_REST_DAYS, null)
            ?: return BooleanArray(7)
        val values = raw.split(",")
        return BooleanArray(7) { index -> values.getOrNull(index) == "1" }
    }

    private fun showRestDayNotification(context: Context) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU &&
            context.checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) !=
            PackageManager.PERMISSION_GRANTED
        ) {
            return
        }

        val launchIntent = context.packageManager.getLaunchIntentForPackage(context.packageName)
            ?: Intent(context, MainActivity::class.java)
        val contentIntent = PendingIntent.getActivity(
            context,
            0,
            launchIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or immutableFlag()
        )

        val builder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(context, CHANNEL_ID)
        } else {
            Notification.Builder(context)
        }

        val notification = builder
            .setSmallIcon(android.R.drawable.ic_dialog_info)
            .setContentTitle("今日は休肝日です")
            .setContentText("一日中、飲酒を控える日として通知欄に表示しています。")
            .setContentIntent(contentIntent)
            .setOngoing(true)
            .setAutoCancel(false)
            .setOnlyAlertOnce(true)
            .setShowWhen(false)
            .setCategory(Notification.CATEGORY_STATUS)
            .setPriority(Notification.PRIORITY_LOW)
            .build()

        notificationManager(context).notify(NOTIFICATION_ID, notification)
    }

    private fun cancelRestDayNotification(context: Context) {
        notificationManager(context).cancel(NOTIFICATION_ID)
    }

    private fun createNotificationChannel(context: Context) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
            return
        }

        val channel = NotificationChannel(
            CHANNEL_ID,
            "休肝日のお知らせ",
            NotificationManager.IMPORTANCE_LOW
        ).apply {
            description = "休肝日の間、通知欄に常駐表示します。"
            setShowBadge(false)
        }

        notificationManager(context).createNotificationChannel(channel)
    }

    private fun notificationManager(context: Context): NotificationManager {
        return context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
    }

    private fun restDayCheckPendingIntent(context: Context): PendingIntent {
        val intent = Intent(context, RestDayNotificationReceiver::class.java).apply {
            action = ACTION_CHECK
        }
        return PendingIntent.getBroadcast(
            context,
            ALARM_REQUEST_CODE,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or immutableFlag()
        )
    }

    private fun nextMidnightMillis(): Long {
        return Calendar.getInstance().apply {
            add(Calendar.DAY_OF_YEAR, 1)
            set(Calendar.HOUR_OF_DAY, 0)
            set(Calendar.MINUTE, 0)
            set(Calendar.SECOND, 0)
            set(Calendar.MILLISECOND, 0)
        }.timeInMillis
    }

    private fun serializeRestDays(restDays: BooleanArray): String {
        return restDays.joinToString(",") { selected -> if (selected) "1" else "0" }
    }

    private fun immutableFlag(): Int {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            PendingIntent.FLAG_IMMUTABLE
        } else {
            0
        }
    }
}
