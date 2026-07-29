import 'package:camera/camera.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show Uint8List, kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/controllers/auth_controller.dart';
import 'package:mobile/data/repositories/customer_repository.dart';
import 'package:mobile/routes/app_routes.dart';
import 'package:mobile/ui/theme/app_styles.dart';
import 'package:mobile/ui/widgets/progress_indicator_custom.dart';

class SelfieController extends GetxController {
  SelfieController({
    required this.authController,
    required this.customerRepository,
  });

  final AuthController authController;
  final CustomerRepository customerRepository;

  CameraController? cameraController;
  final isCameraInitialized = false.obs;
  final cameraError = RxnString();
  List<CameraDescription> cameras = [];
  final cameraAspectRatio = 1.0.obs;
  final isFrontCamera = true.obs;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  late CameraDescription selectedCamera;

  @override
  void onInit() {
    super.onInit();
    initializeCamera();
  }

  Future<void> initializeCamera() async {
    cameraError.value = null;
    isCameraInitialized.value = false;

    try {
      cameras = await availableCameras();

      if (cameras.isEmpty) {
        cameraError.value =
            'Nenhuma câmera encontrada neste dispositivo.';
        return;
      }

      selectedCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );
      isFrontCamera.value =
          selectedCamera.lensDirection == CameraLensDirection.front;

      // medium é mais estável na web; high segue ok no mobile.
      final preset =
          kIsWeb ? ResolutionPreset.medium : ResolutionPreset.high;

      cameraController = CameraController(
        selectedCamera,
        preset,
        enableAudio: false,
      );

      await cameraController!.initialize();
      cameraAspectRatio.value = cameraController!.value.aspectRatio;
      isCameraInitialized.value = true;
    } catch (e) {
      cameraError.value =
          'Não foi possível acessar a câmera. Verifique a permissão do navegador ou do dispositivo.';
      isCameraInitialized.value = false;
    }
  }

  Future<void> switchCamera() async {
    if (cameras.length < 2) return;

    isCameraInitialized.value = false;
    await cameraController?.dispose();
    cameraController = null;

    final newCameraLens = isFrontCamera.value
        ? CameraLensDirection.back
        : CameraLensDirection.front;

    selectedCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == newCameraLens,
      orElse: () => cameras.first,
    );

    final preset =
        kIsWeb ? ResolutionPreset.medium : ResolutionPreset.high;

    cameraController = CameraController(
      selectedCamera,
      preset,
      enableAudio: false,
    );
    await cameraController!.initialize();

    cameraAspectRatio.value = cameraController!.value.aspectRatio;
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

      final uid = authController.user.value?.uid;
      if (uid == null) {
        throw Exception('Usuário não autenticado.');
      }

      final image = await cameraController!.takePicture();
      final bytes = await image.readAsBytes();
      final downloadUrl = await _uploadImageToFirebase(uid, bytes);

      await customerRepository.updatePhotoURL(uid, downloadUrl);
      authController.setProfilePhoto(bytes: bytes, photoURL: downloadUrl);

      if (Get.isDialogOpen ?? false) Get.back();
      Get.offAllNamed(AppRoutes.HOME);
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      Get.dialog(
        Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Erro ao salvar selfie',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Tente novamente. Se estiver na web, permita o acesso à câmera.\n\nDetalhe: $e',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: AppSpacing.lg),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Get.back(),
                    child: const Text('Entendi'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  /// Path fixo por usuário + putData (web e mobile).
  Future<String> _uploadImageToFirebase(String uid, Uint8List bytes) async {
    final ref = _storage.ref(AuthController.selfieStoragePath(uid));

    await ref.putData(
      bytes,
      SettableMetadata(contentType: 'image/jpeg'),
    );
    return ref.getDownloadURL();
  }

  @override
  void onClose() {
    cameraController?.dispose();
    super.onClose();
  }
}
