import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:mobile/controllers/AuthController.dart';
import 'package:mobile/routes/app_routes.dart';
import 'package:mobile/ui/theme/colors.dart';

class CustomDrawer extends StatelessWidget {
  CustomDrawer({super.key});
  final AuthController authController = Get.put(AuthController());
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: defaultTheme),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(50.0),
                        child: Image.network(
                          authController.user.value!.photoURL ?? '',
                          height: 65.0,
                          width: 65.0,
                        ),
                      )
                    ],
                  ),
                ),
                Expanded(
                  flex: 9,
                  child: Column(
                    children: [
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                        child: Text(
                          authController.user.value!.displayName ??
                              '<-- nome de exibição -->',
                          textAlign: TextAlign.left,
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                        child: Text(
                          authController.user.value!.email ??
                              '<-- e-mail não cadastrado -->',
                          textAlign: TextAlign.left,
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.apartment_sharp, color: Colors.black),
            title: const Text(
              'Empresas',
              style: TextStyle(fontSize: 12),
            ),
            onTap: () {
              Get.offAndToNamed(AppRoutes.ESTABELECIMENTOS);
            },
          ),
          ListTile(
            leading: Icon(Icons.picture_as_pdf_sharp, color: Colors.black),
            title: Text(
              'Termos de Uso e Privacidade',
              style: TextStyle(fontSize: 12),
            ),
            onTap: () async {
              // // ignore: deprecated_member_use
              // launch(
              //     'http://app.guiaclube.com.br/termos%20de%20privacidade.pdf');
            },
          ),
          ListTile(
            leading: Icon(Icons.exit_to_app_sharp, color: Colors.black),
            title: Text(
              'Sair',
              style: TextStyle(fontSize: 12),
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
