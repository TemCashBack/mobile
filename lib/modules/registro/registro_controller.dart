import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/data/models/customer_model.dart';
import 'package:mobile/data/repositories/customer_repository.dart';
import 'package:mobile/routes/app_routes.dart';
import 'package:mobile/ui/widgets/progress_indicator_custom.dart';

class RegistroController extends GetxController {
  var currentStep = 0.obs;

  // Controladores de texto
  final emailController = TextEditingController();
  final nomeController = TextEditingController();
  final cepController = TextEditingController();
  final ruaController = TextEditingController();
  final cidadeController = TextEditingController();
  final estadoController = TextEditingController();
  final numeroController = TextEditingController();
  final bairroController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final codigoConviteController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CustomerRepository customerRepository = CustomerRepository();

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
      Get.snackbar('Erro', 'CEP inválido.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
      return;
    }

    try {
      final url = Uri.parse('https://viacep.com.br/ws/$cep/json/');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['erro'] == true) {
          Get.snackbar('Erro', 'CEP não encontrado.',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.orange,
              colorText: Colors.white);
        } else {
          ruaController.text = data['logradouro'] ?? '';
          numeroController.text = data['numero'] ?? '';
          cidadeController.text = data['localidade'] ?? '';
          estadoController.text = data['uf'] ?? '';
          bairroController.text = data['bairro'] ?? '';
        }
      } else {
        throw Exception('Erro ao buscar o CEP');
      }
    } catch (e) {
      Get.snackbar('Erro', 'Não foi possível buscar o endereço.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
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
        return validateCep(cepController.text);
      case 3:
        return validateConfirmPassword(confirmPasswordController.text);
      default:
        return null;
    }
  }

  // Próxima etapa com validação
  void nextStep() {
    String? response = validateCurrentStep();
    if (response == null) {
      if (currentStep.value < 3) {
        currentStep.value++;
      } else {
        completeRegistration();
      }
    } else {
      Get.snackbar(
        'Erro',
        response,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
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
        email: emailController.text,
        password: passwordController.text,
      );

      CustomerModel customerModel = CustomerModel(
          email: emailController.text,
          nomeCompleto: nomeController.text,
          cep: cepController.text,
          rua: ruaController.text,
          n: numeroController.text,
          bairro: bairroController.text,
          cidade: cidadeController.text,
          estado: estadoController.text,
          uid: userCredential.user?.uid);

      await customerRepository.registerCustomer(customerModel);

      Get.back();
      Get.snackbar('Sucesso', 'Dados salvos com sucesso!');
      Get.toNamed(AppRoutes.SELFIE);
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
      Get.back();
      Get.defaultDialog(title: 'Erro', middleText: message);
    } catch (e) {
      Get.back();
      Get.defaultDialog(title: 'Erro', middleText: '$e');
    }
  }
}
