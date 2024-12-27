import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mobile/controllers/AuthController.dart';
import 'package:mobile/controllers/MapsAvalibleController.dart';
import 'package:mobile/modules/estabelecimentos/estabelecimentos_page.dart';
import 'package:mobile/modules/login/login_page.dart';
import 'package:mobile/routes/app_pages.dart';
import 'package:mobile/ui/theme/colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarIconBrightness: Brightness.dark),
  );
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyBAUhPkB1OLsgDEh7857KPheJ3r5FxmN6I",
      authDomain: "temcashback-914bc.firebaseapp.com",
      projectId: "temcashback-914bc",
      storageBucket: "temcashback-914bc.firebasestorage.app",
      messagingSenderId: "941351203236",
      appId: "1:941351203236:web:77e84c5009a095dc9e5131",
      measurementId: "G-L29TEDX8QD",
    ),
  );
  Get.put(AuthController());
  Get.put(MapsAvalibleController());
  runApp(GuiaClube());
}

class GuiaClube extends StatelessWidget {
  const GuiaClube({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Guilheiros',
      theme: ThemeData(
        primarySwatch: defaultTheme,
        secondaryHeaderColor: defaultTheme[900],
      ),
      getPages: AppPages.pages,
      home: AuthChecker(),
    );
  }
}

class AuthChecker extends StatelessWidget {
  AuthChecker({super.key});
  final AuthController authController = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return authController.user.value != null
          ? EstabelecimentosPage()
          : LoginPage();
    });
  }
}
