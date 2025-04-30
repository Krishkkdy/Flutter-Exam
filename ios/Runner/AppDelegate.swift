import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
    let screenBrightnessChannel = FlutterMethodChannel(
      name: "com.example.card_app/screen_brightness",
      binaryMessenger: controller.binaryMessenger)
      
    screenBrightnessChannel.setMethodCallHandler({
      [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      guard call.method == "setBrightness" else {
        result(FlutterMethodNotImplemented)
        return
      }
      
      if let args = call.arguments as? [String: Any],
         let brightness = args["brightness"] as? Double {
        UIScreen.main.brightness = CGFloat(brightness)
        result(nil)
      } else {
        result(FlutterError(code: "INVALID_ARGUMENT",
                           message: "Brightness value is required",
                           details: nil))
      }
    })
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
