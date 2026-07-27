import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/modules/registro/registro_controller.dart';
import 'package:mobile/ui/theme/app_styles.dart';
import 'package:mobile/ui/theme/colors.dart';

class RegistroPage extends GetView<RegistroController> {
  const RegistroPage({super.key});

  static const _stepTitles = [
    'E-mail',
    'Nome completo',
    'Endereço',
    'Senha',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo Cadastro'),
        backgroundColor: secondaryThemeColor,
        foregroundColor: Colors.white,
      ),
      body: Obx(
        () => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _StepHeader(
              currentStep: controller.currentStep.value,
              titles: _stepTitles,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: _buildStepContent(controller, controller.currentStep.value),
              ),
            ),
            _StepActions(
              currentStep: controller.currentStep.value,
              lastStep: _stepTitles.length - 1,
              isLoading: controller.isCheckingEmail.value,
              onNext: controller.nextStep,
              onBack: controller.previousStep,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepContent(RegistroController controller, int step) {
    switch (step) {
      case 0:
        return TextField(
          controller: controller.emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: 'E-mail',
            errorText: controller.validateEmail(controller.emailController.text),
          ),
        );
      case 1:
        return TextField(
          controller: controller.nomeController,
          decoration: InputDecoration(
            labelText: 'Nome completo',
            errorText: controller.validateName(controller.nomeController.text),
          ),
        );
      case 2:
        return Column(
          children: [
            TextField(
              controller: controller.cepController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'CEP',
                errorText: controller.validateCep(controller.cepController.text),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: controller.fetchAddressByCep,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: controller.ruaController,
              decoration: const InputDecoration(labelText: 'Rua'),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: controller.numeroController,
              decoration: const InputDecoration(labelText: 'Nº'),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: controller.bairroController,
              decoration: const InputDecoration(labelText: 'Bairro'),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: controller.cidadeController,
              decoration: const InputDecoration(labelText: 'Cidade'),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: controller.estadoController,
              decoration: const InputDecoration(labelText: 'Estado'),
            ),
          ],
        );
      case 3:
        return Column(
          children: [
            TextField(
              controller: controller.passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Senha',
                errorText:
                    controller.validatePassword(controller.passwordController.text),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: controller.confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Confirmar senha',
                errorText: controller.validateConfirmPassword(
                  controller.confirmPasswordController.text,
                ),
              ),
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

class _StepHeader extends StatelessWidget {
  const _StepHeader({
    required this.currentStep,
    required this.titles,
  });

  final int currentStep;
  final List<String> titles;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Etapa ${currentStep + 1} de ${titles.length}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            titles[currentStep],
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: primaryThemeColor.shade700,
                ),
          ),
          const SizedBox(height: AppSpacing.sm),
          LinearProgressIndicator(
            value: (currentStep + 1) / titles.length,
            backgroundColor: AppColors.divider,
            color: primaryThemeColor,
            minHeight: 4,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
        ],
      ),
    );
  }
}

class _StepActions extends StatelessWidget {
  const _StepActions({
    required this.currentStep,
    required this.lastStep,
    required this.isLoading,
    required this.onNext,
    required this.onBack,
  });

  final int currentStep;
  final int lastStep;
  final bool isLoading;
  final VoidCallback onNext;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            if (currentStep > 0)
              Expanded(
                child: OutlinedButton(
                  onPressed: isLoading ? null : onBack,
                  child: const Text('Voltar'),
                ),
              ),
            if (currentStep > 0) const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: ElevatedButton(
                onPressed: isLoading ? null : onNext,
                child: isLoading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : Text(currentStep == lastStep ? 'Finalizar' : 'Próximo'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
