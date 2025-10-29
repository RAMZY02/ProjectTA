package com.ramz.project_ta

import android.app.admin.DevicePolicyManager
import android.content.ComponentName
import android.content.Context
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "kiosk_mode_channel"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "startLockTask" -> {
                    startLockTask() // Mengunci aplikasi
                    result.success(true)
                }
                "stopLockTask" -> {
                    stopLockTask() // Melepas kunci
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }
}