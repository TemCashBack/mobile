import Flutter
import UIKit
import CoreLocation
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    // Configuração específica para localização no iOS
    if #available(iOS 14.0, *) {
      let locationManager = CLLocationManager()
      locationManager.delegate = self
    }
    
    // Configuração específica para Google Maps
    GMSServices.provideAPIKey("AIzaSyDTruUfrPofVhkGeyThTvr841lvHV_ven0")
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

// MARK: - CLLocationManagerDelegate
extension AppDelegate: CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    switch status {
    case .authorizedWhenInUse, .authorizedAlways:
      print("Localização autorizada")
    case .denied, .restricted:
      print("Localização negada ou restrita")
    case .notDetermined:
      print("Localização não determinada")
    @unknown default:
      print("Status de localização desconhecido")
    }
  }
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print("Erro na localização: \(error.localizedDescription)")
  }
}
