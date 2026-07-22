import 'package:get/get.dart';
import 'package:mobile/controllers/location_controller.dart';

class ListaController extends GetxController {
  var term = ''.obs;
  var category = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _ensureLocation();
  }

  Future<void> _ensureLocation() async {
    if (!Get.isRegistered<LocationController>()) return;
    final location = Get.find<LocationController>();
    if (await location.ensureLocationAccess()) {
      await location.requestLocation();
    }
  }

  // Stream<QuerySnapshot<Object?>> listarPedidos() {
  //   PedidosRepository pedidosRepository = PedidosRepository();
  //   return pedidosRepository.streamGetAll();
  // }

  // Stream<DocumentSnapshot<Object?>> listarItensPedidos(id) {
  //   PedidosRepository pedidosRepository = PedidosRepository();
  //   return pedidosRepository.streamGetFromId(id);
  // }

  // Future<void> delete(idPedido) async {
  //   PedidosRepository pedidosRepository = PedidosRepository();
  //   return await pedidosRepository.delete(idPedido);
  // }
}
