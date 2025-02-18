import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';

class FirebaseMessageController extends GetxController {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  @override
  void onInit() {
    super.onInit();
    _initializeFCM();
  }

  Future<void> _initializeFCM() async {
    // Solicita permissão para notificações
    await _messaging.requestPermission();

    // Obtém o token do dispositivo
    String? token = await _messaging.getToken();
    print("Token FCM: $token");

    // Configura listeners para mensagens recebidas
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Mensagem recebida: ${message.notification?.title}');
      Get.snackbar(
        message.notification?.title ?? "Notificação",
        message.notification?.body ?? "Sem conteúdo",
        snackPosition: SnackPosition.BOTTOM,
      );
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Usuário clicou na notificação: ${message.notification?.title}');
    });
  }
}
