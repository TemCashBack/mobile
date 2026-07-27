import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mobile/core/location/location_settings_helper.dart';

void main() {
  test('LocationSettingsHelper retorna configuração válida', () {
    final settings = LocationSettingsHelper.settings();
    expect(settings, isA<LocationSettings>());
    expect(settings.distanceFilter, 10);
  });
}
