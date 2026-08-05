import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/core/firebase/firebase_callable_service.dart';
import 'package:mobile/data/models/customer_model.dart';
import 'package:mobile/data/repositories/customer_repository.dart';
import 'package:mobile/routes/app_routes.dart';
import 'package:mobile/ui/theme/app_styles.dart';
import 'package:mobile/ui/theme/colors.dart';
import 'package:mobile/ui/widgets/progress_indicator_custom.dart';

class RegistroController extends GetxController {
  RegistroController({required this.customerRepository});

  final CustomerRepository customerRepository;

  var currentStep = 0.obs;
  var isCheckingEmail = false.obs;

  final emailController = TextEditingController();
  final nomeController = TextEditingController();
  final cepController = TextEditingController();
  final ruaController = TextEditingController();
  final cidadeController = TextEditingController();
  final estadoController = TextEditingController();
  final numeroController = TextEditingController();
  final complementoController = TextEditingController();
  final bairroController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final codigoConviteController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Validações

  String? validacaoCodigoConvite(String value) {
    if (value.isEmpty) {
      return 'Por favor, digite seu código de convite.';
    }
    //Fazer uma validação de codigo de convite
    if (value != "1234567890") {
      return 'Código de convite inválido.';
    }
    return null;
  }

  String? validateEmail(String value) {
    if (value.isEmpty) {
      return 'Por favor, insira seu e-mail.';
    }
    if (!GetUtils.isEmail(value)) {
      return 'Insira um e-mail válido.';
    }
    return null;
  }

  String? validateName(String value) {
    if (value.isEmpty) {
      return 'Por favor, insira seu nome completo.';
    }
    return null;
  }

  String? validateCep(String value) {
    if (value.isEmpty) {
      return 'Por favor, insira o CEP.';
    }
    if (value.length != 8 || !GetUtils.isNumericOnly(value)) {
      return 'Insira um CEP válido (8 dígitos).';
    }
    return null;
  }

  String? validatePassword(String value) {
    if (value.isEmpty) {
      return 'Por favor, insira sua senha.';
    }
    if (value.length < 6) {
      return 'A senha deve ter pelo menos 6 caracteres.';
    }
    return null;
  }

  String? validateConfirmPassword(String value) {
    if (value.isEmpty) {
      return 'Por favor, confirme sua senha.';
    }
    if (value != passwordController.text) {
      return 'As senhas não coincidem.';
    }
    return null;
  }

