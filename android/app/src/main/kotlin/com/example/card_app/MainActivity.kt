package com.example.card_app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.provider.Settings
import android.content.Context
import android.view.WindowManager.LayoutParams

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.card_app/screen_brightness"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "setBrightness" -> {
                    val brightness = call.argument<Double>("brightness")
                    if (brightness != null) {
                        setBrightness(brightness.toFloat())
                        result.success(null)
                    } else {
                        result.error("INVALID_ARGUMENT", "Brightness value is required", null)
                    }
                }
                "getBrightness" -> {
                    result.success(getBrightness())
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun setBrightness(brightness: Float) {
        val window = activity.window
        val layoutParams = window.attributes
        layoutParams.screenBrightness = brightness
        window.attributes = layoutParams
    }

    private fun getBrightness(): Float {
        return activity.window.attributes.screenBrightness
    }
}
