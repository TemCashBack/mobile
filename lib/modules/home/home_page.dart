import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_in_app_messaging/firebase_in_app_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mobile/controllers/nivel_controller.dart';
import 'package:mobile/data/models/cashback_model.dart';
import 'package:mobile/data/models/company_model.dart';
import 'package:mobile/data/repositories/cashback_repository.dart';
import 'package:mobile/routes/app_routes.dart';
import 'package:mobile/ui/theme/colors.dart';
import 'package:mobile/ui/widgets/drawer_custom.dart';
import 'package:mobile/ui/widgets/progress_indicator_custom.dart';

// ignore: must_be_immutable
class HomePage extends StatelessWidget {
  HomePage({super.key});

  late FirebaseInAppMessaging fiam;
  final cashbackRepository = CashbackRepository();
  final NivelController nivelController = NivelController();

  final MoneyMaskedTextController moneyController = MoneyMaskedTextController(
    leftSymbol: 'R\$ ',
    decimalSeparator: ',',
    thousandSeparator: '.',
    precision: 2,
  );
  final MoneyMaskedTextController moneyController2 = MoneyMaskedTextController(
    decimalSeparator: ',',
    thousandSeparator: '.',
    precision: 2,
  );

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
              icon: Icon(Icons.menu), // Ícone de notificações
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
          )
        ],
        backgroundColor: Colors.black,
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
        iconTheme: IconThemeData(
          color: Colors.white, // Cor do ícone do Drawer
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Get.offAndToNamed(AppRoutes.ESTABELECIMENTOS);
        },
        backgroundColor: secondaryThemeColor,
        label: Text(
          'Informar compras',
          style: TextStyle(color: Colors.black),
        ),
        icon: Icon(
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
                        padding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                        decoration: BoxDecoration(
                          color: secondaryThemeColor, // Cor de fundo
                          borderRadius: BorderRadius.circular(
                              20), // Define o raio da borda
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Cashback',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                StreamBuilder<double>(
                                  stream: cashbackRepository
                                      .getRealTimeCashbackBalance(),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return Center(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8),
                                          child: ProgressIndicatorCustom(),
                                        ),
                                      );
                                    } else {
                                      moneyController2
                                          .updateValue(snapshot.data ?? 0);
                                      var totalCashback = moneyController2.text;
                                      return Expanded(
                                        child: RichText(
                                          text: TextSpan(
                                            children: [
                                              TextSpan(
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
                                                          Rect.fromLTWH(
                                                              50, 0, 400, 50)),
                                                    fontSize: 30,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                            StreamBuilder<double>(
                              stream: cashbackRepository
                                  .getRealTimeCashbackBalanceUsed(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: ProgressIndicatorCustom(),
                                    ),
                                  );
                                } else {
                                  moneyController2
                                      .updateValue(snapshot.data ?? 0);
                                  var totalCashbackUsed = moneyController2.text;
                                  return RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                            text: 'Utilizado: ',
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 10)),
                                        TextSpan(
                                          text: 'R\$ ',
                                        ),
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
                                                ).createShader(Rect.fromLTWH(
                                                    50, 0, 400, 50)),
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              },
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 40),
              Container(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Text(
                  'Extrato',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              Divider(
                color: Colors.grey, // Cor da linha
                thickness: 0.5,
                indent: 20,
                endIndent: 20,
              ),
              Container(
                padding: EdgeInsets.fromLTRB(20, 5, 20, 0),
                child: SingleChildScrollView(
                  child: StreamBuilder<List<Map<String, dynamic>>>(
                    stream: cashbackRepository.getLast10Document(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: ProgressIndicatorCustom(),
                          ),
                        );
                      } else {
                        if (snapshot.hasData) {
                          final joinedData = snapshot.data!;
                          final jsonData = joinedData.map((data) {
                            return {
                              ...data,
                              'cashback': data['cashback'],
                              'company': data['company'],
                            };
                          }).toList();
                          if (jsonData.isEmpty) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: Text('Nada encontrado!'),
                              ),
                            );
                          }
                          return ListView.builder(
                            itemCount: joinedData.length * 2 - 1,
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemBuilder: (BuildContext context, int index) {
                              if (index.isOdd) {
                                return Divider();
                              } else {
                                int itemIndex = index ~/ 2;
                                final item = jsonData[itemIndex];
                                Map<String, dynamic> jsonCashback =
                                    item['cashback'];
                                String jsonCompany =
                                    jsonEncode(item['company']);
                                Map<String, dynamic> cashbackDocMap =
                                    jsonCashback;
                                Map<String, dynamic> companyDocMap =
                                    jsonDecode(jsonCompany);
                                final cashbackModel =
                                    CashbackModel.fromJson(cashbackDocMap);
                                final companyModel =
                                    CompanyModel.fromJson(companyDocMap);
                                // DateTime cashbackParsedDate =
                                //     DateTime.parse(cashbackModel.date);
                                // String cashbackFormattedDate =
                                //     DateFormat('dd/MM/yyyy')
                                //         .format(cashbackParsedDate);
                                String cashbackFormattedDateHour =
                                    converTimeStamp(cashbackModel.dateTime);
                                moneyController
                                    .updateValue(cashbackModel.valor);
                                var valor = moneyController.text;
                                moneyController
                                    .updateValue(cashbackModel.cashback);
                                var cashback = moneyController.text;
                                return ListTile(
                                  isThreeLine: true,
                                  contentPadding:
                                      EdgeInsets.fromLTRB(20, 0, 0, 0),
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
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 12),
                                        ),
                                        if (cashbackModel.aprovado)
                                          TextSpan(
                                            text: '\n\nAprovado',
                                            style: TextStyle(
                                                color: primaryThemeColor,
                                                fontSize: 12),
                                          )
                                        else
                                          TextSpan(
                                            text: '\n\nNão aprovado',
                                            style: TextStyle(
                                                color: Colors.red,
                                                fontSize: 12),
                                          ),
                                      ],
                                    ),
                                  ),
                                  title: Text(
                                    companyModel.nomeFantasia,
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  subtitle: Text(
                                    'Valor: $valor\nCashback: $cashback',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  onTap: () {},
                                );
                              }
                            },
                          );
                        } else {
                          return Text('Nada encontrado!');
                        }
                      }
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

  converTimeStamp(Timestamp timeStamp) {
    Timestamp timestamp = timeStamp;
    DateTime dateTime = timestamp.toDate();
    String formattedDate = DateFormat('dd/MM/yyyy HH:mm:ss').format(dateTime);
    return formattedDate;
  }
}
