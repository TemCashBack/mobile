import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile/core/constants/firestore_collections.dart';
import 'package:mobile/data/models/company_model.dart';

class CompanyRepository {
  late CollectionReference companies;

  CompanyRepository() {
    companies =
        FirebaseFirestore.instance.collection(FirestoreCollections.companies);
  }

  /// Lista limitada no servidor (evita baixar a collection inteira).
  Stream<QuerySnapshot> getAllCompanies({int limit = 100}) {
    return companies
        .limit(limit)
        .snapshots(includeMetadataChanges: true);
  }

  Stream<QuerySnapshot> getPhysicalCompanies({int limit = 100}) {
    return companies
        .where('isOnline', isEqualTo: false)
        .limit(limit)
        .snapshots(includeMetadataChanges: true);
  }

  Future<List<CompanyModel>> getSuggestions(String term) async {
    if (term.isEmpty) {
      return [];
    }
    final snapshot = await companies
        .where('nomeFantasia', isGreaterThanOrEqualTo: term)
        .where('nomeFantasia', isLessThanOrEqualTo: '$term\uf8ff')
        .limit(20)
        .get();

    return snapshot.docs
        .map((e) {
          final map = CompanyModel.mapFromFirestore(e.data());
          if (!CompanyModel.isVisibleFromJson(map)) return null;
          return CompanyModel.fromFirestore(e.data(), documentId: e.id);
        })
        .whereType<CompanyModel>()
        .toList();
  }
}
