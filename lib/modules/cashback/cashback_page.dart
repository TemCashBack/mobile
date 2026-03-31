import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:get/get.dart';
import 'package:mobile/modules/cashback/cashback_controller.dart';
import 'package:mobile/routes/app_routes.dart';
import 'package:mobile/ui/theme/colors.dart';

// ignore: must_be_immutable
class CashbackPage extends StatelessWidget {
  final CashbackController controller = Get.put(CashbackController());

  CashbackPage({super.key}) {
    _executarMetodo();
  }

  void _executarMetodo() {
    Future.microtask(() {
      controller.currentStep.value = 0;
      controller.loadCashbackBalance();
    });
  }

  @override
  Widget build(BuildContext context) {
    final MoneyMaskedTextController moneyController = MoneyMaskedTextController(
      decimalSeparator: ',',
      thousandSeparator: '.',
      precision: 2,
    );

    final MoneyMaskedTextController moneyController2 =
        MoneyMaskedTextController(
      decimalSeparator: ',',
      thousandSeparator: '.',
      precision: 2,
    );

    void validateInput(String value) {
      double inputValue = moneyController.numberValue;
      if (inputValue > 200) {
        moneyController.updateValue(200);
        controller.valorCompra.value = 200;
      } else {
        controller.valorCompra.value = inputValue;
      }
    }

    void validateInputForUsedCashback(String value, String maxUsed) {
      double inputValue = moneyController2.numberValue;
      double used = double.parse(maxUsed);
      if (inputValue > used) {
        moneyController2.updateValue(used);
        controller.utilizaValor.value = used;
      } else {
        controller.utilizaValor.value = inputValue;
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text('Finalizar compra')),
      body: Obx(
        () {
          if (controller.isLoading.value) {
            return Positioned.fill(
              child: Container(
                width: MediaQuery.of(context).size.width,
                color: Colors.black.withOpacity(0.4),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        color: primaryThemeColor,
                      ),
                      Text('Finalizando a sua compra....')
                    ]),
              ),
            );
          } else {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: Theme.of(context).colorScheme.copyWith(
                    primary: primaryThemeColor, // Cor do Step ativo
                    secondary: secondaryThemeColor),
              ),
              child: Stack(children: [
                Stepper(
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
                      controller.saveCashBack().then((id) {
                        Get.toNamed(AppRoutes.HOME);
                      });
                    } else {
                      controller.nextStep();
                    }
                  },
                  onStepCancel: controller.previousStep,
                  controlsBuilder:
                      (BuildContext context, ControlsDetails details) {
                    return Row(
                      children: [
                        ElevatedButton(
                          onPressed: details.onStepContinue,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: primaryThemeColor),
                          child: Text(
                              (controller.currentStep.value == 3)
                                  ? 'Finalizar'
                                  : 'Continuar',
                              style: TextStyle(color: Colors.white)),
                        ),
                        SizedBox(width: 10),
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
                      title: Text('Digite o Valor da Compra'),
                      content: Column(
                        children: [
                          TextField(
                            controller: moneyController,
                            keyboardType:
                                TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                                labelText: 'Valor (até R\$200,00)'),
                            onChanged: (value) {
                              validateInput(value);
                            },
                          ),
                        ],
                      ),
                      isActive: controller.currentStep.value >= 1,
                    ),
                    Step(
                      title: Text('Tirar Foto do Comprovante'),
                      content: Column(
                        children: [
                          // ignore: unnecessary_null_comparison
                          Obx(() => controller.imagePath.value != null
                              ? Image.file(File(controller.imagePath.value))
                              : Text('Nenhuma imagem selecionada')),
                          SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: controller.pickImage,
                            child: Text('Tirar Foto'),
                          ),
                        ],
                      ),
                      isActive: controller.currentStep.value >= 2,
                    ),
                    Step(
                      title: Text(
                          'Utilizar o cashback da loja?\nDisponível R\$${controller.usedCashback.value.toStringAsFixed(2).replaceAll('.', ',')}'),
                      content: Column(
                        children: [
                          TextField(
                            controller: moneyController2,
                            keyboardType:
                                TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(labelText: 'Valor'),
                            onChanged: (value) {
                              validateInputForUsedCashback(value,
                                  controller.usedCashback.value.toString());
                            },
                          ),
                          Text(
                              'Ao utilizar o cashback, essa compra não gerará ganhos de cashback.')
                        ],
                      ),
                      isActive: controller.currentStep.value >= 2,
                    ),
                    Step(
                      title: Text('Confirmação'),
                      content: Column(
                        children: [
                          Text(
                              'Sua compra será analisada pelo lojista. Assim que for confirmada, você receberá uma notificação no app informando a aprovação.'),
                        ],
                      ),
                      isActive: controller.currentStep.value >= 4,
                    ),
                  ],
                ),
              ]),
            );
          }
        },
      ),
    );
  }
}
