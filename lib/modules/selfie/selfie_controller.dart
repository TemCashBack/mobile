import 'dart:io';

import 'package:camera/camera.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/controllers/auth_controller.dart';
import 'package:mobile/data/repositories/customer_repository.dart';
import 'package:mobile/routes/app_routes.dart';
import 'package:mobile/ui/widgets/progress_indicator_custom.dart';
import 'package:path/path.dart';

class SelfieController extends GetxController {
  SelfieController({
    required this.authController,
    required this.customerRepository,
  });

  final AuthController authController;
  final CustomerRepository customerRepository;

  CameraController? cameraController;
  RxBool isCameraInitialized = false.obs;
  List<CameraDescription>? cameras;
  RxDouble cameraAspectRatio = 1.0.obs;
  RxBool isFrontCamera = true.obs;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  late CameraDescription selectedCamera;

  @override
  void onInit() {
    super.onInit();
    initializeCamera();
  }

  Future<void> initializeCamera() async {
    try {
      cameras = await availableCameras();

      if (cameras!.isNotEmpty) {
        selectedCamera = cameras!.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.front,
        );
        cameraController =
            CameraController(selectedCamera, ResolutionPreset.high);

        await cameraController!.initialize();
        cameraAspectRatio.value = cameraController!.value.aspectRatio;
        isCameraInitialized.value = true;
      }
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Não foi possível acessar a câmera.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> switchCamera() async {
    if (cameraController != null) {
      await cameraController!.dispose();
    }

    final newCameraLens = isFrontCamera.value
        ? CameraLensDirection.back
        : CameraLensDirection.front;

    selectedCamera =
        cameras!.firstWhere((camera) => camera.lensDirection == newCameraLens);

    cameraController = CameraController(selectedCamera, ResolutionPreset.high);
    await cameraController!.initialize();

    isCameraInitialized.value = true;
    isFrontCamera.value = !isFrontCamera.value;
  }

  Future<void> capturePhoto() async {
    if (cameraController == null || !cameraController!.value.isInitialized) {
      return;
    }

    try {
      Get.dialog(
        const Center(child: ProgressIndicatorCustom()),
        barrierDismissible: false,
      );

      final image = await cameraController!.takePicture();
      final downloadUrl = await _uploadImageToFirebase(image.path);
      final uid = authController.user.value?.uid;
      if (uid == null) {
        throw Exception('Usuário não autenticado.');
      }

      await customerRepository.updatePhotoURL(uid, downloadUrl);
      await authController.getCustomerData(uid);

      Get.back();
      Get.snackbar('Sucesso', 'Dados salvos com sucesso!');
      Get.offAllNamed(AppRoutes.HOME);
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      Get.snackbar(
        'Erro',
        'Erro ao tirar a foto: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<String> _uploadImageToFirebase(String imagePath) async {
    final file = File(imagePath);
    final fileName = basename(imagePath);
    final ref = _storage.ref().child('selfie/$fileName');

    await ref.putFile(file);
    return ref.getDownloadURL();
  }

  @override
  void onClose() {
    cameraController?.dispose();
    super.onClose();
  }
}
