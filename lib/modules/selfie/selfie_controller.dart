import 'dart:io';

import 'package:camera/camera.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/controllers/auth_controller.dart';
import 'package:mobile/data/repositories/customer_repository.dart';
import 'package:mobile/routes/app_routes.dart';
import 'package:path/path.dart';

class SelfieController extends GetxController {
  CameraController? cameraController;
  RxBool isCameraInitialized = false.obs;
  List<CameraDescription>? cameras;
  RxDouble cameraAspectRatio = 1.0.obs;
  RxBool isFrontCamera = true.obs; // Para saber se a câmera ativa é a frontal
  final FirebaseStorage _storage = FirebaseStorage.instance;

  late CameraDescription selectedCamera;

  AuthController authController = Get.find();
  CustomerRepository customerRepository = CustomerRepository();

  @override
  void onInit() {
    super.onInit();
    initializeCamera();
  }

  Future<void> initializeCamera() async {
    try {
      cameras = await availableCameras();

      if (cameras!.isNotEmpty) {
        selectedCamera = cameras!.firstWhere((camera) =>
            camera.lensDirection ==
            CameraLensDirection.front); // Inicia com a câmera frontal
        cameraController =
            CameraController(selectedCamera, ResolutionPreset.high);

        await cameraController!.initialize();
        cameraAspectRatio.value = cameraController!.value.aspectRatio;
        isCameraInitialized.value = true;
      }
    } catch (e) {
      Get.snackbar('Erro', 'Não foi possível acessar a câmera.',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> switchCamera() async {
    if (cameraController != null) {
      // Dispose da câmera atual antes de inicializar uma nova
      await cameraController!.dispose();
    }

    // Alterna entre as câmeras frontal e traseira
    final newCameraLens = isFrontCamera.value
        ? CameraLensDirection.back
        : CameraLensDirection.front;

    // Encontra a nova câmera com base no novo tipo
    selectedCamera =
        cameras!.firstWhere((camera) => camera.lensDirection == newCameraLens);

    // Cria um novo controlador para a câmera selecionada
    cameraController = CameraController(selectedCamera, ResolutionPreset.high);

    // Inicializa a nova câmera
    await cameraController!.initialize();

    // Atualiza o estado da câmera
    isCameraInitialized.value = true;
    isFrontCamera.value =
        !isFrontCamera.value; // Atualiza o estado da câmera (frontal/traseira)
  }

  Future<void> capturePhoto() async {
    if (cameraController == null || !cameraController!.value.isInitialized) {
      return;
    }
    try {
      Get.dialog(
        Center(
          child: CircularProgressIndicator(),
        ),
        barrierDismissible: false,
      );

      final XFile image = await cameraController!.takePicture();
      String downloadUrl = await _uploadImageToFirebase(image.path);
      await _saveImageUrlToFirestore(downloadUrl);

      Get.back();
      Get.snackbar('Sucesso', 'Dados salvos com sucesso!');
      Get.toNamed(AppRoutes.HOME);
    } catch (e) {
      Get.snackbar('Erro', 'Erro ao tirar a foto $e',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
  }

  Future<String> _uploadImageToFirebase(String imagePath) async {
    // Crie uma referência para o arquivo no Firebase Storage
    File file = File(imagePath);
    String fileName = basename(imagePath); // Pega o nome do arquivo
    Reference ref = _storage.ref().child('selfie/$fileName');

    await ref.putFile(file);

    String downloadUrl = await ref.getDownloadURL();
    return downloadUrl;
  }

  // Função para salvar a URL da imagem no Firestore
  Future<void> _saveImageUrlToFirestore(String downloadUrl) async {
    customerRepository.updatePhotoURL(
        authController.user.value!.uid, downloadUrl);
  }

  @override
  void onClose() {
    cameraController?.dispose();
    super.onClose();
  }
}
