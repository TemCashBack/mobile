import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/controllers/AuthController.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});
  final AuthController authController = Get.put(AuthController());

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
                Text(
                  'entrar com',
                  style: TextStyle(fontSize: 14),
                ),
                SizedBox(
                  height: 12,
                ),
                ElevatedButton(
                  onPressed: () => AuthController.instance.signInWithGoogle(),
                  child: Text('Entrar com Google'),
                ),
                SizedBox(
                  height: 100,
                ),
                // LogoutButton(onPressed: () async => await Authentication.signOut(context: context)),
                // SizedBox(
                //   height: 100,
                // ),
              ],
            ),
          ),
          Positioned(
            width: MediaQuery.of(context).size.width,
            bottom: MediaQuery.of(context).size.height * 0.25,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Ao entrar, estará de acordo com nosso termo de uso e privacidade.',
                      textAlign: TextAlign.center,
                    ),
                    // LinkButton(
                    //     label: 'Termos de Uso e Privacidade',
                    //     onPressed: () => launchUrl(Uri.http(
                    //         'http://app.guiaclube.com.br/termos%20de%20privacidade.pdf'))),
                  ],
                ))
              ],
            ),
          ),
        ],
      ),
    );
    // return Scaffold(
    //   body: Center(
    //     child: Column(
    //       mainAxisAlignment: MainAxisAlignment.center,
    //       children: [
    //         Text(
    //           'Login com Google',
    //           style: TextStyle(fontSize: 24),
    //         ),
    //         SizedBox(height: 20),
    //         ElevatedButton(
    //           onPressed: () => AuthController.instance.signInWithGoogle(),
    //           child: Text('Entrar com Google'),
    //         ),
    //       ],
    //     ),
    //   ),
    // );
  }
}
