import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/modules/login/login_controller.dart';
import 'package:mobile/routes/app_routes.dart';
import 'package:mobile/ui/theme/colors.dart';
import 'package:mobile/ui/widgets/progress_indicator_custom.dart';

class LoginPage extends GetView<LoginController> {
  LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(40),
          color: Colors.black,
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'lib/ui/assets/logo.png',
                width: MediaQuery.of(context).size.width * 0.6,
              ),
              const SizedBox(height: 20),
              TextField(
                cursorColor: Colors.grey,
                controller: controller.emailController,
                decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: primaryThemeColor, width: 1),
                  ),
                  labelStyle: TextStyle(color: secondaryThemeColor),
                  labelText: 'E-mail',
                  prefixIcon: Icon(
                    Icons.email,
                    color: primaryThemeColor,
                  ),
                  border: const OutlineInputBorder(),
                ),
                style: TextStyle(color: Colors.grey[700]),
              ),
              const SizedBox(height: 20),
              Obx(
                () => TextField(
                  cursorColor: Colors.grey,
                  obscureText: !controller.isPasswordVisible.value,
                  controller: controller.passwordController,
                  decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: primaryThemeColor, width: 1),
                    ),
                    labelStyle: TextStyle(color: secondaryThemeColor),
                    labelText: 'Senha',
                    prefixIcon: Icon(
                      Icons.password,
                      color: primaryThemeColor,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.isPasswordVisible.value
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: primaryThemeColor,
                      ),
                      onPressed: controller.togglePasswordVisibility,
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  style: const TextStyle(
                      color: Color.fromARGB(255, 43, 43, 43)),
                ),
              ),
              const SizedBox(height: 20),
              Obx(() {
                if (controller.isLoading.value) {
                  return const ProgressIndicatorCustom();
                }

                return ElevatedButton(
                  onPressed: () {
                    controller.loginWithEmail(
                      controller.emailController.text.trim(),
                      controller.passwordController.text.trim(),
                    );
                  },
                  child: Text(
                    'ENTRAR',
                    style: TextStyle(color: primaryThemeColor, fontSize: 16),
                  ),
                );
              }),
              TextButton(
                onPressed: () => Get.toNamed(AppRoutes.REGISTRO),
                child: Text(
                  'Criar uma conta',
                  style: TextStyle(color: secondaryThemeColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
