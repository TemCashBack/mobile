import Flutter
import UIKit
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Inicializar Google Maps com a chave API
    if let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
       let plist = NSDictionary(contentsOfFile: path),
       let apiKey = plist["API_KEY"] as? String {
      GMSServices.provideAPIKey(apiKey)
    }
    
    // Configuração específica para Google Maps
    GMSServices.provideAPIKey("AIzaSyDTruUfrPofVhkGeyThTvr841lvHV_ven0")
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
