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

    if (customerSnapshot.docs.isEmpty) return;

    await customerSnapshot.docs.first.reference.update({'photoURL': photoURL});
  }
}
