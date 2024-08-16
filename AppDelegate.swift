import UIKit
import Flutter
import opencv2

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        let opencvChannel = FlutterMethodChannel(name: "com.example/opencv",
                                                  binaryMessenger: controller.binaryMessenger)
        opencvChannel.setMethodCallHandler({
            (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            if call.method == "processImage" {
                if let args = call.arguments as? [String: Any],
                   let imagePath = args["imagePath"] as? String {
                    let height = self.processImageWithOpenCV(imagePath: imagePath)
                    result(height)
                } else {
                    result(FlutterError(code: "INVALID_ARGUMENT", message: "Missing or invalid arguments", details: nil))
                }
            } else {
                result(FlutterMethodNotImplemented)
            }
        })

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    private func processImageWithOpenCV(imagePath: String) -> Double {
        guard let image = UIImage(contentsOfFile: imagePath) else {
            return 0.0
        }

        let mat = Mat(uiImage: image)
        // Implement your OpenCV logic to calculate the height of the tree
        // This is a placeholder for the height calculation logic.
        let calculatedHeight: Double = 10.0 // Replace with actual OpenCV logic

        return calculatedHeight
    }
}
