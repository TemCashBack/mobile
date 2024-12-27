import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryRepository {
  late CollectionReference categories;

  CategoryRepository() {
    this.categories = FirebaseFirestore.instance.collection('categories');
  }

  Stream<QuerySnapshot> getAllCategories() {
    return this.categories.snapshots(includeMetadataChanges: true);
  }
}
