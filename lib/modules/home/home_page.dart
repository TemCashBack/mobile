import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_in_app_messaging/firebase_in_app_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mobile/controllers/firebase_in_app_message_controller.dart';
import 'package:mobile/controllers/nivel_controller.dart';
import 'package:mobile/data/models/checkin_model.dart';
import 'package:mobile/data/models/company_model.dart';
import 'package:mobile/data/repositories/checkin_repository.dart';
import 'package:mobile/routes/app_routes.dart';
import 'package:mobile/ui/theme/colors.dart';
import 'package:mobile/ui/widgets/drawer_custom.dart';

// ignore: must_be_immutable
class HomePage extends StatelessWidget {
  HomePage({super.key});

  late FirebaseInAppMessaging fiam;
  final checkInRepository = CheckinRepository();
  final NivelController nivelController = NivelController();
  final FirebaseInAppMessageController _fiamController =
      Get.find<FirebaseInAppMessageController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(),
      appBar: AppBar(
        title: Text('Tem Cashback'),
        backgroundColor: primaryThemeColor,
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
        iconTheme: IconThemeData(
          color: Colors.white, // Cor do ícone do Drawer
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(20),
            width: double.infinity,
            color: primaryThemeColor,
            height: 140,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Nível',
                          style: TextStyle(fontSize: 12, color: iconColorTheme),
                        ),
                        SizedBox(
                          height: 0,
                        ),
                        Text(
                          nivelController.nivel.toString(),
                          style: TextStyle(fontSize: 12, color: Colors.white),
                        ),
                      ],
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Qtd. de Check-ins',
                          style: TextStyle(fontSize: 12, color: iconColorTheme),
                        ),
                        SizedBox(
                          height: 0,
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.place,
                              size: 10,
                            ),
                            const SizedBox(width: 3),
                            StreamBuilder<QuerySnapshot>(
                              stream: checkInRepository.getCheckInLength(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: CircularProgressIndicator(),
                                    ),
                                  );
                                } else {
                                  return Text(
                                    snapshot.data!.docs.length.toString(),
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.white),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextButton.icon(
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: iconColorTheme,
                          ),
                          onPressed: () {
                            Get.toNamed(AppRoutes.ESTABELECIMENTOS);
                          },
                          icon: const Icon(
                            Icons.business,
                            color: Colors.white,
                          ),
                          label: const Text('Conheça Nossos Parceiros'),
                        ),
                      ],
                    ),
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: iconColorTheme,
                      ),
                      onPressed: () async {
                        _fiamController.triggerTestEvent();
                      },
                      icon: const Icon(
                        Icons.message,
                        color: Colors.white,
                      ),
                      label: const Text('Messaging'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Divider(
            color: Colors.grey[200],
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: Text(
              'Últimos 10 check-ins',
              style: TextStyle(fontSize: 12, color: primaryThemeColor),
            ),
          ),
          Divider(
            color: Colors.grey[200],
          ),
          Expanded(
            flex: 11,
            child: SingleChildScrollView(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: checkInRepository.getLast10Checkins(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: CircularProgressIndicator(),
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
                          Map<String, dynamic> jsonCheckIn = item['checkin'];
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
                          String checkInFormattedDate = DateFormat('dd/MM/yyyy')
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
    );
  }
}
