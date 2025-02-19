import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/modules/login/login_controller.dart';
import 'package:mobile/routes/app_routes.dart';
import 'package:mobile/ui/theme/colors.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final LoginController loginController = Get.put(LoginController());

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(40),
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
              SizedBox(
                height: 20,
              ),
              TextField(
                cursorColor: Colors.grey,
                controller: emailController,
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
                  border: OutlineInputBorder(),
                ),
                style: TextStyle(color: Colors.grey[700]),
              ),
              SizedBox(
                height: 20,
              ),
              Obx(
                () => TextField(
                  cursorColor: Colors.grey,
                  obscureText: !loginController.isPasswordVisible.value,
                  controller: passwordController,
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
                        loginController.isPasswordVisible.value
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: primaryThemeColor,
                      ),
                      onPressed: loginController.togglePasswordVisibility,
                    ),
                    border: OutlineInputBorder(),
                  ),
                  style:
                      TextStyle(color: const Color.fromARGB(255, 43, 43, 43)),
                ),
              ),
              SizedBox(height: 20),
              Obx(() {
                if (loginController.isLoading.value) {
                  return CircularProgressIndicator();
                } else {
                  return ElevatedButton(
                    onPressed: () {
                      final email = emailController.text.trim();
                      final password = passwordController.text.trim();
                      loginController.loginWithEmail(email, password);
                    },
                    child: Text(
                      'ENTRAR',
                      style: TextStyle(color: primaryThemeColor, fontSize: 16),
                    ),
                  );
                }
              }),
              SizedBox(height: 0),
              TextButton(
                onPressed: () {
                  Get.toNamed(
                      AppRoutes.REGISTRO); // Navegar para a tela de registro
                },
                child: Text('Criar uma conta',
                    style: TextStyle(color: secondaryThemeColor)),
              ),
            ],
          ),
        ),
      ),
      // body: Padding(
      //   padding: const EdgeInsets.all(16.0),
      //   child: Column(
      //     mainAxisAlignment: MainAxisAlignment.center,
      //     children: [
      //       TextField(
      //         controller: emailController,
      //         decoration: InputDecoration(labelText: 'Email'),
      //         keyboardType: TextInputType.emailAddress,
      //       ),
      //       SizedBox(height: 16),
      //       TextField(
      //         controller: passwordController,
      //         decoration: InputDecoration(labelText: 'Senha'),
      //         obscureText: true,
      //       ),
      //       SizedBox(height: 16),
      //       Obx(() {
      //         if (controller.isLoading.value) {
      //           return CircularProgressIndicator();
      //         } else {
      //           return ElevatedButton(
      //             onPressed: () {
      //               final email = emailController.text.trim();
      //               final password = passwordController.text.trim();
      //               controller.loginWithEmail(email, password);
      //             },
      //             child: Text('Entrar'),
      //           );
      //         }
      //       }),
      //       SizedBox(height: 16),
      //       TextButton(
      //         onPressed: () {
      //           Get.toNamed('/register'); // Navegar para a tela de registro
      //         },
      //         child: Text('Criar uma conta'),
      //       ),
      //     ],
      //   ),
      // ),
    );
  }
}
