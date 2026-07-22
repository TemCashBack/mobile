import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:get/get.dart';
import 'package:mobile/modules/cashback/cashback_controller.dart';
import 'package:mobile/routes/app_routes.dart';
import 'package:mobile/ui/theme/colors.dart';

class CashbackPage extends GetView<CashbackController> {
  CashbackPage({super.key});

  @override
  Widget build(BuildContext context) {
    final moneyController = MoneyMaskedTextController(
      decimalSeparator: ',',
      thousandSeparator: '.',
      precision: 2,
    );

    final moneyController2 = MoneyMaskedTextController(
      decimalSeparator: ',',
      thousandSeparator: '.',
      precision: 2,
    );

    void validateInput(String value) {
      final inputValue = moneyController.numberValue;
      if (inputValue > 200) {
        moneyController.updateValue(200);
        controller.valorCompra.value = 200;
      } else {
        controller.valorCompra.value = inputValue;
      }
    }

    void validateInputForUsedCashback(String value, String maxUsed) {
      final inputValue = moneyController2.numberValue;
      final used = double.parse(maxUsed);
      if (inputValue > used) {
        moneyController2.updateValue(used);
        controller.utilizaValor.value = used;
      } else {
        controller.utilizaValor.value = inputValue;
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Finalizar compra')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Container(
            width: MediaQuery.of(context).size.width,
            color: Colors.black.withOpacity(0.4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: primaryThemeColor),
                const Text('Finalizando a sua compra....'),
              ],
            ),
          );
        }

        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: primaryThemeColor,
                  secondary: secondaryThemeColor,
                ),
          ),
          child: Stepper(
            currentStep: controller.currentStep.value,
            onStepContinue: () {
              if (controller.currentStep.value == 0) {
                if (controller.valorCompra.value <= 0) {
                  Get.snackbar(
                      'Erro', 'Insira um valor válido para continuar.');
                  return;
                }
              } else if (controller.currentStep.value == 1) {
                if (controller.imagePath.value.isEmpty) {
                  Get.snackbar('Erro', 'Tire uma foto do comprovante.');
                  return;
                }
              }
              if (controller.currentStep.value == 3) {
                controller.isLoading.value = true;
                controller.saveCashBack().then((_) {
                  Get.offAllNamed(AppRoutes.HOME);
                });
              } else {
                controller.nextStep();
              }
            },
            onStepCancel: controller.previousStep,
            controlsBuilder: (context, details) {
              return Row(
                children: [
                  ElevatedButton(
                    onPressed: details.onStepContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryThemeColor,
                    ),
                    child: Text(
                      controller.currentStep.value == 3
                          ? 'Finalizar'
                          : 'Continuar',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: details.onStepCancel,
                    child: Text(
                      'Voltar',
                      style: TextStyle(color: primaryThemeColor),
                    ),
                  ),
                ],
              );
            },
            steps: [
              Step(
                title: const Text('Digite o Valor da Compra'),
                content: TextField(
                  controller: moneyController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Valor (até R\$200,00)',
                  ),
                  onChanged: validateInput,
                ),
                isActive: controller.currentStep.value >= 1,
              ),
              Step(
                title: const Text('Tirar Foto do Comprovante'),
                content: Column(
                  children: [
                    Obx(
                      () => controller.imagePath.value.isNotEmpty
                          ? Image.file(File(controller.imagePath.value))
                          : const Text('Nenhuma imagem selecionada'),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: controller.pickImage,
                      child: const Text('Tirar Foto'),
                    ),
                  ],
                ),
                isActive: controller.currentStep.value >= 2,
              ),
              Step(
                title: Text(
                  'Utilizar o cashback da loja?\nDisponível R\$${controller.usedCashback.value.toStringAsFixed(2).replaceAll('.', ',')}',
                ),
                content: Column(
                  children: [
                    TextField(
                      controller: moneyController2,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Valor'),
                      onChanged: (value) => validateInputForUsedCashback(
                        value,
                        controller.usedCashback.value.toString(),
                      ),
                    ),
                    const Text(
                      'Ao utilizar o cashback, essa compra não gerará ganhos de cashback.',
                    ),
                  ],
                ),
                isActive: controller.currentStep.value >= 2,
              ),
              Step(
                title: const Text('Confirmação'),
                content: const Text(
                  'Sua compra será analisada pelo lojista. Assim que for confirmada, você receberá uma notificação no app informando a aprovação.',
                ),
                isActive: controller.currentStep.value >= 4,
              ),
            ],
          ),
        );
      }),
    );
  }
}
