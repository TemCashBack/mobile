import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile/data/models/customer_model.dart';

class CustomerRepository {
  late CollectionReference customerCollection;
  final firestore = FirebaseFirestore.instance;

  CustomerRepository() {
    customerCollection = firestore.collection('customers');
  }

  Future<void> registerCustomer(CustomerModel customer) async {
    customerCollection.add(customer.toJson());
  }

  Future<DocumentSnapshot> getCustomerByUID(String uid) async {
    QuerySnapshot customerSnapshot =
        await customerCollection.where('uid', isEqualTo: uid).get();
    String docId = customerSnapshot.docs[0].id;
    return await customerCollection.doc(docId).get();
  }

  Future<void> updateFCMToken(String uid, String fcmToken) async {
    QuerySnapshot customerSnapshot =
        await customerCollection.where('uid', isEqualTo: uid).get();
    String docId = customerSnapshot.docs[0].id;
    return await customerCollection.doc(docId).update({"fcmToken": fcmToken});
  }

  Future<void> updatePhotoURL(String uid, String photoURL) async {
    QuerySnapshot customerSnapshot =
        await customerCollection.where('uid', isEqualTo: uid).get();

    if (customerSnapshot.docs.isNotEmpty) {
      DocumentSnapshot document = customerSnapshot.docs.first;
      await document.reference.update({
        'photoURL': photoURL,
      });
      print("Documento atualizado com sucesso!");
    } else {
      print("Documento não encontrado!");
    }
  }
}
