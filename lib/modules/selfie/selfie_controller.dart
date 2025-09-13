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
import 'package:permission_handler/permission_handler.dart';

class SelfieController extends GetxController {
  CameraController? cameraController;
  RxBool isCameraInitialized = false.obs;
  List<CameraDescription>? cameras;
  RxDouble cameraAspectRatio = 1.0.obs;
  RxBool isFrontCamera = true.obs;
  RxBool isPermissionGranted = false.obs;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  late CameraDescription selectedCamera;

  AuthController authController = Get.find();
  CustomerRepository customerRepository = CustomerRepository();

  @override
  void onInit() {
    super.onInit();
    checkCameraPermission();
  }

  Future<void> checkCameraPermission() async {
    try {
      // Verifica se a permissão da câmera foi concedida
      final status = await Permission.camera.status;

      if (status.isGranted) {
        isPermissionGranted.value = true;
        await initializeCamera();
      } else if (status.isDenied) {
        // Solicita permissão se foi negada
        final result = await Permission.camera.request();
        if (result.isGranted) {
          isPermissionGranted.value = true;
          await initializeCamera();
        } else {
          _showPermissionDeniedMessage();
        }
      } else if (status.isPermanentlyDenied) {
        _showPermissionPermanentlyDeniedMessage();
      }
    } catch (e) {
      print('Erro ao verificar permissão da câmera: $e');
      Get.snackbar('Erro', 'Erro ao verificar permissão da câmera.',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  void _showPermissionDeniedMessage() {
    Get.snackbar(
      'Permissão Negada',
      'É necessário permitir o acesso à câmera para tirar selfies.',
      snackPosition: SnackPosition.BOTTOM,
      duration: Duration(seconds: 5),
    );
  }

  void _showPermissionPermanentlyDeniedMessage() {
    Get.dialog(
      AlertDialog(
        title: Text('Permissão Necessária'),
        content: Text(
          'O acesso à câmera foi negado permanentemente. '
          'Por favor, vá às configurações do aplicativo e permita o acesso à câmera.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              openAppSettings();
            },
            child: Text('Abrir Configurações'),
          ),
        ],
      ),
    );
  }

  Future<void> initializeCamera() async {
    try {
      // Verifica se há câmeras disponíveis
      cameras = await availableCameras();

      if (cameras == null || cameras!.isEmpty) {
        Get.snackbar('Erro', 'Nenhuma câmera encontrada no dispositivo.',
            snackPosition: SnackPosition.BOTTOM);
        return;
      }

      // Tenta encontrar a câmera frontal primeiro
      CameraDescription? frontCamera;
      CameraDescription? backCamera;

      for (var camera in cameras!) {
        if (camera.lensDirection == CameraLensDirection.front) {
          frontCamera = camera;
        } else if (camera.lensDirection == CameraLensDirection.back) {
          backCamera = camera;
        }
      }

      // Seleciona a câmera frontal se disponível, senão a traseira
      if (frontCamera != null) {
        selectedCamera = frontCamera;
        isFrontCamera.value = true;
      } else if (backCamera != null) {
        selectedCamera = backCamera;
        isFrontCamera.value = false;
      } else {
        Get.snackbar('Erro', 'Nenhuma câmera adequada encontrada.',
            snackPosition: SnackPosition.BOTTOM);
        return;
      }

      // Inicializa o controlador da câmera
      cameraController = CameraController(
        selectedCamera,
        ResolutionPreset.high,
        enableAudio: false, // Desabilita áudio para selfies
      );

      await cameraController!.initialize();

      if (cameraController!.value.isInitialized) {
        cameraAspectRatio.value = cameraController!.value.aspectRatio;
        isCameraInitialized.value = true;
      } else {
        throw Exception('Falha ao inicializar a câmera');
      }
    } catch (e) {
      print('Erro ao inicializar câmera: $e');
      isCameraInitialized.value = false;

      String errorMessage = 'Não foi possível acessar a câmera.';

      if (e.toString().contains('Permission denied')) {
        errorMessage = 'Permissão da câmera foi negada.';
      } else if (e.toString().contains('Camera not available')) {
        errorMessage = 'Câmera não está disponível no momento.';
      }

      Get.snackbar('Erro', errorMessage, snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> switchCamera() async {
    if (cameras == null || cameras!.length < 2) {
      Get.snackbar('Aviso', 'Apenas uma câmera disponível.',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    try {
      // Dispose da câmera atual
      if (cameraController != null) {
        await cameraController!.dispose();
        isCameraInitialized.value = false;
      }

      // Alterna entre as câmeras frontal e traseira
      final newCameraLens = isFrontCamera.value
          ? CameraLensDirection.back
          : CameraLensDirection.front;

      // Encontra a nova câmera
      selectedCamera = cameras!.firstWhere(
        (camera) => camera.lensDirection == newCameraLens,
        orElse: () => cameras!.first,
      );

      // Cria um novo controlador
      cameraController = CameraController(
        selectedCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      // Inicializa a nova câmera
      await cameraController!.initialize();

      if (cameraController!.value.isInitialized) {
        cameraAspectRatio.value = cameraController!.value.aspectRatio;
        isCameraInitialized.value = true;
        isFrontCamera.value = !isFrontCamera.value;
      } else {
        throw Exception('Falha ao inicializar a nova câmera');
      }
    } catch (e) {
      print('Erro ao alternar câmera: $e');
      Get.snackbar('Erro', 'Erro ao alternar câmera.',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> capturePhoto() async {
    if (cameraController == null || !cameraController!.value.isInitialized) {
      Get.snackbar('Erro', 'Câmera não está inicializada.',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    try {
      Get.dialog(
        Center(
          child: ProgressIndicatorCustom(),
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
      Get.back(); // Fecha o dialog de loading
      print('Erro ao capturar foto: $e');
      Get.snackbar('Erro', 'Erro ao tirar a foto: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM);
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
