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
    
    // Aplicar configurações específicas do Google Maps
    _applyGoogleMapsConfiguration()
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  // Método para aplicar configurações específicas do Google Maps
  private func _applyGoogleMapsConfiguration() {
    // Configurar renderizador Metal se disponível
    if #available(iOS 13.0, *) {
      GMSServices.setMetalRendererEnabled(true)
    }
    
    // Configurações específicas para melhorar o carregamento dos tiles
    // Forçar uso de HTTPS para todos os tiles
    GMSServices.setHTTPSRequired(true)
    
    // Configurar cache de tiles para melhor performance
    if #available(iOS 14.0, *) {
      // Configurar cache de tiles do Google Maps
      let cacheSize = 50 * 1024 * 1024 // 50MB cache
      GMSServices.setTileCacheSize(cacheSize)
    }
    
    // Configurar timeout para carregamento de tiles
    GMSServices.setTileLoadTimeout(30.0) // 30 segundos timeout
    
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
