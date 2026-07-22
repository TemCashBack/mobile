import 'package:get/get.dart';
import 'package:mobile/modules/cashback/cashback_binding.dart';
import 'package:mobile/modules/estabelecimentos/lista/lista_binding.dart';
import 'package:mobile/modules/estabelecimentos/mapa/mapa_binding.dart';

class EstabelecimentosBinding extends Bindings {
  @override
  void dependencies() {
    CashbackBinding.registerDependencies();
    MapaBinding().dependencies();
    ListaBinding().dependencies();
  }
}
