import 'package:get/get.dart';
import 'package:mobile/modules/cashback/cashback_binding.dart';
import 'package:mobile/modules/cashback/cashback_page.dart';
import 'package:mobile/modules/estabelecimentos/estabelecimentos_binding.dart';
import 'package:mobile/modules/estabelecimentos/estabelecimentos_page.dart';
import 'package:mobile/modules/estabelecimentos/lista/lista_binding.dart';
import 'package:mobile/modules/estabelecimentos/lista/lista_page.dart';
import 'package:mobile/modules/estabelecimentos/mapa/mapa_binding.dart';
import 'package:mobile/modules/estabelecimentos/mapa/mapa_page.dart';
import 'package:mobile/modules/home/home_binding.dart';
import 'package:mobile/modules/home/home_page.dart';
import 'package:mobile/modules/boas_vindas/boas_vindas_binding.dart';
import 'package:mobile/modules/boas_vindas/boas_vindas_page.dart';
import 'package:mobile/modules/login/login_binding.dart';
import 'package:mobile/modules/login/login_page.dart';
import 'package:mobile/modules/registro/registro_binding.dart';
import 'package:mobile/modules/registro/registro_page.dart';
import 'package:mobile/modules/selfie/selfie_binding.dart';
import 'package:mobile/modules/selfie/selfie_page.dart';

import 'app_routes.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.HOME,
      page: () => HomePage(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: AppRoutes.BOASVINDAS,
      page: () => BoasVindasPage(),
      binding: BoasVindasBinding(),
    ),
    GetPage(
      name: AppRoutes.LOGIN,
      page: () => LoginPage(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: AppRoutes.REGISTRO,
      page: () => RegistroPage(),
      binding: RegistroBinding(),
    ),
    GetPage(
      name: AppRoutes.SELFIE,
      page: () => SelfiePage(),
      binding: SelfieBinding(),
    ),
    GetPage(
      name: AppRoutes.ESTABELECIMENTOS,
      page: () => EstabelecimentosPage(),
      binding: EstabelecimentosBinding(),
    ),
    GetPage(
      name: AppRoutes.ESTABELECIMENTOS_MAPA,
      page: () => MapaPage(),
      binding: MapaBinding(),
    ),
    GetPage(
      name: AppRoutes.ESTABELECIMENTOS_LISTA,
      page: () => ListaPage(),
      binding: ListaBinding(),
    ),
    GetPage(
      name: AppRoutes.CASHBACK,
      page: () => CashbackPage(),
      binding: CashbackBinding(),
    ),
  ];
}
