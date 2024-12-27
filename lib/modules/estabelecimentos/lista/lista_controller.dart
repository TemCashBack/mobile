import 'package:get/get.dart';

class ListaController extends GetxController {
  var term = ''.obs;
  var category = ''.obs;

  @override
  void onInit() {
    super.onInit();
    //listarPedidos(); // Buscar os produtos ao inicializar o controller
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
