package com.example.revenue_monster_sdk

import android.util.Log
import android.widget.Toast
import androidx.annotation.NonNull
import com.revenuemonster.payment.Checkout
import com.revenuemonster.payment.PaymentResult
import com.revenuemonster.payment.constant.Env
import com.revenuemonster.payment.constant.Method
import com.revenuemonster.payment.model.Error
import com.revenuemonster.payment.model.Transaction
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.IOException
import org.json.JSONObject

class MainActivity : FlutterActivity(), PaymentResult  {
    //Flutter method channel key
    private val CHANNEL = "revenue.monster/payment"
    private var checkout: Checkout = Checkout(this@MainActivity)

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "launchSDK") {
                val environment = call.argument<String>("environment")?: "SANDBOX"
                val paymentMethod = call.argument<String>("payment_method")!!
                val checkoutID = call.argument<String>("checkout_id")!!
                val envValue = getEnvByName(environment)
                val method:Method =getMethodByName(paymentMethod)
                val outerActivity = this@MainActivity // Capture reference to the outer class
            try {
                checkout = Checkout(outerActivity).instance.setEnv(envValue)
                settingsPaymentMethod(method,call)
                checkout.pay(method, checkoutID, outerActivity)
//                result.success(envValue.name)
            }catch(e: IOException){
                Log.e(TAG, "Checkout payment failed:", e)
            }

            } else {
                result.notImplemented()
            }
        }
    }

    private fun getEnvByName(name: String): Env {
        return enumValues<Env>().find { it.name == name }?:Env.SANDBOX
    }

    private fun getMethodByName(name: String): Method {
        return enumValues<Method>().find { it.name == name }?:Method.FPX_MY
    }
    private fun settingsPaymentMethod(paymentMethod: Method, call: MethodCall) {
        if(paymentMethod==Method.GOBIZ_MY){
            val cardName = call.argument<String>("name")!!
            val cardNo = call.argument<String>("cardNo")!!
            val cvc = call.argument<String>("cvcNo")!!
            val month = call.argument<Int>("expMonth")!!
            val year = call.argument<Int>("expYear")!!
//            val countryCode = call.argument<String>("country_code")!!
//            val saveCard = call.argument<Boolean>("save_card")!!
//            if (selectCard.getSelectedItemPosition() === 0) {
//                if (expDate.getText().toString().length() === 5) {
//                    val expMonth: Int = expDate.getText().toString().substring(0, 2).toInt()
//                    val expYear: Int = (20 + expDate.getText().toString().substring(3, 5)).toInt()
//                    checkout = checkout.setCardInfo(cardName.getText().toString(), cardNo.getText().toString(), cvc.getText().toString(), expMonth, expYear, "MY", saveCard)
//                }
//            } else {
//                c = c.setToken(cardNo.getText().toString(), cvc.getText().toString())
//            }
        }else if(paymentMethod==Method.FPX_MY){
            checkout = checkout.setBankCode("TEST");
        }
    }

    companion object {
        // Debugging
        private const val TAG = "RM-SDK"
    }

    override fun onPaymentSuccess(transaction: Transaction?) {
        val args = transactionToJson(transaction);
        MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, CHANNEL).invokeMethod("success", args)
        Log.d("SUCCESS", "onPaymentSuccess")
        val toast = Toast.makeText(applicationContext, "Payment Success", Toast.LENGTH_SHORT)
        toast.show()
    }

    override fun onPaymentFailed(error: Error) {
        val args =   errorToJson(error)
        MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, CHANNEL).invokeMethod("failed", args)
        Log.d("FAILED", error.message)
        val toast = Toast.makeText(applicationContext, "Payment Failed", Toast.LENGTH_SHORT)
        toast.show()
    }

    override fun onPaymentCancelled() {
        val args =   cancelledToJson()
        MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, CHANNEL).invokeMethod("cancelled", args)
        Log.d("CANCELLED", "onPaymentCancelled")
        val toast = Toast.makeText(applicationContext, "Payment Cancelled", Toast.LENGTH_SHORT)
        toast.show()
    }

    private fun transactionToJson(transaction: Transaction?): String {
        val transactionJson = JSONObject()
        transactionJson.put("key", transaction?.key)
        transactionJson.put("id", transaction?.id)
        transactionJson.put("merchantKey", transaction?.merchantKey)
        transactionJson.put("storeKey", transaction?.storeKey)
        val orderJson = JSONObject()
        val order = transaction?.order
        orderJson.put("id", order?.id)
        orderJson.put("title", order?.title)
        orderJson.put("detail", order?.detail)
        orderJson.put("additionalData", order?.additionalData)
        orderJson.put("currencyType", order?.currencyType)
        orderJson.put("amount", order?.amount)
        transactionJson.put("order", orderJson)
        transactionJson.put("type", transaction?.type)
        transactionJson.put("transactionId", transaction?.transactionId)
        transactionJson.put("platform", transaction?.platform)
        transactionJson.put("redirectUrl", transaction?.redirectUrl)
        transactionJson.put("notifyUrl", transaction?.notifyUrl)
        transactionJson.put("startAt", transaction?.startAt)
        transactionJson.put("endAt", transaction?.endAt)
        transactionJson.put("referenceKey", transaction?.referenceKey)
        transactionJson.put("status", transaction?.status)
        transactionJson.put("payload", transaction?.payload)
        transactionJson.put("createdAt", transaction?.createdAt)
        transactionJson.put("updatedAt", transaction?.updatedAt)
        return transactionJson.toString()
    }
    private fun errorToJson(err: Error): String {
        val errJson = JSONObject()
        errJson.put("message", err.message)
        return errJson.toString()
    }
    private fun cancelledToJson(): String {
        val msgJson = JSONObject()
        msgJson.put("message", "cancelled")
        return msgJson.toString()
    }
}

