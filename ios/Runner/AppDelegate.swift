import Flutter
import UIKit
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Maps SDK precisa da GMSApiKey (Info.plist), não da API_KEY do Firebase.
    let mapsApiKey =
      (Bundle.main.object(forInfoDictionaryKey: "GMSApiKey") as? String)?
      .trimmingCharacters(in: .whitespacesAndNewlines)

    if let mapsApiKey, !mapsApiKey.isEmpty {
      GMSServices.provideAPIKey(mapsApiKey)
    } else {
      // Fallback alinhado ao Android / Info.plist
      GMSServices.provideAPIKey("AIzaSyDTruUfrPofVhkGeyThTvr841lvHV_ven0")
    }

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
