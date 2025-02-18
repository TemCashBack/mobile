import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:mobile/controllers/auth_controller.dart';
import 'package:mobile/controllers/nivel_controller.dart';
import 'package:mobile/data/repositories/checkin_repository.dart';
import 'package:mobile/routes/app_routes.dart';
import 'package:mobile/ui/theme/colors.dart';

class CustomDrawer extends StatelessWidget {
  CustomDrawer({super.key});
  final NivelController nivelController = Get.put(NivelController());
  final CheckinRepository checkinRepository = CheckinRepository();
  final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: secondaryThemeColor),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 4,
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(50.0),
                            child:
                                (authController.customerData.value!.photoURL) !=
                                        null
                                    ? Image.network(
                                        authController
                                                .customerData.value!.photoURL ??
                                            '',
                                        height: 50.0,
                                        width: 50.0,
                                      )
                                    : Image.asset(
                                        'lib/ui/assets/logo-round.png',
                                        height: 40,
                                      ),
                          )
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 10,
                      child: Column(
                        children: [
                          Obx(
                            () {
                              return Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 5),
                                child: Text(
                                  authController
                                          .customerData.value!.nomeCompleto ??
                                      '<-- nome de exibição -->',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(color: Colors.white),
                                ),
                              );
                            },
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 5, vertical: 5),
                            child: Text(
                              authController.customerData.value!.email ??
                                  '<-- e-mail não cadastrado -->',
                              textAlign: TextAlign.left,
                              style:
                                  TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                  width: double.infinity,
                  height: 50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Column(
                      //   mainAxisAlignment: MainAxisAlignment.start,
                      //   crossAxisAlignment: CrossAxisAlignment.start,
                      //   children: [
                      //     Text(
                      //       'Qtd. de Check-ins',
                      //       style: TextStyle(
                      //           fontSize: 10, color: primaryThemeColor),
                      //     ),
                      //     SizedBox(
                      //       height: 0,
                      //     ),
                      //     Row(
                      //       mainAxisSize: MainAxisSize.min,
                      //       crossAxisAlignment: CrossAxisAlignment.center,
                      //       children: [
                      //         StreamBuilder<QuerySnapshot>(
                      //           stream: checkinRepository.getCheckInLength(),
                      //           builder: (context, snapshot) {
                      //             if (snapshot.connectionState ==
                      //                 ConnectionState.waiting) {
                      //               return Center(
                      //                 child: Padding(
                      //                   padding: const EdgeInsets.all(8),
                      //                   child: CircularProgressIndicator(),
                      //                 ),
                      //               );
                      //             } else {
                      //               return Text(
                      //                 snapshot.data!.docs.length.toString(),
                      //                 style: TextStyle(
                      //                     fontSize: 12, color: Colors.white),
                      //               );
                      //             }
                      //           },
                      //         ),
                      //       ],
                      //     ),
                      //   ],
                      // ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.fromLTRB(20, 0, 0, 0),
            leading: Icon(
              Icons.monetization_on_outlined,
              color: primaryThemeColor[700],
              size: 18,
            ),
            title: const Text(
              'Extrato',
            ),
            onTap: () {
              Get.offAndToNamed(AppRoutes.HOME);
            },
          ),
          ListTile(
            contentPadding: EdgeInsets.fromLTRB(20, 0, 0, 0),
            leading: FaIcon(
              FontAwesomeIcons.building,
              color: primaryThemeColor[700],
              size: 18,
            ),
            title: const Text(
              'Nossos Parceiros',
            ),
            onTap: () {
              Get.offAndToNamed(AppRoutes.ESTABELECIMENTOS);
            },
          ),
          ListTile(
            contentPadding: EdgeInsets.fromLTRB(20, 0, 0, 0),
            leading: FaIcon(
              FontAwesomeIcons.doorOpen,
              color: primaryThemeColor[700],
              size: 18,
            ),
            title: Text(
              'Sair',
            ),
            onTap: () async {
              await authController.signOut();
            },
          ),
        ],
      ),
    );
  }
}
