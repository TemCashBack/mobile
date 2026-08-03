import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart';

/// Ativa App Check. Em debug usa providers de debug; em release usa Play/App Attest.
/// Web fica desativado até configurar o site key do reCAPTCHA no Console.
class FirebaseAppCheckBootstrap {
  static Future<void> activate() async {
    if (kIsWeb) return;

    try {
      await FirebaseAppCheck.instance.activate(
        androidProvider: kDebugMode
            ? AndroidProvider.debug
            : AndroidProvider.playIntegrity,
        appleProvider:
            kDebugMode ? AppleProvider.debug : AppleProvider.appAttest,
      );
    } catch (_) {
      // App Check indisponível em alguns ambientes de debug — não bloqueia o app.
    }
  }
}
