import 'dart:convert';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_in_app_messaging/firebase_in_app_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mobile/controllers/nivel_controller.dart';
import 'package:mobile/data/models/checkin_model.dart';
import 'package:mobile/data/models/company_model.dart';
import 'package:mobile/data/repositories/checkin_repository.dart';
import 'package:mobile/routes/app_routes.dart';
import 'package:mobile/ui/theme/colors.dart';
import 'package:mobile/ui/widgets/drawer_custom.dart';
import 'package:mobile/ui/widgets/progress_indicator_custom.dart';

// ignore: must_be_immutable
class HomePage extends StatelessWidget {
  HomePage({super.key});

  late FirebaseInAppMessaging fiam;
  final checkInRepository = CheckinRepository();
  final NivelController nivelController = NivelController();

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
        clipBehavior:
            Clip.none, // Permite elementos saírem dos limites do Stack
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
                      width: MediaQuery.of(context).size.width * 0.7,
                      height: 100,
                      child: Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: secondaryThemeColor, // Cor de fundo
                          borderRadius: BorderRadius.circular(
                              20), // Define o raio da borda
                        ),
                        child: Column(
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
                            SizedBox(
                              height: 2,
                            ),
                            Row(
                              children: [
                                Expanded(
                                    child: RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: 'R\$ ',
                                        style: TextStyle(fontSize: 18),
                                      ),
                                      TextSpan(
                                        text: "100.000.000,00",
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
                                            fontSize: 30,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                )),
                              ],
                            ),
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
                    stream: checkInRepository.getLast10Checkins(),
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
                              'checkin': data['checkin'],
                              'company': data['company'],
                            };
                          }).toList();
                          return ListView.builder(
                            itemCount: joinedData.length,
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemBuilder: (BuildContext context, int index) {
                              final item = jsonData[index];
                              Map<String, dynamic> jsonCheckIn =
                                  item['checkin'];
                              String jsonCompany = jsonEncode(item['company']);
                              Map<String, dynamic> checkinDocMap = jsonCheckIn;
                              Map<String, dynamic> companyDocMap =
                                  jsonDecode(jsonCompany);
                              final checkinModel =
                                  CheckinModel.fromJson(checkinDocMap);

                              final companyModel =
                                  CompanyModel.fromJson(companyDocMap);

                              DateTime checkInparsedDate =
                                  DateTime.parse(checkinModel.date);

                              // Formatando a data no formato dd/MM/yyyy
                              String checkInFormattedDate =
                                  DateFormat('dd/MM/yyyy')
                                      .format(checkInparsedDate);
                              return Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ListTile(
                                          contentPadding:
                                              EdgeInsets.fromLTRB(20, 0, 0, 0),
                                          leading: Icon(
                                            Icons.beenhere,
                                            color: iconColorTheme,
                                            size: 20,
                                          ),
                                          title: Text(
                                            companyModel.nomeFantasia,
                                            style: TextStyle(fontSize: 12),
                                          ),
                                          subtitle: Text(
                                            'check-in em $checkInFormattedDate',
                                            style: TextStyle(fontSize: 10),
                                          ),
                                          onTap: () {},
                                        ),
                                      ),
                                    ],
                                  ),
                                  Divider(
                                    color: Colors.grey[200],
                                  )
                                ],
                              );
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
}
