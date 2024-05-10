import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:revenue_monster_sdk/rm-sdk/rm_client.dart';
import 'package:revenue_monster_sdk/rm-sdk/rm_constants.dart';
import 'dart:developer' as dev;

class RmSdk {
  //Variables
  RmEnvironment? _environment;
  String? _baseUrl;
  static const platform = MethodChannel('revenue.monster/payment');
  // Singleton instance variable
  RmSdk._init();
  static final RmSdk _instance = RmSdk._init();
  factory RmSdk() => _instance;

  // Initialize revenue payment sdk
  Future<void> initialize(
      {required RmEnvironment environment, required String baseUrl}) async {
    _environment = environment;
    _baseUrl = baseUrl;
    dev.log("[RM-SDK] Initializing Revenue Monster SDK");
  }

  Future<void> launchSDK(
      {required RMPaymentMethod method, required int total}) async {
    if (_environment == null || _baseUrl == null) {
      dev.log("[RM-SDK] SDK not initialize");
      return;
    }
    String? checkoutID = await _getCheckoutId(baseUrl: _baseUrl!, total: total);
    if (checkoutID == null) {
      dev.log("[RM-SDK] Failed fetching checkout id");
      return;
    }
    var args = {
      "checkout_id": checkoutID,
      "environment": _environment!.code,
      "payment_method": method.code
    };
    await platform.invokeMethod('launchSDK', args);
  }

  static Future<String?> _getCheckoutId(
      {required String baseUrl, required int total}) async {
    String? result;
    //Calling API

    try {
      final rmClient = RmClient(baseUrl: baseUrl);
      var body = {
        "type": "MOBILE_PAYMENT",
        "redirectURL": "revenuemonster://test",
        "notifyURL": "https://dev-rm-api.ap.ngrok.io",
        "amount": total,
      };
      final response = await rmClient.post(body: body);
      dev.log(response.toString());
      Map<String, dynamic> jsonResponse = jsonDecode(response);
      Map<String, dynamic> item = jsonResponse['item'];
      String checkoutId = item['checkoutId'].toString();
      result = checkoutId;
      dev.log("[RM-SDK] Success fetch checkout id");
    } catch (e) {
      dev.log("[RM-SDK] $e");
      result = null;
    }

    return result;
  }
}
