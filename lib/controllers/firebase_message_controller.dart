import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';

class FirebaseMessagingController extends GetxController {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  @override
  void onInit() {
    super.onInit();
    _initNotifications();
  }

  Future<String?> getToken() async {
    String? token = await messaging.getToken();
    return token;
  }

  void _initNotifications() async {
    await messaging.subscribeToTopic("todos");
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print("Permissão concedida para notificações!");
    }

    String? token = await messaging.getToken();
    print("FCM Token: $token");

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Nova notificação!");
      print("Título: ${message.notification?.title}");
      print("Mensagem: ${message.notification?.body}");
    });

    FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);
  }
}

// Handler para background notifications
Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
  print("Notificação recebida em background: ${message.notification?.title}");
}
