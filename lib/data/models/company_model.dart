import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile/data/models/geolocation_model.dart';
import 'package:mobile/data/models/social_model.dart';

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
  double cashbackPercentual;
  double limiteCompra;

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
    this.isOnline = false,
    this.cashbackPercentual = 5.0,
    this.limiteCompra = 200.0,
  });

  bool get hasValidCategory => categoria.trim().isNotEmpty;

  bool get hasValidGeolocation {
    final lat = geolocalizacao.lat;
    final lng = geolocalizacao.lng;
    return lat != 0 || lng != 0;
  }

  /// Aparece na lista/mapa apenas se tiver geolocalização ou categoria.
  bool get isVisibleInApp => hasValidGeolocation || hasValidCategory;

  bool get isMappable => hasValidGeolocation;

  static bool isVisibleFromJson(Map<String, dynamic> json) {
    return hasGeolocationInJson(json) || hasCategoryInJson(json);
  }

  static bool isMappableFromJson(Map<String, dynamic> json) {
    return hasGeolocationInJson(json);
  }

  static bool hasCategoryInJson(Map<String, dynamic> json) {
    return (json['categoria']?.toString().trim() ?? '').isNotEmpty;
  }

  static bool hasGeolocationInJson(Map<String, dynamic> json) {
    final geo = json['geolocalizacao'];
    if (geo is GeoPoint) {
      return geo.latitude != 0 || geo.longitude != 0;
    }
    if (geo is! Map) return false;
    final map = Map<String, dynamic>.from(geo);
    final lat = map['lat'];
    final lng = map['lng'];
    if (lat is! num || lng is! num) return false;
    return lat != 0 || lng != 0;
  }

  /// Converte dados do Firestore sem jsonEncode (evita crash com Timestamp/GeoPoint).
  static Map<String, dynamic> mapFromFirestore(Object? data) {
    if (data is! Map) return <String, dynamic>{};
    final result = <String, dynamic>{};
    data.forEach((key, value) {
      result[key.toString()] = _normalizeFirestoreValue(value);
    });
    return result;
  }

  static dynamic _normalizeFirestoreValue(dynamic value) {
    if (value is Timestamp) {
      return value.toDate().toIso8601String();
    }
    if (value is GeoPoint) {
      return {
        'lat': value.latitude,
        'lng': value.longitude,
        'accuracy': 0,
      };
    }
    if (value is Map) {
      return mapFromFirestore(value);
    }
    if (value is Iterable && value is! String) {
      return value.map(_normalizeFirestoreValue).toList();
    }
    return value;
  }

  static GeolocationModel _parseGeolocation(dynamic geoRaw) {
    if (geoRaw is GeoPoint) {
      return GeolocationModel(
        accuracy: 0,
        lat: geoRaw.latitude,
        lng: geoRaw.longitude,
      );
    }
    if (geoRaw is Map) {
      return GeolocationModel.fromJson(Map<String, dynamic>.from(geoRaw));
    }
    return GeolocationModel(accuracy: 0, lng: 0, lat: 0);
  }

  static SocialModel _parseSocials(dynamic socialsRaw) {
    if (socialsRaw is Map) {
      return SocialModel.fromJson(Map<String, dynamic>.from(socialsRaw));
    }
    return SocialModel(
      whatsapp: '',
      facebook: '',
      linkedin: '',
      instagram: '',
    );
  }

  factory CompanyModel.fromFirestore(
    Object? data, {
    String? documentId,
  }) {
    final json = mapFromFirestore(data);
    if (documentId != null && documentId.isNotEmpty) {
      json['id'] = documentId;
    }
    return CompanyModel.fromJson(json);
  }

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    final telefonesRaw = json['telefones'];
    final List<String> telefones = telefonesRaw is List
        ? telefonesRaw.map((e) => e.toString()).toList()
        : <String>[];

    return CompanyModel(
      endereco: json['endereco']?.toString() ?? '',
      numero: json['numero']?.toString() ?? '',
      bairro: json['bairro']?.toString() ?? '',
      municipio: json['municipio']?.toString() ?? '',
      cnpj: json['cnpj']?.toString() ?? '',
      telefones: telefones,
      cep: json['cep']?.toString() ?? '',
      createdAt: json['createdAt']?.toString() ?? '',
      uf: json['uf']?.toString() ?? '',
      nomeFantasia: json['nomeFantasia']?.toString() ?? '',
      complemento: json['complemento']?.toString() ?? '',
      foto: json['foto']?.toString() ?? '',
      geolocalizacao: _parseGeolocation(json['geolocalizacao']),
      id: json['id']?.toString() ?? '',
      socials: _parseSocials(json['socials']),
      razaoSocial: json['razaoSocial']?.toString() ?? '',
      status: (json['status'] as num?)?.toInt() ?? 0,
      categoria: json['categoria']?.toString() ?? '',
      isOnline: json['isOnline'] == true,
      cashbackPercentual: (json['cashbackPercentual'] as num?)?.toDouble() ?? 5.0,
      limiteCompra: (json['limiteCompra'] as num?)?.toDouble() ?? 200.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'endereco': endereco,
      'numero': numero,
      'bairro': bairro,
      'municipio': municipio,
      'cnpj': cnpj,
      'telefones': telefones,
      'cep': cep,
      'createdAt': createdAt,
      'uf': uf,
      'nomeFantasia': nomeFantasia,
      'complemento': complemento,
      'foto': foto,
      'geolocalizacao': geolocalizacao.toJson(),
      'id': id,
      'socials': socials.toJson(),
      'razaoSocial': razaoSocial,
      'status': status,
      'categoria': categoria,
      'isOnline': isOnline,
      'cashbackPercentual': cashbackPercentual,
      'limiteCompra': limiteCompra,
    };
  }
}
