import UIKit
import Flutter
import RevenueMonster

static let CHANNEL = "revenue.monster/payment"

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    guard let controller = window?.rootViewController as? FlutterViewController else {
          fatalError("rootViewController is not type FlutterViewController")
      }

      let checkoutChannel = FlutterMethodChannel(name: CHANNEL, binaryMessenger: controller.binaryMessenger)
      
      checkoutChannel.setMethodCallHandler({
          [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
         
          guard call.method == "launchSDK", let data = call.arguments as? [String: AnyObject] else {
              result(FlutterMethodNotImplemented)
              return
          }
          self?.checkout(result: result, data: data)
      })

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  private func checkout(result: @escaping FlutterResult, data: [String: AnyObject]) {

        let mtd = data["payment_method"] as? String
        let env = data["environment"] as? String
        let method = RevenueMonster.Method(rawValue: mtd) ?? RevenueMonster.Method.FPX_MY
        let environment = RevenueMonster.Env(rawValue: env) ?? RevenueMonster.Env.SANDBOX


        guard let checkoutId = data["checkout_id"] as? String else {
            result(FlutterError(code: "failed",
                                message: "checkout_id empty",
                                details: ""))
            return
        }
        
        guard let controller = window?.rootViewController as? FlutterViewController else {
            result(FlutterError(code: "failed",
                                message: "rootViewController is not type FlutterViewController",
                                details: ""))
            return
        }
        
        var c = Checkout(viewController: controller).setEnv(environment)

        do {
            if let bankInfo = data["bankInfo"] as? [String: Any],
               let name = bankInfo["name"] as? String,
               let cardNo = bankInfo["cardNo"] as? String,
               let cvcNo = bankInfo["cvcNo"] as? String,
               let month = bankInfo["expMonth"] as? String,
               let year = bankInfo["expYear"] as? String,
               let expMonth = Int32(month),
               let expYear = Int32(year) {
                c.setCardInfo(name: name, cardNo: cardNo, cvcNo: cvcNo, expMonth: expMonth, expYear: expYear, countryCode: "MY", isSave: false)
            } 
            if let bankCode = data["bankCode"] as? String {
                c.setBankCode(bankCode)
            }
            try c.pay(method: method, checkoutId: checkoutId, result: Result(result: result))
            
        } catch {
            result(FlutterError(code: "failed", message: "Check out failed.", details: error))
        }
    }
}

class Result: PaymentResult {
    
    private var result: FlutterResult
    
    public init(result: @escaping FlutterResult) {
        self.result = result
    }
    
    func getDictionary(data: Transaction) -> Dictionary<String, String> {
        return [
            "transactionId": data.getTransactionId(),
            "status": data.getStatus(),
            "type": data.getType(),
            "currencyType": data.getCurrencyType(),
            "amount": data.getAmount(),
        ]
    }
    
    func onPaymentSuccess(transaction: Transaction) {
        print("PAYMENT SUCCESS")
        MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, CHANNEL).invokeMethod("success", self.getDictionary(data: transaction))
    }
    
    func onPaymentFailed(error: PaymentError) {
        print("PAYMENT FAILED")
        MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, CHANNEL).invokeMethod("failed", {"message" : error.getMessage()})
    }
    
    func onPaymentCancelled() {
        print("PAYMENT CANCELLED")
        MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, CHANNEL).invokeMethod("cancelled", {"message" : "cancelled"})
    }
}
