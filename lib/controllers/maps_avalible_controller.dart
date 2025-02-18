import 'package:get/get.dart';
import 'package:map_launcher/map_launcher.dart';

class MapsAvalibleController extends GetxController {
  Rx<List<AvailableMap>?> availableMaps = Rx<List<AvailableMap>?>(null);

  @override
  Future<void> onInit() async {
    super.onInit();
    await _getAvalibelMaps();
  }

  // Método para obter a localização atual
  Future<void> _getAvalibelMaps() async {
    try {
      availableMaps.value = await MapLauncher.installedMaps;
    } catch (e) {
      print("Ocorreu um erro ao trazer os tipos de mapas: $e");
    }
  }
}
