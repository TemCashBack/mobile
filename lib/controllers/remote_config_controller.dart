import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:get/get.dart';

class RemoteConfigController extends GetxController {
  final FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;
  var cashback = 0.obs;

  @override
  void onInit() {
    super.onInit();
    Future.microtask(() async => await _setupRemoteConfig());
  }

  Future<void> _setupRemoteConfig() async {
    await remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 1),
      minimumFetchInterval: const Duration(seconds: 1),
    ));

    await remoteConfig.setDefaults(const {
      "cashback": 10,
    });

    await fetchRemoteConfig();
  }

  Future<void> fetchRemoteConfig() async {
    try {
      await remoteConfig.fetchAndActivate();
      cashback.value = remoteConfig.getInt("cashback");
      print('Valor do cashback: ${cashback.value}');
    } catch (e) {
      print("Erro ao buscar configuração remota: $e");
    }
  }
}
