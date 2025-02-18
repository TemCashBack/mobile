import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:mobile/controllers/user_controller.dart';
import 'package:mobile/data/models/user_model.dart';

class UserRepository {
  late CollectionReference customers;
  final userController = Get.put(UserController());

  UserRepository() {
    customers = FirebaseFirestore.instance.collection('customers');
  }

  Stream<QuerySnapshot> getCompanies() {
    return customers.snapshots(includeMetadataChanges: true);
  }

  Future<void> saveUser() async {
    UserModel userModel = UserModel(
        displayName: userController.user.displayName ?? '',
        photoURL: userController.user.photoURL ?? '',
        email: userController.user.email ?? '',
        uid: userController.user.uid);

    var customer =
        await customers.where('uid', isEqualTo: userController.user.uid).get();

    //Faz o update do documento
    if (customer.docs.isNotEmpty) {
      await customers.doc(customer.docs[0].id).set(userModel.toJson());
    } else {
      await customers.add(userModel.toJson());
    }
  }
}
