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

  CustomerModel(
      {this.email,
      this.nomeCompleto,
      this.cep,
      this.rua,
      this.n,
      this.bairro,
      this.cidade,
      this.estado,
      this.uid,
      this.photoURL});

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
        email: json['email'],
        nomeCompleto: json['nomeCompleto'],
        cep: json['cep'],
        rua: json['rua'],
        n: json['numero'],
        bairro: json['bairro'],
        cidade: json['cidade'],
        estado: json['estado'],
        uid: json['uid'],
        photoURL: json['photoURL']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['email'] = email;
    data['nomeCompleto'] = nomeCompleto;
    data['cep'] = cep;
    data['rua'] = rua;
    data['numero'] = n;
    data['bairro'] = bairro;
    data['cidade'] = cidade;
    data['estado'] = estado;
    data['uid'] = uid;
    data['photoURL'] = photoURL;
    return data;
  }
}
