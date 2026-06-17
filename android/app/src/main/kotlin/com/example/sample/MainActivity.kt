package com.example.sample

import android.Manifest
import android.content.pm.PackageManager
import android.os.Build
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "sample/rest_day_notification"
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "configure" -> {
                    val enabled = call.argument<Boolean>("enabled") ?: false
                    val restDays = call.argument<List<Boolean>>("restDays") ?: emptyList()

                    RestDayNotificationHelper.configure(this, enabled, restDays)
                    if (enabled) {
                        requestNotificationPermissionIfNeeded()
                    }
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun requestNotificationPermissionIfNeeded() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) {
            return
        }

        if (checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) ==
            PackageManager.PERMISSION_GRANTED
        ) {
            return
        }

        requestPermissions(
            arrayOf(Manifest.permission.POST_NOTIFICATIONS),
            NOTIFICATION_PERMISSION_REQUEST_CODE
        )
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == NOTIFICATION_PERMISSION_REQUEST_CODE &&
            grantResults.firstOrNull() == PackageManager.PERMISSION_GRANTED
        ) {
            RestDayNotificationHelper.updateNotificationForToday(this)
        }
    }

    companion object {
        private const val NOTIFICATION_PERMISSION_REQUEST_CODE = 9101
    }
}
