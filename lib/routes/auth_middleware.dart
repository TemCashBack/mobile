import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/controllers/auth_controller.dart';
import 'package:mobile/routes/app_routes.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final auth = Get.find<AuthController>();
    if (auth.user.value == null) {
      return const RouteSettings(name: AppRoutes.BOASVINDAS);
    }

    // Exige selfie/perfil completo antes das rotas protegidas.
    if (route != AppRoutes.SELFIE) {
      final customer = auth.customerData.value;
      if (customer != null && !customer.hasPhoto) {
        return const RouteSettings(name: AppRoutes.SELFIE);
      }
    }

    return null;
  }
}
