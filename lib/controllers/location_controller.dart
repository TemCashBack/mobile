import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mobile/core/location/location_settings_helper.dart';

class LocationController extends GetxController {
  Rx<LatLng?> initialPosition = Rx<LatLng?>(null);
  Rx<Position?> currentPosition = Rx<Position?>(null);
  Rx<CameraPosition?> cameraPosition = Rx<CameraPosition?>(null);
  Rx<GoogleMapController?> mapController = Rx<GoogleMapController?>(null);
  RxBool isLoadingLocation = false.obs;
  RxBool hasLocationPermission = false.obs;
  RxBool isLocationServiceEnabled = false.obs;
  RxString locationError = ''.obs;

  StreamSubscription<Position>? _positionSubscription;

  @override
  Future<void> onInit() async {
    super.onInit();
    await _initializeLocationServices();
  }

  Future<void> _initializeLocationServices() async {
    try {
      await _refreshLocationServiceStatus();
      await checkLocationPermission();

      if (hasLocationPermission.value) {
        await requestLocation();
      }
    } catch (_) {
      locationError.value = 'Não foi possível inicializar a localização.';
    }
  }

  Future<void> _refreshLocationServiceStatus() async {
    if (kIsWeb) {
      isLocationServiceEnabled.value = true;
      return;
    }

    isLocationServiceEnabled.value =
        await Geolocator.isLocationServiceEnabled();
  }

  Future<bool> ensureLocationAccess() async {
    try {
      await _refreshLocationServiceStatus();

      if (!kIsWeb && !isLocationServiceEnabled.value) {
        locationError.value = 'Ative o GPS/localização do dispositivo.';
        hasLocationPermission.value = false;
        return false;
      }

      var permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        hasLocationPermission.value = false;
        locationError.value =
            'Permissão negada. Habilite a localização nas configurações.';
        return false;
      }

      if (permission == LocationPermission.denied) {
        hasLocationPermission.value = false;
        locationError.value = kIsWeb
            ? 'Permita o acesso à localização no navegador.'
            : 'Permissão de localização necessária.';
        return false;
      }

      hasLocationPermission.value = true;
      locationError.value = '';
      return true;
    } catch (_) {
      hasLocationPermission.value = false;
      locationError.value = 'Erro ao solicitar permissão de localização.';
      return false;
    }
  }

  Future<bool> requestLocation() async {
    if (isLoadingLocation.value) {
      return currentPosition.value != null;
    }

    final hasAccess = await ensureLocationAccess();
    if (!hasAccess) return false;

    isLoadingLocation.value = true;

    try {
      await _startPositionStream();
      await _fetchCurrentPosition();
      return currentPosition.value != null;
    } catch (_) {
      locationError.value = 'Não foi possível obter sua localização.';
      return false;
    } finally {
      isLoadingLocation.value = false;
    }
  }

  Future<void> _startPositionStream() async {
    await _positionSubscription?.cancel();
    _positionSubscription = null;

    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: LocationSettingsHelper.settings(forStream: true),
    ).listen(
      (position) => _applyPosition(position),
      onError: (_) {},
    );
  }

  Future<void> _fetchCurrentPosition() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettingsHelper.settings(),
      );
      _applyPosition(position);
      locationError.value = '';
    } catch (_) {
      await _tryLastKnownPosition();
    }
  }

  Future<void> _tryLastKnownPosition() async {
    try {
      final lastKnownPosition = await Geolocator.getLastKnownPosition();
      if (lastKnownPosition != null) {
        _applyPosition(lastKnownPosition);
        locationError.value = '';
      }
    } catch (_) {
      if (currentPosition.value == null) {
        locationError.value = 'Localização indisponível no momento.';
      }
    }
  }

  void _applyPosition(Position position) {
    currentPosition.value = position;
    initialPosition.value ??= LatLng(position.latitude, position.longitude);
  }

  Future<bool> checkLocationPermission() async {
    try {
      final permission = await Geolocator.checkPermission();
      hasLocationPermission.value =
          permission == LocationPermission.whileInUse ||
              permission == LocationPermission.always;
      return hasLocationPermission.value;
    } catch (_) {
      hasLocationPermission.value = false;
      return false;
    }
  }

  Future<bool> requestLocationPermission() async {
    return ensureLocationAccess();
  }

  Future<bool> openLocationSettings() async {
    return Geolocator.openLocationSettings();
  }

  Future<bool> openAppSettings() async {
    return Geolocator.openAppSettings();
  }

  void onCameraMove(CameraPosition position) {
    cameraPosition.value = position;
  }

  @override
  void onClose() {
    _positionSubscription?.cancel();
    super.onClose();
  }
}
