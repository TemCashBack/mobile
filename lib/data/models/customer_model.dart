class CustomerModel {
  String? email;
  String? nomeCompleto;
  String? cep;
  String? rua;
  String? n;
  String? bairro;
  String? cidade;
  String? estado;
  String? uid;
  String? photoURL;

  CustomerModel({
    this.email,
    this.nomeCompleto,
    this.cep,
    this.rua,
    this.n,
    this.bairro,
    this.cidade,
    this.estado,
    this.uid,
    this.photoURL,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      email: json['email']?.toString(),
      nomeCompleto: json['nomeCompleto']?.toString(),
      cep: json['cep']?.toString(),
      rua: json['rua']?.toString(),
      n: json['numero']?.toString() ?? json['n']?.toString(),
      bairro: json['bairro']?.toString(),
      cidade: json['cidade']?.toString(),
      estado: json['estado']?.toString(),
      uid: json['uid']?.toString(),
      photoURL: json['photoURL']?.toString() ?? json['photoUrl']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'nomeCompleto': nomeCompleto,
      'cep': cep,
      'rua': rua,
      'numero': n,
      'bairro': bairro,
      'cidade': cidade,
      'estado': estado,
      'uid': uid,
      'photoURL': photoURL,
    };
  }

  bool get hasPhoto => photoURL != null && photoURL!.trim().isNotEmpty;
}
