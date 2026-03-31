import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mobile/controllers/customer_controller.dart';
import 'package:mobile/controllers/firebase_message_controller.dart';
import 'package:mobile/data/models/customer_model.dart';
import 'package:mobile/data/repositories/customer_repository.dart';
import 'package:mobile/modules/boas_vindas/boas_vindas_page.dart';
import 'package:mobile/modules/home/home_page.dart';

class AuthController extends GetxController {
  AuthController({required this.customerRepository});

  final FirebaseMessagingController firebaseMessagingController =
      Get.find<FirebaseMessagingController>();

  final CustomerController customerController = Get.find<CustomerController>();

  final CustomerRepository customerRepository;

  Rx<User?> user = Rx<User?>(null);
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Rx<Map<String, dynamic>?> userData = Rx<Map<String, dynamic>?>(null);

  var customerData = Rxn<CustomerModel>();

  @override
  void onInit() {
    super.onInit();
    user.bindStream(_auth.authStateChanges());
    ever(user, _setInitialScreen);
    ever(user, (User? user) {
      if (user != null) {
        getCustomerData(user.uid);
        updateFCMToken(user);
      }
    });
  }

  Future<void> updateFCMToken(User user) async {
    String? token = await firebaseMessagingController.getToken();
    if (token != null) {
      await customerRepository.updateFCMToken(user.uid, token);
    }
  }

  void _setInitialScreen(User? user) {
    if (user == null) {
      Get.offAll(() => BoasVindasPage());
    } else {
      Get.offAll(() => HomePage());
    }
  }

  Future<void> getCustomerData(String uid) async {
    try {
      final customerDoc = await customerRepository.getCustomerByUID(uid);
      if (customerDoc.exists) {
        customerData.value =
            CustomerModel.fromJson(customerDoc.data() as Map<String, dynamic>);
        customerController.customerId.value = customerData.value!.uid!;
      }
    } catch (e) {
      print("Erro ao buscar dados do customer: $e");
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        await _auth.signInWithCredential(credential);
      }
    } catch (e) {
      Get.snackbar("Erro", "Falha ao autenticar: $e");
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }
}
