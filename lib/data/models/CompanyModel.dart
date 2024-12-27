import 'package:mobile/data/models/GeolocationModel.dart';
import 'package:mobile/data/models/SocialModel.dart';

class CompanyModel {
  String endereco;
  String numero;
  String bairro;
  String municipio;
  String cnpj;
  List<String> telefones;
  String cep;
  String createdAt;
  String uf;
  String nomeFantasia;
  String complemento;
  String foto;
  GeolocationModel geolocalizacao;
  String id;
  SocialModel socials;
  String razaoSocial;
  int status;
  bool isOnline;
  String categoria;
  List<dynamic> discounts;

  CompanyModel({
    required this.endereco,
    required this.numero,
    required this.bairro,
    required this.municipio,
    required this.cnpj,
    required this.telefones,
    required this.cep,
    required this.createdAt,
    required this.uf,
    required this.nomeFantasia,
    required this.complemento,
    required this.foto,
    required this.geolocalizacao,
    required this.id,
    required this.socials,
    required this.razaoSocial,
    required this.status,
    required this.categoria,
    required this.discounts,
    this.isOnline = false,
  });

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    return CompanyModel(
        endereco: json['endereco'],
        numero: json['numero'],
        bairro: json['bairro'],
        municipio: json['municipio'],
        cnpj: json['cnpj'],
        telefones: json['telefones'].cast<String>(),
        cep: json['cep'],
        createdAt: json['createdAt'],
        uf: json['uf'],
        nomeFantasia: json['nomeFantasia'],
        complemento: json['complemento'],
        foto: json['foto'],
        geolocalizacao: GeolocationModel.fromJson(json['geolocalizacao']),
        id: json['id'],
        socials: SocialModel.fromJson(json['socials']),
        razaoSocial: json['razaoSocial'],
        status: json['status'],
        categoria: json['categoria'],
        discounts: json['discounts'],
        isOnline: json['isOnline'] ?? false);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['endereco'] = endereco;
    data['numero'] = numero;
    data['bairro'] = bairro;
    data['municipio'] = municipio;
    data['cnpj'] = cnpj;
    data['telefones'] = telefones;
    data['cep'] = cep;
    data['createdAt'] = createdAt;
    data['uf'] = uf;
    data['nomeFantasia'] = nomeFantasia;
    data['complemento'] = complemento;
    data['foto'] = foto;
    data['geolocalizacao'] = geolocalizacao.toJson();
    data['id'] = id;
    data['socials'] = socials.toJson();
    data['razaoSocial'] = razaoSocial;
    data['status'] = status;
    data['categoria'] = categoria;
    data['isOnline'] = isOnline;
    data['discounts'] = discounts;
    return data;
  }
}
