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
    GMSServices.provideAPIKey("AIzaSyC6Q5EC_3hYvdCpkMGje4Kv2z5_mE12fkE")
    
    // Configurações adicionais para melhorar o carregamento no iOS
    if #available(iOS 13.0, *) {
      // Configurar para usar sempre HTTPS
      GMSServices.setMetalRendererEnabled(true)
    }
    
    // Configurar cache de tiles para melhor performance
    GMSServices.setTileCacheEnabled(true)
    
    // Aplicar configurações específicas do arquivo de configuração
    _applyGoogleMapsConfiguration()
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  // Método para aplicar configurações específicas do Google Maps
  private func _applyGoogleMapsConfiguration() {
    // Configurar para sempre usar HTTPS
    GMSServices.setHTTPSEnabled(true)
    
    // Configurar cache de tiles
    GMSServices.setTileCacheEnabled(true)
    
    // Configurar renderizador Metal se disponível
    if #available(iOS 13.0, *) {
      GMSServices.setMetalRendererEnabled(true)
    }
    
    print("Configurações do Google Maps aplicadas com sucesso")
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
