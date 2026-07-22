import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get/get.dart';

class FirebaseMessagingController extends GetxController {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  @override
  void onInit() {
    super.onInit();
    _initNotifications();
  }

  Future<String?> getToken() async {
    if (kIsWeb) {
      try {
        return await messaging.getToken();
      } catch (_) {
        return null;
      }
    }
    return messaging.getToken();
  }

  Future<void> _initNotifications() async {
    try {
      if (!kIsWeb) {
        await messaging.subscribeToTopic('todos');
        FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);
      }

      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized &&
          !kIsWeb) {
        // Log removido — evita avoid_print no web durante dev
      }

      await getToken();

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        final title = message.notification?.title;
        final body = message.notification?.body;
        if (title != null || body != null) {
          Get.snackbar(title ?? 'Notificação', body ?? '');
        }
      });
    } catch (_) {
      // FCM web pode falhar em localhost sem VAPID ou permissão negada.
    }
  }
}

Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {}
