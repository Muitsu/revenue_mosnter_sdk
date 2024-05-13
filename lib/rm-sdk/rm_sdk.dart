import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:revenue_monster_sdk/rm-sdk/rm_client.dart';
import 'package:revenue_monster_sdk/rm-sdk/rm_constants.dart';
import 'dart:developer' as dev;

class RmSdk {
  //Variables
  RmEnvironment? _environment;
  String? _baseUrl;
  String? _type;
  String? _redirectURL;
  String? _notifyURL;
  static const platform = MethodChannel('revenue.monster/payment');
  // Singleton instance variable
  RmSdk._init();
  static final RmSdk _instance = RmSdk._init();
  factory RmSdk() => _instance;

  // Initialize revenue payment sdk
  Future<void> initialize({
    required RmEnvironment environment,
    required String baseUrl,
    String type = "MOBILE_PAYMENT",
    String redirectURL = "revenuemonster://test",
    String notifyURL = "https://dev-rm-api.ap.ngrok.io",
  }) async {
    _environment = environment;
    _baseUrl = baseUrl;
    _type = type;
    _redirectURL = redirectURL;
    _notifyURL = notifyURL;
    dev.log("Initializing Revenue Monster SDK", name: "[RM-SDK]");
  }

  Future<void> launchSDK(
      {required RMPaymentMethod method,
      required int total,
      void Function()? onSuccess,
      void Function()? onFailed,
      void Function()? onCancelled,
      void Function()? onTimeout,
      Duration? timeout}) async {
    if (_environment == null || _baseUrl == null) {
      dev.log("SDK not initialize", name: "[RM-SDK]");
      return;
    }

    platform.setMethodCallHandler((call) async {
      final String jsonString = call.arguments;
      final state = RMPaymentResult.values.byName(call.method);
      if (state == RMPaymentResult.success && onSuccess != null) {
        dev.log("${state.name}: ${jsonString.toString()}");
        onSuccess();
      } else if (state == RMPaymentResult.failed && onFailed != null) {
        dev.log("${state.name}: ${jsonString.toString()}");
        onFailed();
      } else {
        dev.log(jsonString);
        if (onCancelled == null) return;
        onCancelled();
      }
    });

    String? checkoutID = await _getCheckoutId(
      baseUrl: _baseUrl!,
      total: total,
      type: _type!,
      redirectURL: _redirectURL!,
      notifyURL: _notifyURL!,
      timeout: timeout ?? const Duration(seconds: 10),
      onTimeout: onTimeout,
    );
    if (checkoutID == null) {
      dev.log("Failed fetching checkout id", name: "[RM-SDK]");
      return;
    }
    var args = {
      "checkout_id": checkoutID,
      "environment": _environment!.code,
      "payment_method": method.code
    };

    await platform.invokeMethod('launchSDK', args);
  }

  static Future<String?> _getCheckoutId({
    required String baseUrl,
    required String type,
    required String redirectURL,
    required String notifyURL,
    required int total,
    required Duration timeout,
    void Function()? onTimeout,
  }) async {
    String? result;
    //Calling API

    try {
      final rmClient = RmClient(baseUrl: baseUrl);
      var body = {
        "type": type,
        "redirectURL": redirectURL,
        "notifyURL": notifyURL,
        "amount": total,
      };
      final response = await rmClient.post(body: body).timeout(
            timeout,
            onTimeout: onTimeout,
          );
      dev.log(response.toString());
      Map<String, dynamic> jsonResponse = jsonDecode(response);
      Map<String, dynamic> item = jsonResponse['item'];
      String checkoutId = item['checkoutId'].toString();
      result = checkoutId;
      dev.log("Success fetch checkout id", name: "[RM-SDK]");
    } catch (e) {
      dev.log("$e");
      result = null;
    }

    return result;
  }
}
