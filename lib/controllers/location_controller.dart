import 'dart:io';

import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationController extends GetxController {
  Rx<LatLng?> initialPosition = Rx<LatLng?>(null);
  Rx<Position?> currentPosition = Rx<Position?>(null);
  Rx<CameraPosition?> cameraPosition = Rx<CameraPosition?>(null);
  Rx<GoogleMapController?> mapController = Rx<GoogleMapController?>(null);
  RxBool isLoadingLocation = false.obs;
  RxBool hasLocationPermission = false.obs;
  RxBool isLocationServiceEnabled = false.obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    // Inicializar de forma mais segura
    await _initializeLocationServices();
  }

  // Inicializar serviços de localização de forma segura
  Future<void> _initializeLocationServices() async {
    try {
      // Verificar se o serviço de localização está habilitado
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      isLocationServiceEnabled.value = serviceEnabled;

      if (!serviceEnabled) {
        print("Serviço de localização está desativado.");
        return;
      }

      // Verificar permissões existentes
      await checkLocationPermission();

      // Se tem permissão, obter localização inicial
      if (hasLocationPermission.value) {
        await _getCurrentLocation();
      }
    } catch (e) {
      print("Erro ao inicializar serviços de localização: $e");
    }
  }

  // Método para obter a localização atual
  Future<void> _getCurrentLocation() async {
    if (isLoadingLocation.value) return; // Evita múltiplas chamadas simultâneas

    isLoadingLocation.value = true;

    try {
      // Verificar se o serviço de localização está habilitado
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      isLocationServiceEnabled.value = serviceEnabled;

      if (!serviceEnabled) {
        print("Serviço de localização está desativado.");
        isLoadingLocation.value = false;
        return;
      }

      // Verificar permissões de localização
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.deniedForever) {
        print("Permissão de localização permanentemente negada.");
        hasLocationPermission.value = false;
        isLoadingLocation.value = false;
        return;
      } else if (permission == LocationPermission.denied) {
        // Solicitar permissão de forma mais segura
        try {
          permission = await Geolocator.requestPermission();
          if (permission != LocationPermission.whileInUse &&
              permission != LocationPermission.always) {
            print("Permissão de localização negada.");
            hasLocationPermission.value = false;
            isLoadingLocation.value = false;
            return;
          }
        } catch (e) {
          print("Erro ao solicitar permissão de localização: $e");
          hasLocationPermission.value = false;
          isLoadingLocation.value = false;
          return;
        }
      }

      hasLocationPermission.value = true;

      // Configurar stream de posição de forma mais segura
      try {
        Geolocator.getPositionStream(
          locationSettings: LocationSettings(
            accuracy: Platform.isAndroid
                ? LocationAccuracy.best
                : LocationAccuracy.bestForNavigation,
            distanceFilter: 10, // Atualizar apenas quando mover 10 metros
          ),
        ).listen(
          (Position position) {
            currentPosition.value = position;
            if (initialPosition.value == null) {
              initialPosition.value =
                  LatLng(position.latitude, position.longitude);
            }
          },
          onError: (error) {
            print("Erro no stream de localização: $error");
          },
        );
      } catch (e) {
        print("Erro ao configurar stream de localização: $e");
      }

      // Obter posição atual de forma mais segura
      try {
        Position position = await Geolocator.getCurrentPosition(
          locationSettings: LocationSettings(
            accuracy: Platform.isAndroid
                ? LocationAccuracy.best
                : LocationAccuracy.bestForNavigation,
            timeLimit: const Duration(seconds: 15), // Timeout de 15 segundos
          ),
        );

        currentPosition.value = position;
        if (initialPosition.value == null) {
          initialPosition.value = LatLng(position.latitude, position.longitude);
        }

        print(
            "Posição atual obtida: ${position.latitude}, ${position.longitude}");
      } catch (e) {
        print("Erro ao obter posição atual: $e");
        // Em caso de erro, tentar usar a última posição conhecida
        try {
          Position? lastKnownPosition = await Geolocator.getLastKnownPosition();
          if (lastKnownPosition != null) {
            currentPosition.value = lastKnownPosition;
            if (initialPosition.value == null) {
              initialPosition.value = LatLng(
                  lastKnownPosition.latitude, lastKnownPosition.longitude);
            }
            print(
                "Usando última posição conhecida: ${lastKnownPosition.latitude}, ${lastKnownPosition.longitude}");
          }
        } catch (lastError) {
          print("Erro ao obter última posição conhecida: $lastError");
        }
      }
    } catch (e) {
      print("Erro geral ao obter localização: $e");
    } finally {
      isLoadingLocation.value = false;
    }
  }

  // Método público para solicitar localização
  Future<void> requestLocation() async {
    await _getCurrentLocation();
  }

  // Verificar se tem permissão de localização
  Future<bool> checkLocationPermission() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      hasLocationPermission.value =
          permission == LocationPermission.whileInUse ||
              permission == LocationPermission.always;
      return hasLocationPermission.value;
    } catch (e) {
      print("Erro ao verificar permissão: $e");
      return false;
    }
  }

  // Solicitar permissão de localização
  Future<bool> requestLocationPermission() async {
    try {
      LocationPermission permission = await Geolocator.requestPermission();
      hasLocationPermission.value =
          permission == LocationPermission.whileInUse ||
              permission == LocationPermission.always;

      // Se permissão concedida, obter localização
      if (hasLocationPermission.value) {
        await _getCurrentLocation();
      }

      return hasLocationPermission.value;
    } catch (e) {
      print("Erro ao solicitar permissão: $e");
      return false;
    }
  }

  // Atualizar a posição da câmera quando o usuário mover o mapa
  void onCameraMove(CameraPosition position) {
    try {
      print(
          "Posição da câmera: ${position.target.latitude}, ${position.target.longitude}");
      cameraPosition.value = position;
    } catch (e) {
      print("Erro ao atualizar posição da câmera: $e");
    }
  }
}
