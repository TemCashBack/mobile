class SocialModel {
  String whatsapp;
  String facebook;
  String linkedin;
  String instagram;

  SocialModel(
      {required this.whatsapp,
      required this.facebook,
      required this.linkedin,
      required this.instagram});

  factory SocialModel.fromJson(Map<String, dynamic> json) {
    return SocialModel(
        whatsapp: json['whatsapp'],
        facebook: json['facebook'],
        linkedin: json['linkedin'],
        instagram: json['instagram']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['whatsapp'] = whatsapp;
    data['facebook'] = facebook;
    data['linkedin'] = linkedin;
    data['instagram'] = instagram;
    return data;
  }
}
