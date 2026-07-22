import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mobile/controllers/customer_controller.dart';
import 'package:mobile/controllers/firebase_message_controller.dart';
import 'package:mobile/data/models/customer_model.dart';
import 'package:mobile/data/repositories/customer_repository.dart';
import 'package:mobile/routes/app_routes.dart';

class AuthController extends GetxController {
  AuthController({required this.customerRepository});

  final FirebaseMessagingController firebaseMessagingController =
      Get.find<FirebaseMessagingController>();

  final CustomerController customerController = Get.find<CustomerController>();

  final CustomerRepository customerRepository;

  Rx<User?> user = Rx<User?>(null);
  final isAuthReady = false.obs;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  var customerData = Rxn<CustomerModel>();

  StreamSubscription<User?>? _authSubscription;
  String? _lastTargetRoute;

  @override
  void onInit() {
    super.onInit();
    _authSubscription = _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    user.value = firebaseUser;

    if (firebaseUser != null) {
      await getCustomerData(firebaseUser.uid);
      await updateFCMToken(firebaseUser);
    } else {
      customerData.value = null;
      customerController.customerId.value = '';
    }

    isAuthReady.value = true;
    _navigateIfNeeded(_resolveRoute(firebaseUser));
  }

  String _resolveRoute(User? firebaseUser) {
    if (firebaseUser == null) return AppRoutes.BOASVINDAS;

    final customer = customerData.value;
    if (customer != null && !customer.hasPhoto) {
      return AppRoutes.SELFIE;
    }

    return AppRoutes.HOME;
  }

  void _navigateIfNeeded(String targetRoute) {
    final currentRoute = Get.currentRoute;
    if (currentRoute == AppRoutes.REGISTRO) return;
    if (currentRoute == targetRoute) return;
    if (_lastTargetRoute == targetRoute &&
        currentRoute.isNotEmpty &&
        currentRoute != '/') {
      return;
    }

    _lastTargetRoute = targetRoute;
    Get.offAllNamed(targetRoute);
  }

  Future<void> updateFCMToken(User user) async {
    try {
      final token = await firebaseMessagingController.getToken();
      if (token != null) {
        await customerRepository.updateFCMToken(user.uid, token);
      }
    } catch (_) {
      // Token FCM indisponível (comum na web em dev).
    }
  }

  Future<void> getCustomerData(String uid) async {
    try {
      final customerDoc = await customerRepository.getCustomerByUID(uid);
      if (customerDoc != null && customerDoc.exists) {
        customerData.value = CustomerModel.fromJson(
            customerDoc.data() as Map<String, dynamic>);
        customerController.customerId.value = customerData.value!.uid ?? uid;
      } else {
        customerData.value = null;
        customerController.customerId.value = uid;
      }
    } catch (e) {
      Get.snackbar('Erro', 'Não foi possível carregar seus dados.');
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return;

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);
    } catch (e) {
      Get.snackbar('Erro', 'Falha ao autenticar: $e');
    }
  }

  Future<void> signOut() async {
    _lastTargetRoute = null;
    await _auth.signOut();
    await _googleSignIn.signOut();
  }

  @override
  void onClose() {
    _authSubscription?.cancel();
    super.onClose();
  }
}
