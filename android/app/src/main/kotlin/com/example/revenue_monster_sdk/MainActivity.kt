package com.example.revenue_monster_sdk

import androidx.annotation.NonNull
import com.revenuemonster.payment.constant.Env;
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "revenue.monster/payment"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "launchSDK") {
                val environment = call.argument<String>("environment")
                val paymentMethod = call.argument<String>("payment_method")
                val checkoutID = call.argument<String>("checkout_id")
                val envValue = when (environment) {
                    "SANDBOX" -> Env.SANDBOX
                    "PRODUCTION" -> Env.PRODUCTION
                    else -> Env.SANDBOX // Default to sandbox if environment is not recognized
                }
                result.success(envValue.toString())
            } else {
                result.notImplemented()
            }
        }
    }

    private fun getBatteryLevel(): String {
        return "batteryLevel"
    }
}

