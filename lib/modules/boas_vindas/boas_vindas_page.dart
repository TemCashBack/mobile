import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/routes/app_routes.dart';
import 'package:mobile/ui/widgets/buttons/LinkButton.dart';
import 'package:mobile/ui/widgets/buttons/LoginButton.dart';
import 'package:mobile/ui/widgets/buttons/RegisterButton.dart';
import 'package:url_launcher/url_launcher.dart';

class BoasVindasPage extends StatelessWidget {
  const BoasVindasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.all(50),
                  child: Image.asset('lib/ui/assets/logo.png'),
                ),
                SizedBox(
                  height: 30,
                ),
                SizedBox(
                  height: 12,
                ),
                LoginButton(
                    onPressed: () => Get.offAndToNamed(AppRoutes.LOGIN)),
                SizedBox(
                  height: 15,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: Colors.grey, // Cor da linha
                          thickness: 0.2,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text(
                          "ou",
                          style:
                              TextStyle(color: Colors.grey), // Estilo do texto
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: Colors.grey,
                          thickness: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                RegisterButton(
                  onPressed: () => Get.toNamed(AppRoutes.REGISTRO),
                )
              ],
            ),
          ),
          Positioned(
            width: MediaQuery.of(context).size.width,
            bottom: MediaQuery.of(context).size.height * 0.05,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Ao entrar, estará de acordo com nosso termo de uso e privacidade.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ),
                    LinkButton(
                        label: 'Termos de Uso e Privacidade',
                        onPressed: () => launchUrl(Uri.http(''))),
                  ],
                ))
              ],
            ),
          ),
        ],
      ),
    );
  }
}
