import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
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
              Obx(() => Text(
                'O valor máximo por compra nesta loja é R\$ ${controller.limiteCompra.value.toStringAsFixed(2).replaceAll('.', ',')}.',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
              )),
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
              if (kIsWeb)
                ElevatedButton.icon(
                  onPressed: () => controller.pickImage(
                    preferred: ImageSource.gallery,
                  ),
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('Escolher foto'),
                )
              else ...[
                ElevatedButton.icon(
                  onPressed: () => controller.pickImage(
                    preferred: ImageSource.camera,
                  ),
                  icon: const Icon(Icons.photo_camera_outlined),
                  label: const Text('Tirar foto'),
                ),
                const SizedBox(height: AppSpacing.sm),
                OutlinedButton.icon(
                  onPressed: () => controller.pickImage(
                    preferred: ImageSource.gallery,
                  ),
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('Escolher da galeria'),
                ),
              ],
            ],
          ),
        );
      case 2:
        return _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Usar cashback nesta compra',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              const Text(
                'O cashback só pode ser utilizado na loja onde foi gerado. O saldo tem validade de 40 dias. O uso não pode passar do valor da compra e, se houver uso, esta compra não gera novos ganhos.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Obx(() {
                if (controller.isLoadingBalance.value) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                // Lê obs para o Obx reagir a saldo e valor da compra.
                final maximo = controller.maximoUtilizavel;
                controller.valorCompra.value;
                controller.maximoSaldo.value;

                return Column(
                  children: [
                    _BalanceInfoRow(
                      label: 'Saldo disponível nesta loja',
                      value: controller.saldoLoja.value,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _BalanceInfoRow(
                      label: 'Máximo nesta compra',
                      value: maximo,
                      emphasize: true,
                    ),
                  ],
                );
              }),
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
              Obx(() {
                if (controller.utilizaValor.value <= 0) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.sm),
                  child: Text(
                    'Esta compra não gerará cashback.',
                    style: TextStyle(
                      color: AppColors.error.withValues(alpha: 0.9),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      case 3:
        return _Card(
          child: Obx(() {
            final using = controller.utilizaValor.value > 0;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Confirmar envio',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  using
                      ? 'Você está utilizando R\$ ${controller.utilizaValor.value.toStringAsFixed(2).replaceAll('.', ',')} de cashback nesta loja (reserva pendente de aprovação). Esta compra não gerará novos cashbacks.'
                      : 'Sua compra será analisada pelo lojista. Após a aprovação, você receberá ${controller.cashbackPercentual.value.toStringAsFixed(0)}% de cashback (válido por 40 dias) e uma notificação no app.',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    height: 1.45,
                  ),
                ),
              ],
            );
          }),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Future<void> _onStepContinue() async {
    if (controller.currentStep.value == 0) {
      controller.onValorCompraChanged('');
      if (controller.valorCompra.value <= 0) {
        _showError('Insira um valor válido para continuar.');
        return;
      }
    } else if (controller.currentStep.value == 1) {
      if (controller.imageBytes.value == null) {
        _showError('Selecione uma foto do comprovante.');
        return;
      }
    }

    if (controller.currentStep.value == 3) {
      if (controller.isLoading.value) return;
      controller.isLoading.value = true;
      try {
        await controller.saveCashBack();
        Get.offAllNamed(AppRoutes.HOME);
      } catch (error) {
        debugPrint('Erro ao finalizar cashback: $error');
        _showError('Não foi possível finalizar a compra. Tente novamente.');
      } finally {
        if (Get.isRegistered<CashbackController>()) {
          controller.isLoading.value = false;
        }
      }
    } else {
      controller.nextStep();
    }
  }

  void _showError(String message) {
    final context = Get.context;
    if (context != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
      return;
    }
    Get.snackbar('Erro', message);
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

class _BalanceInfoRow extends StatelessWidget {
  const _BalanceInfoRow({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  final String label;
  final double value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final formatted =
        'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: emphasize
            ? primaryThemeColor.withValues(alpha: 0.08)
            : AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: emphasize
              ? primaryThemeColor.withValues(alpha: 0.25)
              : AppColors.divider,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: emphasize
                    ? primaryThemeColor.shade800
                    : AppColors.textSecondary,
                fontSize: 13,
                fontWeight: emphasize ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
          Text(
            formatted,
            style: TextStyle(
              color: emphasize
                  ? primaryThemeColor.shade800
                  : AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
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
