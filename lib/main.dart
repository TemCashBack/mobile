import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mobile/controllers/customer_controller.dart';
import 'package:mobile/controllers/firebase_in_app_message_controller.dart';
import 'package:mobile/controllers/firebase_message_controller.dart';
import 'package:mobile/initial_binding.dart';
import 'package:mobile/modules/splash_screen/splash_screen_page.dart';
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
        measurementId: "G-L29TEDX8QD"),
  );

  Get.put(FirebaseMessagingController());
  Get.put(FirebaseInAppMessagingController());
  Get.put(CustomerController());
  //Get.put(RemoteConfigController());

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]).then((_) {
    runApp(MainWidget());
  });
}

class MainWidget extends StatelessWidget {
  const MainWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Tem Cashback',
      theme: ThemeData(
          primarySwatch: primaryThemeColor,
          secondaryHeaderColor: secondaryThemeColor,
          textTheme: TextTheme(
            bodySmall: TextStyle(fontSize: 12),
            bodyMedium: TextStyle(fontSize: 12),
            bodyLarge: TextStyle(fontSize: 12),
          ),
          iconTheme: IconThemeData(color: iconColorTheme)),
      getPages: AppPages.pages,
      home: SplashScreenPage(),
      initialBinding: InitialBinding(),
    );
  }
}
