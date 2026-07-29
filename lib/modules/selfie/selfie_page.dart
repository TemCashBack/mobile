import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/modules/selfie/selfie_controller.dart';
import 'package:mobile/ui/theme/app_styles.dart';
import 'package:mobile/ui/theme/colors.dart';
import 'package:mobile/ui/widgets/progress_indicator_custom.dart';

class SelfiePage extends GetView<SelfieController> {
  const SelfiePage({super.key});

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
        final error = controller.cameraError.value;
        if (error != null) {
          return _CameraError(
            message: error,
            onRetry: controller.initializeCamera,
          );
        }

        if (!controller.isCameraInitialized.value ||
            controller.cameraController == null) {
          return const Center(child: ProgressIndicatorCustom());
        }

        return Stack(
          fit: StackFit.expand,
          children: [
            _CameraPreviewLayer(controller: controller),
            Positioned(
              bottom: 24,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (controller.cameras.length > 1) ...[
                    FloatingActionButton(
                      heroTag: 'switch_camera',
                      onPressed: controller.switchCamera,
                      child: Icon(
                        controller.isFrontCamera.value
                            ? Icons.camera_rear
                            : Icons.camera_front,
                      ),
                    ),
                    const SizedBox(width: 24),
                  ],
                  FloatingActionButton(
                    heroTag: 'capture_photo',
                    onPressed: controller.capturePhoto,
                    child: const Icon(Icons.camera_alt),
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

class _CameraPreviewLayer extends StatelessWidget {
  const _CameraPreviewLayer({required this.controller});

  final SelfieController controller;

  @override
  Widget build(BuildContext context) {
    final preview = CameraPreview(controller.cameraController!);

    // Na web, o preview já vem na orientação correta.
    // As rotações extras do mobile quebram a exibição no Chrome.
    if (kIsWeb) {
      return ColoredBox(
        color: Colors.black,
        child: Center(
          child: AspectRatio(
            aspectRatio: controller.cameraAspectRatio.value,
            child: preview,
          ),
        ),
      );
    }

    return SizedBox(
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
                  child: preview,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CameraError extends StatelessWidget {
  const _CameraError({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.videocam_off_outlined,
            size: 56,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              height: 1.4,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('Tentar novamente'),
          ),
        ],
      ),
    );
  }
}
