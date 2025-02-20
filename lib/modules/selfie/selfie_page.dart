import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/modules/selfie/selfie_controller.dart';
import 'package:mobile/ui/theme/colors.dart';
import 'package:mobile/ui/widgets/progress_indicator_custom.dart';

class SelfiePage extends StatelessWidget {
  SelfiePage({super.key});
  final SelfieController controller = Get.put(SelfieController());

  @override
  Widget build(BuildContext context) {
    final SelfieController controller = Get.put(SelfieController());
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
          if (!controller.isCameraInitialized.value ||
              controller.cameraController == null) {
            return Center(child: ProgressIndicatorCustom());
          }
          return Stack(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.75,
                    child: Transform(
                      alignment: Alignment.center,
                      transform: controller.isFrontCamera.value
                          ? Matrix4.rotationX(3.14159)
                          : Matrix4.rotationX(3.14159),
                      child: Transform(
                        alignment: Alignment.center,
                        transform: controller.isFrontCamera.value
                            ? Matrix4.rotationX(-3.14159)
                            : Matrix4.rotationY(3.14159),
                        child: Transform.rotate(
                          angle: -1.57,
                          child: AspectRatio(
                            aspectRatio: controller.cameraAspectRatio.value,
                            child: CameraPreview(controller.cameraController!),
                          ),
                        ),
                      ),
                    ),
                  ),
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
