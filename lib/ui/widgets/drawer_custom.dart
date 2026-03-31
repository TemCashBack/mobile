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
    final customer = authController.customerData.value;
    final String displayName = (customer?.nomeCompleto != null &&
            customer!.nomeCompleto!.trim().isNotEmpty)
        ? customer.nomeCompleto!.trim()
        : '<-- nome de exibição -->';
    final String? photoUrl = customer?.photoURL;
    final bool hasPhoto = photoUrl != null && photoUrl.trim().isNotEmpty;
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
              decoration: BoxDecoration(color: Colors.black),
              child: Stack(
                children: [
                  Positioned(
                    top: 40,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(50.0),
                      child: hasPhoto
                          ? Image.network(
                              photoUrl,
                              height: 50.0,
                              width: 50.0,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Image.asset(
                                'lib/ui/assets/logo-round.png',
                                height: 50.0,
                                width: 50.0,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Image.asset(
                              'lib/ui/assets/logo-round.png',
                              height: 50.0,
                              width: 50.0,
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                  Positioned(
                    top: 50,
                    left: 110,
                    right: 0,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                      child: Text(
                        displayName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.left,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  )
                ],
              )),
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
