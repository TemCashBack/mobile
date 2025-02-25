import 'package:firebase_in_app_messaging/firebase_in_app_messaging.dart';
import 'package:get/get.dart';

class FirebaseInAppMessagingController extends GetxController {
  FirebaseInAppMessaging fiam = FirebaseInAppMessaging.instance;

  @override
  void onInit() {
    super.onInit();
    _initInAppMessaging();
  }

  void _initInAppMessaging() {
    fiam.setMessagesSuppressed(false);
    fiam.triggerEvent("app_open");
  }
}