  // Buscar endereço pelo CEP
  Future<void> fetchAddressByCep() async {
    final cep = cepController.text;
    if (validateCep(cep) != null) {
      _showErrorDialog(title: 'Erro', message: 'CEP inválido.');
      return;
    }

    try {
      final url = Uri.parse('https://viacep.com.br/ws/$cep/json/');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['erro'] == true) {
          _showErrorDialog(title: 'Erro', message: 'CEP não encontrado.');
        } else {
          ruaController.text = data['logradouro'] ?? '';
          numeroController.text = data['numero'] ?? '';
          complementoController.text = data['complemento'] ?? '';
          cidadeController.text = data['localidade'] ?? '';
          estadoController.text = data['uf'] ?? '';
          bairroController.text = data['bairro'] ?? '';
        }
      } else {
        throw Exception('Erro ao buscar o CEP');
      }
    } catch (e) {
      _showErrorDialog(
        title: 'Erro',
        message: 'Não foi possível buscar o endereço.',
      );
    }
  }

  // Validação geral da etapa atual
  String? validateCurrentStep() {
    switch (currentStep.value) {
      case 0:
        return validateEmail(emailController.text);
      case 1:
        return validateName(nomeController.text);
      case 2:
        if (validateCep(cepController.text) != null) {
          return validateCep(cepController.text);
        }
        if (ruaController.text.trim().isEmpty) {
          return 'Informe a rua.';
        }
        if (numeroController.text.trim().isEmpty) {
          return 'Informe o número.';
        }
        return null;
      case 3:
        final passwordError =
            validatePassword(passwordController.text);
        if (passwordError != null) return passwordError;
        return validateConfirmPassword(confirmPasswordController.text);
      default:
        return null;
    }
  }

  Future<bool> isEmailAlreadyRegistered(String email) async {
    final normalized = email.trim().toLowerCase();

    // No cadastro o usuário ainda não está autenticado — a leitura em
    // customers pode falhar por rules; não bloqueia a verificação.
    try {
      if (await customerRepository.existsByEmail(normalized)) {
        return true;
      }
    } catch (_) {}

    try {
      return await FirebaseCallableService().checkEmailExists(normalized);
    } catch (_) {
      // Fallback se a Function falhar (rede / App Check / etc.).
      return _existsInFirebaseAuth(normalized);
    }
  }

  /// Verifica no Auth tentando criar a conta. Se o e-mail já existir,
  /// o Firebase retorna [email-already-in-use]. Se criar, remove o usuário
  /// temporário imediatamente.
  Future<bool> _existsInFirebaseAuth(String email) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: _temporaryPassword(),
      );

      try {
        await credential.user?.delete();
      } finally {
        if (_auth.currentUser != null) {
          await _auth.signOut();
        }
      }
      return false;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        return true;
      }
      rethrow;
    }
  }

  String _temporaryPassword() {
    return 'Tmp!${DateTime.now().microsecondsSinceEpoch}Aa1';
  }

  // Próxima etapa com validação
  Future<void> nextStep() async {
    final response = validateCurrentStep();
    if (response != null) {
      _showErrorDialog(title: 'Atenção', message: response);
      return;
    }

    if (currentStep.value == 0) {
      isCheckingEmail.value = true;
      try {
        final email = emailController.text.trim().toLowerCase();
        emailController.text = email;

        final alreadyRegistered = await isEmailAlreadyRegistered(email);
        if (alreadyRegistered) {
          _showErrorDialog(
            title: 'E-mail já cadastrado',
            message:
                'Já existe uma conta com este e-mail. Faça login ou use outro e-mail.',
          );
          return;
        }
      } catch (_) {
        _showErrorDialog(
          title: 'Erro',
          message: 'Não foi possível verificar o e-mail. Tente novamente.',
        );
        return;
      } finally {
        isCheckingEmail.value = false;
      }
    }

    if (currentStep.value < 3) {
      currentStep.value++;
    } else {
      await completeRegistration();
    }
  }

  /// Fecha dialog/loading sem passar por Get.back() (que tenta limpar
  /// snackbar e pode estourar LateInitializationError / No Overlay).
  void _closeDialog() {
    final ctx = Get.overlayContext ?? Get.context;
    if (ctx == null) return;
    final navigator = Navigator.of(ctx, rootNavigator: true);
    if (navigator.canPop()) {
      navigator.pop();
    }
  }

  void _showErrorDialog({
    required String title,
    required String message,
  }) {
    if (Get.isDialogOpen ?? false) {
      _closeDialog();
    }

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.md,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline_rounded,
                  color: AppColors.error,
                  size: 30,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryThemeColor,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _closeDialog,
                  child: const Text('Entendi'),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  // Voltar para a etapa anterior
  void previousStep() {
    if (currentStep.value > 0) {
      currentStep.value--;
    }
  }

  // Finalizar o cadastro
  void completeRegistrations() {
    Get.dialog(
      Center(
        child: ProgressIndicatorCustom(),
      ),
      barrierDismissible: true,
    );
  }

  Future<void> completeRegistration() async {
    try {
      Get.dialog(
        Center(
          child: ProgressIndicatorCustom(),
        ),
        barrierDismissible: false,
      );

      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim().toLowerCase(),
        password: passwordController.text,
      );

      CustomerModel customerModel = CustomerModel(
          email: emailController.text.trim().toLowerCase(),
          nomeCompleto: nomeController.text,
          cep: cepController.text,
          rua: ruaController.text,
          n: numeroController.text,
          complemento: complementoController.text.trim().isEmpty
              ? null
              : complementoController.text.trim(),
          bairro: bairroController.text,
          cidade: cidadeController.text,
          estado: estadoController.text,
          uid: userCredential.user?.uid);

      await customerRepository.registerCustomer(customerModel);

      if (Get.isDialogOpen ?? false) _closeDialog();
      await Future<void>.delayed(const Duration(milliseconds: 50));
      Get.offNamed(AppRoutes.SELFIE);
    } on FirebaseAuthException catch (e) {
      String message = '';
      if (e.code == 'email-already-in-use') {
        message = 'Este e-mail já está em uso.';
      } else if (e.code == 'invalid-email') {
        message = 'O e-mail informado é inválido.';
      } else if (e.code == 'weak-password') {
        message = 'A senha é muito fraca.';
      } else {
        message = 'Erro ao cadastrar: ${e.message}';
      }
      if (Get.isDialogOpen ?? false) _closeDialog();
      _showErrorDialog(title: 'Erro', message: message);
    } catch (e) {
      if (Get.isDialogOpen ?? false) _closeDialog();
      _showErrorDialog(title: 'Erro', message: '$e');
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    nomeController.dispose();
    cepController.dispose();
    ruaController.dispose();
    cidadeController.dispose();
    estadoController.dispose();
    numeroController.dispose();
    complementoController.dispose();
    bairroController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    codigoConviteController.dispose();
    super.onClose();
  }
}
