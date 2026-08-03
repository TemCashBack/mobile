class GeolocationModel {
  int accuracy;
  double lng;
  double lat;

  GeolocationModel(
      {required this.accuracy, required this.lng, required this.lat});

  factory GeolocationModel.fromJson(Map<String, dynamic> json) {
    return GeolocationModel(
      accuracy: (json['accuracy'] as num?)?.toInt() ?? 0,
      lng: (json['lng'] as num?)?.toDouble() ?? 0,
      lat: (json['lat'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accuracy': accuracy,
      'lng': lng,
      'lat': lat,
    };
  }
}
