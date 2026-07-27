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
    return null;
  }
}
