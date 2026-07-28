import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mobile/controllers/customer_controller.dart';
import 'package:mobile/controllers/firebase_message_controller.dart';
import 'package:mobile/data/models/customer_model.dart';
import 'package:mobile/data/repositories/cashback_repository.dart';
import 'package:mobile/data/repositories/customer_repository.dart';
import 'package:mobile/routes/app_routes.dart';
import 'package:mobile/ui/widgets/progress_indicator_custom.dart';

class AuthController extends GetxController {
  AuthController({
    required this.customerRepository,
    required this.cashbackRepository,
  });

  final FirebaseMessagingController firebaseMessagingController =
      Get.find<FirebaseMessagingController>();

  final CustomerController customerController = Get.find<CustomerController>();

  final CustomerRepository customerRepository;
  final CashbackRepository cashbackRepository;

  Rx<User?> user = Rx<User?>(null);
  final isAuthReady = false.obs;
  final isDeletingAccount = false.obs;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseStorage _storage = FirebaseStorage.instance;

  var customerData = Rxn<CustomerModel>();

  StreamSubscription<User?>? _authSubscription;
  String? _lastTargetRoute;

  bool get usesPasswordProvider {
    final current = _auth.currentUser;
    if (current == null) return false;
    return current.providerData.any((p) => p.providerId == 'password');
  }

  bool get usesGoogleProvider {
    final current = _auth.currentUser;
    if (current == null) return false;
    return current.providerData.any((p) => p.providerId == 'google.com');
  }

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
    if (currentRoute == AppRoutes.LOGIN &&
        targetRoute == AppRoutes.BOASVINDAS) {
      return;
    }
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

  /// Exclusão permanente da conta (exigência Apple 5.1.1(v)).
  /// Remove dados do usuário, arquivos e o usuário no Firebase Auth.
  Future<void> deleteAccount({String? password}) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw StateError('Nenhum usuário autenticado.');
    }

    if (isDeletingAccount.value) return;
    isDeletingAccount.value = true;
    var showedLoading = false;

    try {
      await _reauthenticate(currentUser, password: password);

      Get.dialog(
        const Center(child: ProgressIndicatorCustom()),
        barrierDismissible: false,
      );
      showedLoading = true;

      final uid = currentUser.uid;
      final storageUrls = <String>[];

      storageUrls.addAll(await customerRepository.deleteAllByUid(uid));
      storageUrls
          .addAll(await cashbackRepository.deleteAllByCustomerId(uid));
      await _deleteStorageFiles(storageUrls);

      if (showedLoading && (Get.isDialogOpen ?? false)) {
        Get.back();
        showedLoading = false;
      }

      await currentUser.delete();
      _lastTargetRoute = null;
      await _googleSignIn.signOut();
    } finally {
      if (showedLoading && (Get.isDialogOpen ?? false)) Get.back();
      isDeletingAccount.value = false;
    }
  }

  Future<void> _reauthenticate(User currentUser, {String? password}) async {
    final providers =
        currentUser.providerData.map((p) => p.providerId).toSet();

    if (providers.contains('password')) {
      final email = currentUser.email;
      if (email == null || email.isEmpty) {
        throw FirebaseAuthException(
          code: 'missing-email',
          message: 'Conta sem e-mail para reautenticação.',
        );
      }
      if (password == null || password.trim().isEmpty) {
        throw FirebaseAuthException(
          code: 'missing-password',
          message: 'Informe a senha para confirmar a exclusão.',
        );
      }
      final credential = EmailAuthProvider.credential(
        email: email,
        password: password.trim(),
      );
      await currentUser.reauthenticateWithCredential(credential);
      return;
    }

    if (providers.contains('google.com')) {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw FirebaseAuthException(
          code: 'aborted-by-user',
          message: 'Reautenticação cancelada.',
        );
      }
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await currentUser.reauthenticateWithCredential(credential);
      return;
    }

    throw FirebaseAuthException(
      code: 'unsupported-provider',
      message: 'Não foi possível confirmar sua identidade para excluir a conta.',
    );
  }

  Future<void> _deleteStorageFiles(List<String> urls) async {
    final unique = urls.toSet().where((u) => u.startsWith('http'));
    for (final url in unique) {
      try {
        await _storage.refFromURL(url).delete();
      } catch (_) {
        // Arquivo já removido ou URL inválida — segue a exclusão da conta.
      }
    }
  }

  @override
  void onClose() {
    _authSubscription?.cancel();
    super.onClose();
  }
}
