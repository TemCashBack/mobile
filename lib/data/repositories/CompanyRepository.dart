import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile/data/models/CompanyModel.dart';

class CompanyRepository {
  late CollectionReference companies;

  CompanyRepository() {
    companies = FirebaseFirestore.instance.collection('companies');
  }

  Stream<QuerySnapshot> getAllCompanies() {
    return companies.snapshots(includeMetadataChanges: true);
  }

  Stream<QuerySnapshot> getPhysicalCompanies() {
    return companies
        .where('isOnline', isEqualTo: false)
        .snapshots(includeMetadataChanges: true);
  }

  Future<List<CompanyModel>> getSuggestions(String term) async {
    if (term.isEmpty) {
      return [];
    }
    // Realiza a consulta no Firestore usando `isGreaterThanOrEqualTo` e `isLessThanOrEqualTo`
    final snapshot = await companies
        .where('nomeFantasia', isGreaterThanOrEqualTo: term)
        .where('nomeFantasia',
            isLessThanOrEqualTo:
                '$term\uf8ff') // Garante a busca com correspondência parcial
        .get();

    // Extrai e retorna as sugestões dos documentos encontrados
    return snapshot.docs.map((e) {
      var a = jsonEncode(e.data());
      return CompanyModel.fromJson(jsonDecode(a));
    }).toList();
  }
}
