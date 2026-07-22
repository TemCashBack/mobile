import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/modules/registro/registro_controller.dart';
import 'package:mobile/ui/theme/colors.dart';

class RegistroPage extends GetView<RegistroController> {
  RegistroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Novo Cadastro'),
        backgroundColor: secondaryThemeColor,
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
        iconTheme: IconThemeData(
          color: Colors.white, // Cor do ícone do Drawer
        ),
      ),
      body: Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: primaryThemeColor, // Cor do Step ativo
              secondary: secondaryThemeColor),
        ),
        child: Row(
          children: [
            Expanded(
              child: Obx(
                () => Stepper(
                  currentStep: controller.currentStep.value,
                  onStepContinue: controller.nextStep,
                  onStepCancel: controller.previousStep,
                  steps: [
                    Step(
                      title: Text(
                        'Cadastro de E-mail',
                        style: TextStyle(color: secondaryThemeColor),
                      ),
                      content: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: TextField(
                          controller: controller.emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintStyle: TextStyle(fontSize: 8),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 10, // Altura do TextField
                              horizontal: 12, // Espaço horizontal
                            ),
                            labelText: 'E-mail',
                            labelStyle: TextStyle(fontSize: 12),
                            border: const OutlineInputBorder(),
                            errorText: controller.currentStep.value == 0
                                ? controller.validateEmail(
                                    controller.emailController.text)
                                : null,
                          ),
                        ),
                      ),
                      isActive: controller.currentStep.value >= 1,
                    ),
                    Step(
                      title: Text(
                        'Cadastro de Nome Completo',
                        style: TextStyle(color: secondaryThemeColor),
                      ),
                      content: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: TextField(
                          controller: controller.nomeController,
                          decoration: InputDecoration(
                            labelText: 'Nome Completo',
                            border: const OutlineInputBorder(),
                            errorText: controller.currentStep.value == 1
                                ? controller.validateName(
                                    controller.nomeController.text)
                                : null,
                          ),
                        ),
                      ),
                      isActive: controller.currentStep.value >= 2,
                    ),
                    Step(
                      title: Text(
                        'Cadastro de Endereço',
                        style: TextStyle(color: secondaryThemeColor),
                      ),
                      content: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Column(
                          children: [
                            TextField(
                              controller: controller.cepController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'CEP',
                                border: OutlineInputBorder(),
                                suffixIcon: IconButton(
                                  icon: Icon(Icons.search),
                                  onPressed: controller.fetchAddressByCep,
                                ),
                              ),
                            ),
                            SizedBox(height: 10),
                            TextField(
                              controller: controller.ruaController,
                              decoration: InputDecoration(
                                labelText: 'Rua',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            SizedBox(height: 10),
                            TextField(
                              controller: controller.numeroController,
                              decoration: InputDecoration(
                                labelText: 'Nº',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            SizedBox(height: 10),
                            TextField(
                              controller: controller.bairroController,
                              decoration: InputDecoration(
                                labelText: 'Bairro',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            SizedBox(height: 10),
                            TextField(
                              controller: controller.cidadeController,
                              decoration: InputDecoration(
                                labelText: 'Cidade',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            SizedBox(height: 10),
                            TextField(
                              controller: controller.estadoController,
                              decoration: InputDecoration(
                                labelText: 'Estado',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ],
                        ),
                      ),
                      isActive: controller.currentStep.value >= 3,
                    ),
                    Step(
                      title: Text(
                        'Cadastro de Senha',
                        style: TextStyle(color: secondaryThemeColor),
                      ),
                      content: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Column(
                          children: [
                            TextField(
                              controller: controller.passwordController,
                              obscureText: true,
                              decoration: InputDecoration(
                                labelText: 'Senha',
                                border: OutlineInputBorder(),
                                errorText: controller.validatePassword(
                                    controller.passwordController.text),
                              ),
                            ),
                            SizedBox(height: 10),
                            TextField(
                              controller: controller.confirmPasswordController,
                              obscureText: true,
                              decoration: InputDecoration(
                                labelText: 'Confirmar Senha',
                                border: OutlineInputBorder(),
                                errorText: controller.validateConfirmPassword(
                                    controller.confirmPasswordController.text),
                              ),
                            ),
                          ],
                        ),
                      ),
                      isActive: controller.currentStep.value >= 4,
                    ),
                  ],
                  controlsBuilder:
                      (BuildContext context, ControlsDetails details) {
                    return Row(
                      children: [
                        ElevatedButton(
                          onPressed: details.onStepContinue,
                          child: Text(
                            controller.currentStep.value == 3
                                ? 'Finalizar'
                                : 'Próximo',
                            style: TextStyle(
                                fontSize: 12, color: primaryThemeColor),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (controller.currentStep.value > 0)
                          TextButton(
                            onPressed: details.onStepCancel,
                            child: Text(
                              'Voltar',
                              style: TextStyle(
                                  fontSize: 12, color: primaryThemeColor),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
