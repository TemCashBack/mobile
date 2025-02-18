class UserModel {
  String displayName;
  String email;
  String phoneNumber;
  String photoURL;
  String providerId;
  String uid;

  UserModel(
      {required this.displayName,
      required this.email,
      this.phoneNumber = '',
      this.photoURL = '',
      this.providerId = '',
      required this.uid});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
        displayName: json['displayName'],
        email: json['email'],
        phoneNumber: json['phoneNumber'] ?? '',
        photoURL: json['photoURL'] ?? '',
        providerId: json['providerId'],
        uid: json['uid']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['displayName'] = displayName;
    data['email'] = email;
    data['phoneNumber'] = phoneNumber;
    data['photoURL'] = photoURL;
    data['providerId'] = providerId;
    data['uid'] = uid;

    return data;
  }
}
