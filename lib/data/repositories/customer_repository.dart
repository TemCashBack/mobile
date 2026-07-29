import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile/core/constants/firestore_collections.dart';
import 'package:mobile/data/models/customer_model.dart';

class CustomerRepository {
  late CollectionReference customerCollection;
  final firestore = FirebaseFirestore.instance;

  CustomerRepository() {
    customerCollection = firestore.collection(FirestoreCollections.customers);
  }

  Future<void> registerCustomer(CustomerModel customer) async {
    await customerCollection.add(customer.toJson());
  }

  Future<bool> existsByEmail(String email) async {
    final normalized = email.trim().toLowerCase();
    if (normalized.isEmpty) return false;

    final byLower = await customerCollection
        .where('emailLower', isEqualTo: normalized)
        .limit(1)
        .get();
    if (byLower.docs.isNotEmpty) return true;

    final byEmail = await customerCollection
        .where('email', isEqualTo: normalized)
        .limit(1)
        .get();
    if (byEmail.docs.isNotEmpty) return true;

    return false;
  }

  Future<DocumentSnapshot?> getCustomerByUID(String uid) async {
    final customerSnapshot =
        await customerCollection.where('uid', isEqualTo: uid).get();
    if (customerSnapshot.docs.isEmpty) return null;
    return customerSnapshot.docs.first;
  }

  Future<void> updateFCMToken(String uid, String fcmToken) async {
    final customerSnapshot =
        await customerCollection.where('uid', isEqualTo: uid).get();
    if (customerSnapshot.docs.isEmpty) return;

    final docId = customerSnapshot.docs.first.id;
    await customerCollection.doc(docId).update({'fcmToken': fcmToken});
  }

  Future<void> updatePhotoURL(String uid, String photoURL) async {
    final customerSnapshot =
        await customerCollection.where('uid', isEqualTo: uid).get();

    if (customerSnapshot.docs.isEmpty) {
      throw StateError('Cliente não encontrado para atualizar a selfie.');
    }

    await customerSnapshot.docs.first.reference.update({'photoURL': photoURL});
  }

  /// Remove todos os documentos do cliente e devolve URLs de foto para limpar no Storage.
  Future<List<String>> deleteAllByUid(String uid) async {
    final snapshot =
        await customerCollection.where('uid', isEqualTo: uid).get();
    if (snapshot.docs.isEmpty) return const [];

    final photoUrls = <String>[];
    var batch = firestore.batch();
    var ops = 0;

    for (final doc in snapshot.docs) {
      final data = doc.data();
      if (data is Map<String, dynamic>) {
        final photo = data['photoURL']?.toString().trim();
        if (photo != null && photo.isNotEmpty) photoUrls.add(photo);
      }
      batch.delete(doc.reference);
      ops++;
      if (ops >= 450) {
        await batch.commit();
        batch = firestore.batch();
        ops = 0;
      }
    }

    if (ops > 0) await batch.commit();
    return photoUrls;
  }
}
