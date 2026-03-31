import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

class EstabelecimentosController extends GetxController {
  Rx<Position?> currentPosition = Rx<Position?>(null);

  @override
  void onInit() {
    super.onInit();
  }
}
