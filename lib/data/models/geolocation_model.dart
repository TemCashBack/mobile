class GeolocationModel {
  int accuracy;
  double lng;
  double lat;

  GeolocationModel(
      {required this.accuracy, required this.lng, required this.lat});

  factory GeolocationModel.fromJson(Map<String, dynamic> json) {
    return GeolocationModel(
        accuracy: json['accuracy'], lng: json['lng'], lat: json['lat']);
  }

  Map<String, dynamic> toJson() {
    return {
      'accuracy': accuracy,
      'lng': lng,
      'lat': lat,
    };
  }
}
