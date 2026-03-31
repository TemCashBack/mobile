import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/modules/selfie/selfie_controller.dart';
import 'package:mobile/ui/theme/colors.dart';
import 'package:mobile/ui/widgets/progress_indicator_custom.dart';

class SelfiePage extends GetView<SelfieController> {
  const SelfiePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Selfie'),
        backgroundColor: primaryThemeColor,
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
        iconTheme: IconThemeData(
          color: Colors.white, // Cor do ícone do Drawer
        ),
      ),
      body: Obx(
        () {
          // Se a permissão não foi concedida, mostra uma mensagem
          if (!controller.isPermissionGranted.value) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.camera_alt_outlined,
                    size: 80,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Permissão da Câmera Necessária',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Para tirar selfies, é necessário permitir o acesso à câmera.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 20),
                  if (controller.isRequestingPermission.value)
                    CircularProgressIndicator()
                  else
                    Column(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            controller.requestCameraPermission();
                          },
                          child: Text('Solicitar Permissão'),
                        ),
                        SizedBox(height: 10),
                        TextButton(
                          onPressed: () {
                            controller.testPermissionHandler();
                          },
                          child: Text('Testar Permission Handler'),
                        ),
                      ],
                    ),
                ],
              ),
            );
          }

          if (!controller.isCameraInitialized.value ||
              controller.cameraController == null) {
            return Center(child: ProgressIndicatorCustom());
          }
          return Stack(
            children: [
              // Preview da câmera com orientação correta
              Positioned.fill(
                child: AspectRatio(
                  aspectRatio: controller.cameraAspectRatio.value,
                  child: controller.isFrontCamera.value
                      ? Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()..scale(-1.0, 1.0),
                          child: CameraPreview(controller.cameraController!),
                        )
                      : CameraPreview(controller.cameraController!),
                ),
              ),
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FloatingActionButton(
                      onPressed: () async {
                        await controller.capturePhoto();
                      },
                      child: Icon(Icons.camera_alt),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 20,
                left: 50,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    FloatingActionButton(
                      onPressed: () async {
                        await controller.switchCamera();
                      },
                      child: Icon(
                        controller.isFrontCamera.value
                            ? Icons.camera_rear
                            : Icons.camera_front,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
