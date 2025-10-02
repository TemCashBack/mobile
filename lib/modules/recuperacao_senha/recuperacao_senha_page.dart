import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/modules/recuperacao_senha/recuperacao_senha_controller.dart';
import 'package:mobile/ui/theme/colors.dart';
import 'package:mobile/ui/widgets/progress_indicator_custom.dart';

class RecuperacaoSenhaPage extends StatelessWidget {
  RecuperacaoSenhaPage({super.key});

  final RecuperacaoSenhaController controller =
      Get.find<RecuperacaoSenhaController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primaryThemeColor),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Recuperar Senha',
          style: TextStyle(color: primaryThemeColor),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(40),
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height - kToolbarHeight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_reset,
                size: 80,
                color: primaryThemeColor,
              ),
              SizedBox(height: 30),
              Text(
                'Esqueceu sua senha?',
                style: TextStyle(
                  color: primaryThemeColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Obx(() => !controller.emailSent.value
                  ? Column(
                      children: [
                        Text(
                          'Digite seu e-mail abaixo e enviaremos instruções para redefinir sua senha.',
                          style: TextStyle(
                            color: secondaryThemeColor,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 30),
                        TextField(
                          controller: controller.emailController,
                          keyboardType: TextInputType.emailAddress,
                          cursorColor: Colors.grey,
                          decoration: InputDecoration(
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: primaryThemeColor, width: 1),
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
                        SizedBox(height: 30),
                        Obx(() {
                          if (controller.isLoading.value) {
                            return ProgressIndicatorCustom();
                          } else {
                            return SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: () {
                                  final email =
                                      controller.emailController.text.trim();
                                  controller.sendPasswordResetEmail(email);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryThemeColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  'ENVIAR E-MAIL',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          }
                        }),
                      ],
                    )
                  : Column(
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 60,
                          color: Colors.green,
                        ),
                        SizedBox(height: 20),
                        Text(
                          'E-mail enviado com sucesso!',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 15),
                        Text(
                          'Verifique sua caixa de entrada e siga as instruções para redefinir sua senha.',
                          style: TextStyle(
                            color: secondaryThemeColor,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Você será redirecionado automaticamente...',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    )),
              SizedBox(height: 30),
              TextButton(
                onPressed: () => Get.back(),
                child: Text(
                  'Voltar ao Login',
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
