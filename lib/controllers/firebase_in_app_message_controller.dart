import 'package:get/get.dart';
import 'package:firebase_in_app_messaging/firebase_in_app_messaging.dart';

class FirebaseInAppMessageController extends GetxController {
  final FirebaseInAppMessaging fiam = FirebaseInAppMessaging.instance;

  @override
  void onInit() {
    super.onInit();
    fiam.setMessagesSuppressed(false);
    fiam.setAutomaticDataCollectionEnabled(true);
  }

  void triggerTestEvent() async {
    fiam.triggerEvent("evento_teste").then(
      (value) {
        print('Evento de trigger disparado: evento_teste');
      },
    ).catchError((error) {
      print('Erro: $error');
    });
  }
}
