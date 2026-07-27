import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/modules/cashback/cashback_controller.dart';
import 'package:mobile/routes/app_routes.dart';
import 'package:mobile/ui/theme/app_styles.dart';
import 'package:mobile/ui/theme/colors.dart';

class CashbackPage extends GetView<CashbackController> {
  const CashbackPage({super.key});

  static const _titles = [
    'Valor da compra',
    'Comprovante',
    'Usar cashback',
    'Confirmação',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Finalizar compra')),
      body: Obx(() {
        final step = controller.currentStep.value;
        return Stack(
          children: [
            Column(
              children: [
                _StepHeader(
                  currentStep: step,
                  titles: _titles,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: _buildStepContent(step),
                  ),
                ),
                _StepActions(
                  currentStep: step,
                  lastStep: _titles.length - 1,
                  onBack: controller.previousStep,
                  onContinue: _onStepContinue,
                ),
              ],
            ),
            if (controller.isLoading.value) const _LoadingOverlay(),
          ],
        );
      }),
    );
  }

  Widget _buildStepContent(int step) {
    switch (step) {
      case 0:
        return _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Informe o valor da compra',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              const Text(
                'O valor máximo por compra é R\$ 200,00.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: controller.valorCompraController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Valor (R\$)',
                  prefixText: 'R\$ ',
                ),
                onChanged: controller.onValorCompraChanged,
              ),
            ],
          ),
        );
      case 1:
        return _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Envie a foto do comprovante',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Obx(() {
                final bytes = controller.imageBytes.value;
                if (bytes == null) {
                  return Container(
                    height: 180,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 36,
                          color: AppColors.textSecondary,
                        ),
                        SizedBox(height: AppSpacing.sm),
                        Text(
                          'Nenhuma imagem selecionada',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  );
                }

                return ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  child: Image.memory(
                    bytes,
                    height: 220,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                );
              }),
              const SizedBox(height: AppSpacing.md),
              ElevatedButton.icon(
                onPressed: controller.pickImage,
                icon: Icon(
                  kIsWeb
                      ? Icons.photo_library_outlined
                      : Icons.photo_camera_outlined,
                ),
                label: Text(kIsWeb ? 'Escolher foto' : 'Tirar foto'),
              ),
            ],
          ),
        );
      case 2:
        return _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Obx(
                () => Text(
                  'Cashback disponível: R\$ ${controller.usedCashback.value.toStringAsFixed(2).replaceAll('.', ',')}',
                  style: TextStyle(
                    color: primaryThemeColor.shade800,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              const Text(
                'Se quiser, use parte do saldo nesta compra. Ao utilizar cashback, esta compra não gera novos ganhos.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: controller.utilizaValorController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Valor a utilizar (opcional)',
                  prefixText: 'R\$ ',
                ),
                onChanged: controller.onUtilizaValorChanged,
              ),
            ],
          ),
        );
      case 3:
      default:
        return const _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Confirmar envio',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: AppSpacing.sm),
              Text(
                'Sua compra será analisada pelo lojista. Assim que for confirmada, você receberá uma notificação no app informando a aprovação.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  height: 1.45,
                ),
              ),
            ],
          ),
        );
    }
  }

  void _onStepContinue() {
    if (controller.currentStep.value == 0) {
      controller.onValorCompraChanged('');
      if (controller.valorCompra.value <= 0) {
        Get.snackbar('Erro', 'Insira um valor válido para continuar.');
        return;
      }
    } else if (controller.currentStep.value == 1) {
      if (controller.imageBytes.value == null) {
        Get.snackbar('Erro', 'Selecione uma foto do comprovante.');
        return;
      }
    }

    if (controller.currentStep.value == 3) {
      controller.isLoading.value = true;
      controller.saveCashBack().then((_) {
        Get.offAllNamed(AppRoutes.HOME);
      }).catchError((Object error) {
        controller.isLoading.value = false;
        Get.snackbar('Erro', 'Não foi possível finalizar a compra.');
      });
    } else {
      controller.nextStep();
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
      width: double.infinity,
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
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            titles[currentStep],
            style: TextStyle(
              color: primaryThemeColor.shade800,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: LinearProgressIndicator(
              value: (currentStep + 1) / titles.length,
              minHeight: 4,
              backgroundColor: AppColors.divider,
              color: primaryThemeColor,
            ),
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
    required this.onBack,
    required this.onContinue,
  });

  final int currentStep;
  final int lastStep;
  final VoidCallback onBack;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.divider)),
        ),
        child: Row(
          children: [
            if (currentStep > 0)
              Expanded(
                child: OutlinedButton(
                  onPressed: onBack,
                  child: const Text('Voltar'),
                ),
              ),
            if (currentStep > 0) const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: ElevatedButton(
                onPressed: onContinue,
                child: Text(currentStep == lastStep ? 'Finalizar' : 'Continuar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _LoadingOverlay extends StatelessWidget {
  const _LoadingOverlay();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.45),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: primaryThemeColor),
            const SizedBox(height: AppSpacing.md),
            const Text(
              'Finalizando a sua compra...',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
