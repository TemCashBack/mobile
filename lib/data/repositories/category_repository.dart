import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryRepository {
  late CollectionReference categories;

  CategoryRepository() {
    categories = FirebaseFirestore.instance.collection('categories');
  }

  Stream<QuerySnapshot> getAllCategories() {
    return categories.snapshots(includeMetadataChanges: true);
  }
}
