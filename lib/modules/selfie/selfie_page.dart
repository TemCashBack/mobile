import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/modules/selfie/selfie_controller.dart';
import 'package:mobile/ui/theme/colors.dart';
import 'package:mobile/ui/widgets/progress_indicator_custom.dart';

class SelfiePage extends GetView<SelfieController> {
  SelfiePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Selfie'),
        backgroundColor: primaryThemeColor,
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Obx(() {
        if (!controller.isCameraInitialized.value ||
            controller.cameraController == null) {
          return const Center(child: ProgressIndicatorCustom());
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
                    transform: Matrix4.rotationX(3.14159),
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
                    onPressed: controller.capturePhoto,
                    child: const Icon(Icons.camera_alt),
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
                    onPressed: controller.switchCamera,
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
      }),
    );
  }
}
