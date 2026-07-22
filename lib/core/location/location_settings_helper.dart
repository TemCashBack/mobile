import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:geolocator/geolocator.dart';

class LocationSettingsHelper {
  static const _distanceFilter = 10;
  static const _timeLimit = Duration(seconds: 15);

  static LocationSettings settings({bool forStream = false}) {
    if (kIsWeb) {
      return WebSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: _distanceFilter,
        timeLimit: _timeLimit,
      );
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return AndroidSettings(
          accuracy: LocationAccuracy.best,
          distanceFilter: _distanceFilter,
          timeLimit: _timeLimit,
          forceLocationManager: false,
          intervalDuration: forStream
              ? const Duration(seconds: 5)
              : const Duration(seconds: 2),
        );
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return AppleSettings(
          accuracy: LocationAccuracy.best,
          distanceFilter: _distanceFilter,
          timeLimit: _timeLimit,
          activityType: ActivityType.otherNavigation,
          pauseLocationUpdatesAutomatically: false,
          showBackgroundLocationIndicator: false,
        );
      default:
        return LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: _distanceFilter,
          timeLimit: _timeLimit,
        );
    }
  }
}
