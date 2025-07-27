import Flutter
import UIKit
import GoogleMaps
import Dotenv

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    if let googleKey = Dotenv().load()["GOOGLE_KEY"] {
        GMSServices.provideAPIKey(googleKey)
    } else {
        fatalError("Google API key not found in .env file")
    }
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
