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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['accuracy'] = accuracy;
    data['lng'] = lng;
    data['lat'] = lat;
    return data;
  }
}
