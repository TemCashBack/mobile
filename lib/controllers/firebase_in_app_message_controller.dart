import 'package:firebase_in_app_messaging/firebase_in_app_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get/get.dart';

class FirebaseInAppMessagingController extends GetxController {
  FirebaseInAppMessaging fiam = FirebaseInAppMessaging.instance;

  @override
  void onInit() {
    super.onInit();
    _initInAppMessaging();
  }

  void _initInAppMessaging() {
    if (kIsWeb) return;

    try {
      fiam.setMessagesSuppressed(false);
      fiam.triggerEvent('app_open');
    } catch (_) {
      // In-app messaging não é suportado na web.
    }
  }
}
