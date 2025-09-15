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
  RxBool isRequestingPermission = false.obs;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  late CameraDescription selectedCamera;

  AuthController authController = Get.find();
  CustomerRepository customerRepository = CustomerRepository();

  @override
  void onInit() {
    super.onInit();
    print('=== INICIALIZANDO SELFIECONTROLLER ===');
    checkCameraPermission();
  }

  Future<void> checkCameraPermission() async {
    // Evita múltiplas solicitações simultâneas
    if (isRequestingPermission.value) {
      print('Já está solicitando permissão, ignorando nova solicitação');
      return;
    }

    try {
      isRequestingPermission.value = true;
      print('Verificando permissão da câmera...');

      // Verifica se a permissão da câmera foi concedida
      final status = await Permission.camera.status;
      print('Status da permissão: $status');

      if (status.isGranted) {
        print('Permissão já concedida, inicializando câmera...');
        isPermissionGranted.value = true;
        await _initializeCameraSafely();
      } else if (status.isPermanentlyDenied) {
        print('Permissão negada permanentemente');
        _showPermissionPermanentlyDeniedMessage();
      } else {
        // Para todos os outros casos (isDenied, isNotDetermined, etc.)
        print('Solicitando permissão da câmera... Status atual: $status');
        final result = await Permission.camera.request();
        print('Resultado da solicitação: $result');

        if (result.isGranted) {
          print('Permissão concedida pelo usuário');
          isPermissionGranted.value = true;
          await _initializeCameraSafely();
        } else {
          print('Permissão negada pelo usuário');
          _showPermissionDeniedMessage();
        }
      }
    } catch (e) {
      print('Erro ao verificar permissão da câmera: $e');
      Get.snackbar('Erro', 'Erro ao verificar permissão da câmera.',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isRequestingPermission.value = false;
      print('Finalizou verificação de permissão');
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

  // Método para forçar solicitação de permissão (chamado pelo botão)
  Future<void> requestCameraPermission() async {
    if (isRequestingPermission.value) {
      print('Já está solicitando permissão, ignorando nova solicitação');
      return;
    }

    try {
      isRequestingPermission.value = true;
      print('=== INICIANDO SOLICITAÇÃO DE PERMISSÃO ===');

      // Verifica o status atual antes de solicitar
      final currentStatus = await Permission.camera.status;
      print('Status atual da permissão: $currentStatus');

      // Força a solicitação independente do status
      print('Solicitando permissão da câmera...');
      final result = await Permission.camera.request();
      print('Resultado da solicitação: $result');

      // Verifica o status após a solicitação
      final newStatus = await Permission.camera.status;
      print('Novo status após solicitação: $newStatus');

      if (result.isGranted || newStatus.isGranted) {
        print('✅ Permissão concedida pelo usuário');
        isPermissionGranted.value = true;
        await _initializeCameraSafely();
      } else if (result.isPermanentlyDenied || newStatus.isPermanentlyDenied) {
        print('❌ Permissão negada permanentemente');
        _showPermissionPermanentlyDeniedMessage();
      } else {
        print('❌ Permissão negada pelo usuário');
        _showPermissionDeniedMessage();
      }
    } catch (e) {
      print('❌ Erro ao solicitar permissão da câmera: $e');
      Get.snackbar(
          'Erro', 'Erro ao solicitar permissão da câmera: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isRequestingPermission.value = false;
      print('=== FINALIZOU SOLICITAÇÃO DE PERMISSÃO ===');
    }
  }

  // Método para testar se o permission_handler está funcionando
  Future<void> testPermissionHandler() async {
    try {
      print('=== TESTANDO PERMISSION_HANDLER ===');

      // Testa se consegue acessar o status
      final status = await Permission.camera.status;
      print('Status da câmera: $status');

      // Testa se consegue acessar outras permissões para comparar
      final locationStatus = await Permission.location.status;
      print('Status da localização: $locationStatus');

      // Verifica se o dispositivo tem câmera
      final cameras = await availableCameras();
      print('Câmeras disponíveis: ${cameras.length}');
    } catch (e) {
      print('Erro ao testar permission_handler: $e');
    }
  }

  // Método para resetar o estado de permissão (útil para debug)
  void resetPermissionState() {
    isPermissionGranted.value = false;
    isRequestingPermission.value = false;
    isCameraInitialized.value = false;
    if (cameraController != null) {
      cameraController!.dispose();
      cameraController = null;
    }
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

  // Método seguro para inicializar a câmera baseado na lógica do LocationController
  Future<void> _initializeCameraSafely() async {
    if (isCameraInitialized.value) {
      print('Câmera já está inicializada');
      return;
    }

    try {
      print('=== INICIALIZAÇÃO SEGURA DA CÂMERA ===');

      // Dispose da câmera anterior se existir
      if (cameraController != null) {
        print('Dispose da câmera anterior...');
        await cameraController!.dispose();
        cameraController = null;
        isCameraInitialized.value = false;
      }

      // Verificar permissão novamente antes de prosseguir
      final permissionStatus = await Permission.camera.status;
      if (!permissionStatus.isGranted) {
        throw Exception('Permissão da câmera não foi concedida');
      }

      // Buscar câmeras disponíveis
      print('Buscando câmeras disponíveis...');
      cameras = await availableCameras();

      if (cameras == null || cameras!.isEmpty) {
        throw Exception('Nenhuma câmera encontrada no dispositivo');
      }

      // Selecionar câmera frontal primeiro
      CameraDescription? selectedCameraDesc;
      for (var camera in cameras!) {
        if (camera.lensDirection == CameraLensDirection.front) {
          selectedCameraDesc = camera;
          break;
        }
      }

      if (selectedCameraDesc == null && cameras!.isNotEmpty) {
        selectedCameraDesc = cameras!.first;
      }

      if (selectedCameraDesc == null) {
        throw Exception('Nenhuma câmera adequada encontrada');
      }

      selectedCamera = selectedCameraDesc;
      isFrontCamera.value =
          selectedCameraDesc.lensDirection == CameraLensDirection.front;

      print('✅ Câmera selecionada: ${selectedCamera.name}');

      // Configurações específicas para iOS (baseado no LocationController)
      ResolutionPreset resolutionPreset = ResolutionPreset.medium;
      if (Platform.isIOS) {
        print('🔧 Configurações específicas para iOS aplicadas');
        resolutionPreset = ResolutionPreset.low; // Resolução menor para iOS
      }

      // Criar controller com configurações seguras
      print('Criando CameraController...');
      cameraController = CameraController(
        selectedCamera,
        resolutionPreset,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      // Inicialização com timeout (como no LocationController)
      print('Inicializando CameraController...');
      await cameraController!.initialize().timeout(
        Duration(
            seconds: 15), // Timeout de 15 segundos como no LocationController
        onTimeout: () {
          throw Exception('Timeout na inicialização da câmera');
        },
      );

      if (cameraController!.value.isInitialized) {
        cameraAspectRatio.value = cameraController!.value.aspectRatio;
        isCameraInitialized.value = true;
        print(
            '✅ Câmera inicializada com sucesso! Aspect ratio: ${cameraAspectRatio.value}');
      } else {
        throw Exception('CameraController não foi inicializado corretamente');
      }
    } catch (e) {
      print('❌ Erro na inicialização segura da câmera: $e');
      isCameraInitialized.value = false;

      // Dispose do controller em caso de erro
      if (cameraController != null) {
        try {
          await cameraController!.dispose();
          cameraController = null;
        } catch (disposeError) {
          print('❌ Erro no dispose da câmera: $disposeError');
        }
      }

      // Mostrar erro específico
      String errorMessage = 'Não foi possível acessar a câmera.';
      if (e.toString().contains('Permission denied')) {
        errorMessage = 'Permissão da câmera foi negada.';
      } else if (e.toString().contains('Camera not available')) {
        errorMessage = 'Câmera não está disponível no momento.';
      } else if (e.toString().contains('Timeout')) {
        errorMessage = 'Timeout ao inicializar a câmera. Tente novamente.';
      }

      Get.snackbar('Erro', errorMessage, snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> initializeCamera() async {
    try {
      print('=== INICIANDO INICIALIZAÇÃO DA CÂMERA ===');

      // Dispose da câmera anterior se existir
      if (cameraController != null) {
        print('Dispose da câmera anterior...');
        await cameraController!.dispose();
        cameraController = null;
        isCameraInitialized.value = false;
      }

      // Aguarda um pouco para garantir que o dispose foi concluído
      await Future.delayed(Duration(milliseconds: 500));

      // Verifica se há câmeras disponíveis
      print('Buscando câmeras disponíveis...');
      cameras = await availableCameras();
      print('Câmeras encontradas: ${cameras?.length ?? 0}');

      if (cameras == null || cameras!.isEmpty) {
        print('❌ Nenhuma câmera encontrada no dispositivo');
        Get.snackbar('Erro', 'Nenhuma câmera encontrada no dispositivo.',
            snackPosition: SnackPosition.BOTTOM);
        return;
      }

      // Tenta encontrar a câmera frontal primeiro
      CameraDescription? frontCamera;
      CameraDescription? backCamera;

      for (var camera in cameras!) {
        print('Câmera encontrada: ${camera.name} - ${camera.lensDirection}');
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
        print('✅ Selecionada câmera frontal: ${frontCamera.name}');
      } else if (backCamera != null) {
        selectedCamera = backCamera;
        isFrontCamera.value = false;
        print('✅ Selecionada câmera traseira: ${backCamera.name}');
      } else {
        print('❌ Nenhuma câmera adequada encontrada');
        Get.snackbar('Erro', 'Nenhuma câmera adequada encontrada.',
            snackPosition: SnackPosition.BOTTOM);
        return;
      }

      // Aguarda um pouco antes de criar o controller (especialmente importante no iOS)
      await Future.delayed(Duration(milliseconds: 300));

      // Configurações específicas para iOS
      ResolutionPreset resolutionPreset = ResolutionPreset.medium;
      if (Platform.isIOS) {
        print('🔧 Configurações específicas para iOS aplicadas');
        resolutionPreset =
            ResolutionPreset.low; // Resolução ainda menor para iOS
        // Aguarda um pouco mais no iOS
        await Future.delayed(Duration(milliseconds: 200));
      }

      // Inicializa o controlador da câmera com configurações mais conservadoras para iOS
      print('Criando CameraController...');
      cameraController = CameraController(
        selectedCamera,
        resolutionPreset,
        enableAudio: false, // Desabilita áudio para selfies
        imageFormatGroup:
            ImageFormatGroup.jpeg, // Especifica formato JPEG explicitamente
      );

      print('Inicializando CameraController...');
      await cameraController!.initialize();

      if (cameraController!.value.isInitialized) {
        cameraAspectRatio.value = cameraController!.value.aspectRatio;
        isCameraInitialized.value = true;
        print(
            '✅ Câmera inicializada com sucesso! Aspect ratio: ${cameraAspectRatio.value}');
      } else {
        throw Exception(
            'Falha ao inicializar a câmera - controller não inicializado');
      }
    } catch (e) {
      print('❌ Erro ao inicializar câmera: $e');
      print('❌ Stack trace: ${StackTrace.current}');
      isCameraInitialized.value = false;

      // Dispose do controller em caso de erro
      if (cameraController != null) {
        try {
          await cameraController!.dispose();
          cameraController = null;
        } catch (disposeError) {
          print('❌ Erro ao fazer dispose da câmera: $disposeError');
        }
      }

      String errorMessage = 'Não foi possível acessar a câmera.';

      if (e.toString().contains('Permission denied')) {
        errorMessage = 'Permissão da câmera foi negada.';
      } else if (e.toString().contains('Camera not available')) {
        errorMessage = 'Câmera não está disponível no momento.';
      } else if (e.toString().contains('Memory')) {
        errorMessage = 'Erro de memória ao acessar a câmera. Tente novamente.';
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
      print('=== ALTERNANDO CÂMERA ===');

      // Dispose da câmera atual
      if (cameraController != null) {
        print('Dispose da câmera atual...');
        await cameraController!.dispose();
        cameraController = null;
        isCameraInitialized.value = false;
      }

      // Aguarda um pouco para garantir que o dispose foi concluído
      await Future.delayed(Duration(milliseconds: 500));

      // Alterna entre as câmeras frontal e traseira
      final newCameraLens = isFrontCamera.value
          ? CameraLensDirection.back
          : CameraLensDirection.front;

      // Encontra a nova câmera
      selectedCamera = cameras!.firstWhere(
        (camera) => camera.lensDirection == newCameraLens,
        orElse: () => cameras!.first,
      );

      print(
          'Nova câmera selecionada: ${selectedCamera.name} - ${selectedCamera.lensDirection}');

      // Aguarda um pouco antes de criar o novo controller
      await Future.delayed(Duration(milliseconds: 300));

      // Configurações específicas para iOS
      ResolutionPreset resolutionPreset = ResolutionPreset.medium;
      if (Platform.isIOS) {
        print('🔧 Configurações específicas para iOS aplicadas (switch)');
        resolutionPreset =
            ResolutionPreset.low; // Resolução ainda menor para iOS
        // Aguarda um pouco mais no iOS
        await Future.delayed(Duration(milliseconds: 200));
      }

      // Cria um novo controlador com configurações mais conservadoras
      print('Criando novo CameraController...');
      cameraController = CameraController(
        selectedCamera,
        resolutionPreset,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      // Inicializa a nova câmera
      print('Inicializando nova câmera...');
      await cameraController!.initialize();

      if (cameraController!.value.isInitialized) {
        cameraAspectRatio.value = cameraController!.value.aspectRatio;
        isCameraInitialized.value = true;
        isFrontCamera.value = !isFrontCamera.value;
        print(
            '✅ Câmera alternada com sucesso! Nova câmera: ${isFrontCamera.value ? "frontal" : "traseira"}');
      } else {
        throw Exception('Falha ao inicializar a nova câmera');
      }
    } catch (e) {
      print('❌ Erro ao alternar câmera: $e');
      print('❌ Stack trace: ${StackTrace.current}');

      // Dispose do controller em caso de erro
      if (cameraController != null) {
        try {
          await cameraController!.dispose();
          cameraController = null;
        } catch (disposeError) {
          print('❌ Erro ao fazer dispose da câmera: $disposeError');
        }
      }

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
    print('=== DISPOSE SELFIECONTROLLER ===');
    if (cameraController != null) {
      try {
        cameraController!.dispose();
        print('✅ CameraController disposed com sucesso');
      } catch (e) {
        print('❌ Erro ao fazer dispose do CameraController: $e');
      }
      cameraController = null;
    }
    super.onClose();
  }
}
