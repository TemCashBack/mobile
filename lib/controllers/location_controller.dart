import 'dart:io';

import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationController extends GetxController {
  Rx<LatLng?> initialPosition = Rx<LatLng?>(null);
  Rx<Position?> currentPosition = Rx<Position?>(null);
  Rx<CameraPosition?> cameraPosition = Rx<CameraPosition?>(null);
  Rx<GoogleMapController?> mapController = Rx<GoogleMapController?>(null);

  @override
  Future<void> onInit() async {
    super.onInit();
    await _getCurrentLocation();
  }

  // Método para obter a localização atual
  Future<void> _getCurrentLocation() async {
    try {
      // Request permission and get the current position
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print("Serviço de localização esta desativado.");
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.deniedForever) {
        // Handle case where permission is denied forever
        print("Permissão de localização permanentemente negada.");
        return;
      } else if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission != LocationPermission.whileInUse &&
            permission != LocationPermission.always) {
          print("Permissão de localização negada.");
          return;
        }
      }

      Geolocator.getPositionStream().listen((Position position) {
        currentPosition.value = position;
      });

      // Get the current position
      Position position = await Geolocator.getCurrentPosition(
          locationSettings: LocationSettings(
              accuracy: Platform
                      .isAndroid //no caso do android, somente utilizar o best
                  ? LocationAccuracy.best
                  : LocationAccuracy.bestForNavigation));

      currentPosition.value = position; // Update the current position
      print("Current Position: ${position.latitude}, ${position.longitude}");
    } catch (e) {
      print("Erro ao obter a localização: $e");
    }
  }

  // Atualizar a posição da câmera quando o usuário mover o mapa
  void onCameraMove(CameraPosition position) {
    print(
        "Current Position: ${position.target.latitude}, ${position.target.longitude}");
    cameraPosition.value = position;
  }
}
