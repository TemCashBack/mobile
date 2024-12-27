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
                  flex: 4,
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(50.0),
                        child: Image.network(
                          authController.user.value!.photoURL ?? '',
                          height: 80.0,
                          width: 80.0,
                        ),
                      )
                    ],
                  ),
                ),
                Expanded(
                  flex: 10,
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
          //  ListTile(
          //   leading: FaIcon(FontAwesomeIcons.building, color: Colors.black),
          //   title: const Text('Add Company'),
          //   onTap: () {
          //     this.companiesRepository.createCompany();
          //   },
          // ),
          ListTile(
            leading: FaIcon(FontAwesomeIcons.building, color: Colors.black),
            title: const Text('Clubeiros'),
            onTap: () {
              Get.offAndToNamed(AppRoutes.ESTABELECIMENTOS);
            },
          ),
          ListTile(
            leading: FaIcon(FontAwesomeIcons.solidFilePdf, color: Colors.black),
            title: Text('Termos de Uso e Privacidade'),
            onTap: () async {
              // // ignore: deprecated_member_use
              // launch(
              //     'http://app.guiaclube.com.br/termos%20de%20privacidade.pdf');
            },
          ),
          ListTile(
            leading: FaIcon(FontAwesomeIcons.doorOpen, color: Colors.black),
            title: Text('Sair'),
            onTap: () async {
              await authController.signOut();
            },
          ),
        ],
      ),
    );
  }
}
