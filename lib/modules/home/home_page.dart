import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:mobile/data/models/cashback_model.dart';
import 'package:mobile/data/models/company_model.dart';
import 'package:mobile/modules/home/home_controller.dart';
import 'package:mobile/routes/app_routes.dart';
import 'package:mobile/ui/theme/colors.dart';
import 'package:mobile/ui/widgets/drawer_custom.dart';
import 'package:mobile/ui/widgets/progress_indicator_custom.dart';

class HomePage extends GetView<HomeController> {
  HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Image.asset(
              'lib/ui/assets/logo.png',
              height: 40,
            ),
          ],
        ),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          )
        ],
        backgroundColor: Colors.black,
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.offAndToNamed(AppRoutes.ESTABELECIMENTOS),
        backgroundColor: secondaryThemeColor,
        label: const Text(
          'Informar compras',
          style: TextStyle(color: Colors.black),
        ),
        icon: FaIcon(
          FontAwesomeIcons.plus,
          color: primaryThemeColor,
          size: 15,
        ),
      ),
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                color: Colors.black,
                height: 80,
                child: Stack(
                  alignment: AlignmentDirectional.bottomCenter,
                  fit: StackFit.loose,
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      bottom: -30,
                      left: 10,
                      width: MediaQuery.of(context).size.width * 0.6,
                      height: 100,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 20),
                        decoration: BoxDecoration(
                          color: secondaryThemeColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Cashback',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                StreamBuilder<double>(
                                  stream: controller.cashbackBalanceStream,
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const Expanded(
                                        child: Padding(
                                          padding: EdgeInsets.all(8),
                                          child: ProgressIndicatorCustom(),
                                        ),
                                      );
                                    }

                                    final totalCashback = controller
                                        .formatMaskedValue(snapshot.data ?? 0);
                                    return Expanded(
                                      child: RichText(
                                        text: TextSpan(
                                          children: [
                                            const TextSpan(
                                              text: 'R\$ ',
                                              style: TextStyle(fontSize: 18),
                                            ),
                                            TextSpan(
                                              text: totalCashback,
                                              style: TextStyle(
                                                foreground: Paint()
                                                  ..shader = LinearGradient(
                                                    colors: [
                                                      primaryThemeColor,
                                                      Colors.black,
                                                      primaryThemeColor,
                                                    ],
                                                  ).createShader(
                                                      const Rect.fromLTWH(
                                                          50, 0, 400, 50)),
                                                fontSize: 30,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                            StreamBuilder<double>(
                              stream: controller.cashbackUsedStream,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Padding(
                                    padding: EdgeInsets.all(8),
                                    child: ProgressIndicatorCustom(),
                                  );
                                }

                                final totalCashbackUsed = controller
                                    .formatMaskedValue(snapshot.data ?? 0);
                                return RichText(
                                  text: TextSpan(
                                    children: [
                                      const TextSpan(
                                        text: 'Utilizado: ',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 10,
                                        ),
                                      ),
                                      const TextSpan(text: 'R\$ '),
                                      TextSpan(
                                        text: totalCashbackUsed,
                                        style: TextStyle(
                                          foreground: Paint()
                                            ..shader = LinearGradient(
                                              colors: [
                                                primaryThemeColor,
                                                Colors.black,
                                                primaryThemeColor,
                                              ],
                                            ).createShader(const Rect.fromLTWH(
                                                50, 0, 400, 50)),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: const Text(
                  'Extrato',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const Divider(
                color: Colors.grey,
                thickness: 0.5,
                indent: 20,
                endIndent: 20,
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(20, 5, 20, 0),
                child: SingleChildScrollView(
                  child: StreamBuilder<List<Map<String, dynamic>>>(
                    stream: controller.extratoStream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(8),
                            child: ProgressIndicatorCustom(),
                          ),
                        );
                      }

                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(8),
                            child: Text('Nada encontrado!'),
                          ),
                        );
                      }

                      final joinedData = snapshot.data!;
                      return ListView.builder(
                        itemCount: joinedData.length * 2 - 1,
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          if (index.isOdd) {
                            return const Divider();
                          }

                          final item = joinedData[index ~/ 2];
                          final cashbackModel = CashbackModel.fromJson(
                            item['cashback'] as Map<String, dynamic>,
                          );
                          final companyModel = CompanyModel.fromJson(
                            controller.parseCompanyMap(item['company']),
                          );
                          final cashbackFormattedDateHour =
                              controller.formatTimestamp(cashbackModel.dateTime);
                          final valor =
                              controller.formatTransactionValue(cashbackModel.valor);
                          final cashback = controller
                              .formatTransactionValue(cashbackModel.cashback);

                          return ListTile(
                            isThreeLine: true,
                            contentPadding:
                                const EdgeInsets.fromLTRB(20, 0, 0, 0),
                            leading: Icon(
                              Icons.shopping_bag,
                              color: iconColorTheme,
                              size: 20,
                            ),
                            trailing: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: cashbackFormattedDateHour,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 12,
                                    ),
                                  ),
                                  TextSpan(
                                    text: cashbackModel.aprovado
                                        ? '\n\nAprovado'
                                        : '\n\nNão aprovado',
                                    style: TextStyle(
                                      color: cashbackModel.aprovado
                                          ? primaryThemeColor
                                          : Colors.red,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            title: Text(
                              companyModel.nomeFantasia,
                              style: const TextStyle(fontSize: 16),
                            ),
                            subtitle: Text(
                              'Valor: $valor\nCashback: $cashback',
                              style: const TextStyle(fontSize: 12),
                            ),
                            onTap: () {},
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
