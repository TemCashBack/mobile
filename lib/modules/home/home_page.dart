import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:mobile/data/models/cashback_model.dart';
import 'package:mobile/data/models/company_model.dart';
import 'package:mobile/modules/home/home_controller.dart';
import 'package:mobile/routes/app_routes.dart';
import 'package:mobile/ui/theme/app_styles.dart';
import 'package:mobile/ui/theme/colors.dart';
import 'package:mobile/ui/widgets/app_app_bar.dart';
import 'package:mobile/ui/widgets/app_cashback_card.dart';
import 'package:mobile/ui/widgets/app_section_title.dart';
import 'package:mobile/ui/widgets/drawer_custom.dart';
import 'package:mobile/ui/widgets/progress_indicator_custom.dart';

class HomePage extends GetView<HomeController> {
  HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(),
      appBar: AppLogoAppBar(actions: [AppLogoAppBar.menuButton(context)]),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.offAndToNamed(AppRoutes.ESTABELECIMENTOS),
        icon: FaIcon(FontAwesomeIcons.plus, color: primaryThemeColor, size: 16),
        label: const Text('Informar compras'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            color: AppColors.header,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: AppCashbackCard(
                balanceChild: StreamBuilder<double>(
                  stream: controller.cashbackBalanceStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: ProgressIndicatorCustom(),
                      );
                    }
                    final totalCashback =
                        controller.formatMaskedValue(snapshot.data ?? 0);
                    return RichText(
                      text: TextSpan(
                        style: const TextStyle(color: AppColors.textPrimary),
                        children: [
                          const TextSpan(
                            text: 'R\$ ',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextSpan(
                            text: totalCashback,
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              color: primaryThemeColor.shade800,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                usedChild: StreamBuilder<double>(
                  stream: controller.cashbackUsedStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox(
                        height: 16,
                        child: ProgressIndicatorCustom(),
                      );
                    }
                    final used =
                        controller.formatMaskedValue(snapshot.data ?? 0);
                    return Text(
                      'Utilizado: R\$ $used',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textPrimary.withValues(alpha: 0.7),
                            fontWeight: FontWeight.w500,
                          ),
                    );
                  },
                ),
              ),
            ),
          ),
          const AppSectionTitle(title: 'Extrato'),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: controller.extratoStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: ProgressIndicatorCustom());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const AppEmptyState(message: 'Nenhuma movimentação ainda.');
                }

                final joinedData = snapshot.data!;
                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 88),
                  itemCount: joinedData.length,
                  itemBuilder: (context, index) {
                    final item = joinedData[index];
                    final cashbackModel = CashbackModel.fromJson(
                      item['cashback'] as Map<String, dynamic>,
                    );
                    final companyModel = CompanyModel.fromJson(
                      controller.parseCompanyMap(item['company']),
                    );
                    final date =
                        controller.formatTimestamp(cashbackModel.dateTime);
                    final valor =
                        controller.formatTransactionValue(cashbackModel.valor);
                    final cashback = controller
                        .formatTransactionValue(cashbackModel.cashback);

                    return Card(
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: CircleAvatar(
                          backgroundColor:
                              primaryThemeColor.withValues(alpha: 0.1),
                          child: Icon(
                            Icons.shopping_bag_outlined,
                            color: primaryThemeColor.shade700,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          companyModel.nomeFantasia,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Valor: $valor  •  Cashback: $cashback'),
                              const SizedBox(height: 4),
                              Text(
                                date,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        trailing: AppStatusChip(
                          label: cashbackModel.aprovado
                              ? 'Aprovado'
                              : 'Pendente',
                          approved: cashbackModel.aprovado,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
