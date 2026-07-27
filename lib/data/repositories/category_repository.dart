import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile/core/constants/firestore_collections.dart';

class CategoryRepository {
  late CollectionReference categories;

  CategoryRepository() {
    categories =
        FirebaseFirestore.instance.collection(FirestoreCollections.categories);
  }

  Stream<QuerySnapshot> getAllCategories() {
    return categories.snapshots(includeMetadataChanges: true);
  }
}
