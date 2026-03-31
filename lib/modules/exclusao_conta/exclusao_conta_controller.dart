import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/controllers/auth_controller.dart';
import 'package:mobile/data/repositories/customer_repository.dart';
import 'package:mobile/data/repositories/cashback_repository.dart';
import 'package:mobile/data/repositories/used_cashback_repository.dart';
import 'package:mobile/data/repositories/checkin_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ExclusaoContaController extends GetxController {
  final CustomerRepository customerRepository = CustomerRepository();
  final CashbackRepository cashbackRepository = CashbackRepository();
  final UsedCashbackRepository usedCashbackRepository =
      UsedCashbackRepository();
  final CheckinRepository checkinRepository = CheckinRepository();

  // Usar getter lazy para evitar problemas de dependência
  AuthController get authController => Get.find<AuthController>();

  var isLoading = false.obs;
  var confirmationText = ''.obs;

  final TextEditingController confirmationController = TextEditingController();

  bool get canDelete => confirmationText.value.toLowerCase() == 'excluir';

  @override
  void onInit() {
    super.onInit();
    confirmationController.addListener(() {
      confirmationText.value = confirmationController.text;
    });
  }

  @override
  void onClose() {
    confirmationController.dispose();
    super.onClose();
  }

  Future<void> excluirConta() async {
    if (!canDelete) {
      Get.snackbar(
        'Erro',
        'Digite "EXCLUIR" para confirmar a exclusão da conta',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;

    try {
      final user = authController.user.value;
      if (user == null) {
        throw Exception('Usuário não encontrado');
      }

      final uid = user.uid;

      // 1. Excluir todos os cashbacks do usuário
      await _excluirCashbacks(uid);

      // 2. Excluir todos os cashbacks utilizados
      await _excluirCashbacksUtilizados(uid);

      // 3. Excluir todos os check-ins
      await _excluirCheckins(uid);

      // 4. Excluir dados do customer
      await _excluirDadosCustomer(uid);

      // 5. Excluir conta do Firebase Auth
      await user.delete();

      Get.snackbar(
        'Sucesso',
        'Conta excluída com sucesso',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // O AuthController já vai redirecionar para a tela de boas-vindas
      // quando detectar que o usuário foi deslogado
    } catch (e) {
      print('Erro ao excluir conta: $e');
      Get.snackbar(
        'Erro',
        'Erro ao excluir conta: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _excluirCashbacks(String uid) async {
    final firestore = FirebaseFirestore.instance;
    final cashbackQuery = await firestore
        .collection('cashback')
        .where('customerId', isEqualTo: uid)
        .get();

    final batch = firestore.batch();
    for (var doc in cashbackQuery.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  Future<void> _excluirCashbacksUtilizados(String uid) async {
    final firestore = FirebaseFirestore.instance;
    final usedCashbackQuery = await firestore
        .collection('usedCashback')
        .where('customerId', isEqualTo: uid)
        .get();

    final batch = firestore.batch();
    for (var doc in usedCashbackQuery.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  Future<void> _excluirCheckins(String uid) async {
    final firestore = FirebaseFirestore.instance;
    final checkinQuery = await firestore
        .collection('checkin')
        .where('customerId', isEqualTo: uid)
        .get();

    final batch = firestore.batch();
    for (var doc in checkinQuery.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  Future<void> _excluirDadosCustomer(String uid) async {
    final firestore = FirebaseFirestore.instance;
    final customerQuery = await firestore
        .collection('customers')
        .where('uid', isEqualTo: uid)
        .get();

    final batch = firestore.batch();
    for (var doc in customerQuery.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  void mostrarDialogoConfirmacao() {
    Get.dialog(
      AlertDialog(
        title: Text('Confirmar Exclusão'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Esta ação não pode ser desfeita. Todos os seus dados serão permanentemente excluídos, incluindo:',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 10),
            Text('• Histórico de cashback'),
            Text('• Check-ins realizados'),
            Text('• Dados pessoais'),
            Text('• Conta de usuário'),
            SizedBox(height: 20),
            Text(
              'Digite "EXCLUIR" para confirmar:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            TextField(
              controller: confirmationController,
              decoration: InputDecoration(
                hintText: 'Digite EXCLUIR',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              confirmationController.clear();
              Get.back();
            },
            child: Text('Cancelar'),
          ),
          Obx(() => ElevatedButton(
                onPressed: confirmationText.value.toLowerCase() == 'excluir' &&
                        !isLoading.value
                    ? () {
                        Get.back();
                        excluirConta();
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: isLoading.value
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text('Excluir Conta'),
              )),
        ],
      ),
      barrierDismissible: false,
    );
  }
}
