import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:clippy_flutter/clippy_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:custom_info_window/custom_info_window.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mobile/controllers/location_controller.dart';
import 'package:mobile/data/models/company_model.dart';
import 'package:mobile/data/repositories/company_repository.dart';
import 'package:mobile/ui/theme/colors.dart';
import 'package:mobile/ui/widgets/company_bottom_sheet.dart';
import 'package:mobile/ui/widgets/progress_indicator_custom.dart';

class MapaPage extends StatefulWidget {
  const MapaPage({super.key});

  @override
  _MapaPageState createState() => _MapaPageState();
}

class _MapaPageState extends State<MapaPage> with WidgetsBindingObserver {
  final companiesRepository = CompanyRepository();
  final Completer<GoogleMapController> _googleMapController = Completer();
  late LocationController locationController;
  bool _isInitialized = false;
  BitmapDescriptor? _customIcon;
  List<DocumentSnapshot> empresas = [];
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  final bool _isIOS = Platform.isIOS;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializePage();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Tratamento específico para iOS
    if (_isIOS) {
      if (state == AppLifecycleState.resumed) {
        // App voltou ao foco, verificar localização
        _checkLocationOnResume();
      }
    }
  }

  Future<void> _checkLocationOnResume() async {
    try {
      // Verificar se ainda tem permissão de localização
      bool hasPermission = await locationController.checkLocationPermission();
      if (hasPermission && locationController.currentPosition.value == null) {
        // Solicitar localização novamente
        await locationController.requestLocation();
      }
    } catch (e) {
      print("Erro ao verificar localização no resume: $e");
    }
  }

  Future<void> _initializePage() async {
    try {
      // Inicializar o controller de localização
      locationController = Get.put(LocationController());

      // Carregar o ícone customizado
      _customIcon = await _loadCustomIcon();

      // Marcar como inicializado
      setState(() {
        _isInitialized = true;
      });

      // Solicitar localização após a inicialização
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _requestLocationIfNeeded();
      });
    } catch (e) {
      print("Erro ao inicializar página do mapa: $e");
      // Em caso de erro, mostrar mensagem de erro
      setState(() {
        _isInitialized = true;
      });
    }
  }

  Future<void> _requestLocationIfNeeded() async {
    try {
      if (locationController.currentPosition.value == null) {
        // Verificar se tem permissão
        bool hasPermission = await locationController.checkLocationPermission();
        if (!hasPermission) {
          // Solicitar permissão
          await locationController.requestLocationPermission();
        } else {
          // Solicitar localização
          await locationController.requestLocation();
        }
      }
    } catch (e) {
      print("Erro ao solicitar localização: $e");
    }
  }

  Future<BitmapDescriptor> _loadCustomIcon() async {
    try {
      return await BitmapDescriptor.asset(
          ImageConfiguration(size: Size(20, 26)), 'lib/ui/assets/gps.png');
    } catch (e) {
      print("Erro ao carregar ícone customizado: $e");
      return BitmapDescriptor.defaultMarker;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ProgressIndicatorCustom(),
              SizedBox(height: 16),
              Text('Inicializando mapa...'),
              if (_isIOS) ...[
                SizedBox(height: 8),
                Text(
                  'iOS: Configurando permissões...',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: _buildMapContent(),
      floatingActionButton: FloatingActionButton.small(
        onPressed: () async => await _goToCurrentLocation(),
        child: Icon(Icons.my_location),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }

  Widget _buildMapContent() {
    return StreamBuilder<QuerySnapshot>(
      stream: companiesRepository.getPhysicalCompanies(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: ProgressIndicatorCustom());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, size: 64, color: Colors.red),
                SizedBox(height: 16),
                Text('Erro ao carregar estabelecimentos'),
                SizedBox(height: 8),
                Text('${snapshot.error}'),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {});
                  },
                  child: Text('Tentar Novamente'),
                ),
              ],
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.store, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('Nenhum estabelecimento encontrado'),
              ],
            ),
          );
        }

        // Processar dados dos estabelecimentos
        _processCompanies(snapshot.data!.docs);

        return Obx(() => _buildMapWithLocation());
      },
    );
  }

  void _processCompanies(List<DocumentSnapshot> documents) {
    try {
      markers.clear();
      empresas = documents;

      for (var doc in documents) {
        try {
          String json = jsonEncode(doc.data());
          Map<String, dynamic> docMap = jsonDecode(json);
          var entityCompany = CompanyModel.fromJson(docMap);

          MarkerId markerId = MarkerId(doc.id);
          Marker marker = Marker(
            icon: _customIcon ?? BitmapDescriptor.defaultMarker,
            markerId: markerId,
            position: LatLng(
              entityCompany.geolocalizacao.lat,
              entityCompany.geolocalizacao.lng,
            ),
            onTap: () => _onMarkerTapped(doc.id, entityCompany),
          );

          markers[markerId] = marker;
        } catch (e) {
          print("Erro ao processar estabelecimento ${doc.id}: $e");
        }
      }
    } catch (e) {
      print("Erro ao processar estabelecimentos: $e");
    }
  }

  void _onMarkerTapped(String docId, CompanyModel company) {
    try {
      CompanyBottomSheet(context: context).showCompany(
        docId,
        company,
        locationController.currentPosition.value,
      );
    } catch (e) {
      print("Erro ao mostrar bottom sheet: $e");
      Get.snackbar(
        'Erro',
        'Não foi possível mostrar informações do estabelecimento',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Widget _buildMapWithLocation() {
    // Verificar se está carregando localização
    if (locationController.isLoadingLocation.value) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ProgressIndicatorCustom(),
            SizedBox(height: 16),
            Text('Obtendo sua localização...'),
            if (_isIOS) ...[
              SizedBox(height: 8),
              Text(
                'iOS: Aguardando permissão do sistema...',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ],
        ),
      );
    }

    // Verificar se tem permissão de localização
    if (!locationController.hasLocationPermission.value) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Permissão de localização necessária'),
            SizedBox(height: 8),
            Text('Este app precisa de acesso à sua localização para funcionar'),
            if (_isIOS) ...[
              SizedBox(height: 8),
              Text(
                'iOS: Vá em Configurações > Privacidade > Localização',
                style: TextStyle(fontSize: 12, color: Colors.blue),
                textAlign: TextAlign.center,
              ),
            ],
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                await locationController.requestLocationPermission();
              },
              child: Text('Conceder Permissão'),
            ),
            if (_isIOS) ...[
              SizedBox(height: 8),
              ElevatedButton(
                onPressed: () async {
                  // No iOS, abrir configurações do sistema
                  if (Platform.isIOS) {
                    // Tentar abrir configurações do app
                    try {
                      // Implementar abertura das configurações do iOS
                      print("Abrir configurações do iOS");
                    } catch (e) {
                      print("Erro ao abrir configurações: $e");
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                ),
                child: Text('Abrir Configurações'),
              ),
            ],
          ],
        ),
      );
    }

    // Verificar se tem posição atual
    if (locationController.currentPosition.value == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.gps_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Não foi possível obter sua localização'),
            SizedBox(height: 8),
            Text('Verifique se o GPS está ativado'),
            if (_isIOS) ...[
              SizedBox(height: 8),
              Text(
                'iOS: Verifique se o app tem permissão "Sempre" ou "Durante o uso"',
                style: TextStyle(fontSize: 12, color: Colors.blue),
                textAlign: TextAlign.center,
              ),
            ],
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                await locationController.requestLocation();
              },
              child: Text('Tentar Novamente'),
            ),
          ],
        ),
      );
    }

    // Mapa funcionando normalmente
    return _buildGoogleMap();
  }

  Widget _buildGoogleMap() {
    try {
      return Stack(
        fit: StackFit.expand,
        children: [
          GoogleMap(
            onTap: (position) {
              // Ocultar info window se estiver visível
            },
            onCameraMove: (position) {
              // Atualizar posição da câmera se necessário
            },
            markers: Set<Marker>.of(markers.values),
            mapType: MapType.normal,
            initialCameraPosition: CameraPosition(
              target: LatLng(
                locationController.currentPosition.value!.latitude,
                locationController.currentPosition.value!.longitude,
              ),
              zoom: 15.0,
            ),
            onMapCreated: (GoogleMapController googleMapsController) {
              if (!_googleMapController.isCompleted) {
                _googleMapController.complete(googleMapsController);
              }
            },
            gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{}..add(
                Factory<PanGestureRecognizer>(() => PanGestureRecognizer())),
            myLocationButtonEnabled: true,
            myLocationEnabled: true,
          ),
          _buildSearchBar(),
        ],
      );
    } catch (e) {
      print("Erro ao construir mapa: $e");
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text('Erro ao carregar mapa'),
            SizedBox(height: 8),
            Text('Tente novamente mais tarde'),
            if (_isIOS) ...[
              SizedBox(height: 8),
              Text(
                'iOS: Verifique se o Google Maps está funcionando',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ],
        ),
      );
    }
  }

  Widget _buildSearchBar() {
    return Positioned(
      top: 0,
      left: 0,
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Container(
          padding: EdgeInsets.all(5),
          color: Colors.black,
          child: TypeAheadField<CompanyModel>(
            builder: (context, controller, focusNode) {
              return TextField(
                cursorColor: Colors.grey,
                controller: controller,
                focusNode: focusNode,
                obscureText: false,
                decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black, width: 1),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(),
                  hintText: 'Pesquise um estabelecimento',
                ),
                style: TextStyle(fontSize: 12),
              );
            },
            suggestionsCallback: (pattern) async {
              if (pattern.isEmpty) return [];

              try {
                return empresas
                    .where((element) {
                      return element
                          .get('nomeFantasia')
                          .toString()
                          .toLowerCase()
                          .contains(pattern.toLowerCase());
                    })
                    .map((e) {
                      try {
                        String json = jsonEncode(e.data());
                        Map<String, dynamic> docMap = jsonDecode(json);
                        return CompanyModel.fromJson(docMap);
                      } catch (e) {
                        print("Erro ao converter estabelecimento: $e");
                        return null;
                      }
                    })
                    .where((e) => e != null)
                    .cast<CompanyModel>()
                    .toList();
              } catch (e) {
                print("Erro na busca: $e");
                return [];
              }
            },
            itemBuilder: (context, CompanyModel suggestion) {
              return ListTile(
                leading: FaIcon(
                  FontAwesomeIcons.building,
                  color: Colors.black,
                ),
                title: Text(suggestion.nomeFantasia),
                subtitle: Text(suggestion.razaoSocial),
              );
            },
            onSelected: (CompanyModel suggestion) async {
              await _goToCompany(suggestion);
            },
            loadingBuilder: (context) => const Text('Carregando...'),
            errorBuilder: (context, error) => const Text('Erro ao carregar...'),
            emptyBuilder: (context) => Padding(
              padding: EdgeInsets.all(10),
              child: Text('Nenhum estabelecimento encontrado'),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _goToCompany(CompanyModel companyModel) async {
    try {
      final GoogleMapController controller = await _googleMapController.future;
      controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          bearing: 192.8334901395799,
          target: LatLng(
              companyModel.geolocalizacao.lat, companyModel.geolocalizacao.lng),
          zoom: 18.0,
        ),
      ));
    } catch (e) {
      print("Erro ao ir para estabelecimento: $e");
      Get.snackbar(
        'Erro',
        'Não foi possível navegar para o estabelecimento',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _goToCurrentLocation() async {
    try {
      if (locationController.currentPosition.value == null) {
        // Se não tem localização, solicitar
        await _requestLocationIfNeeded();
        return;
      }

      final GoogleMapController controller = await _googleMapController.future;
      controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          bearing: 192.8334901395799,
          target: LatLng(
            locationController.currentPosition.value!.latitude,
            locationController.currentPosition.value!.longitude,
          ),
          zoom: 18.0,
        ),
      ));
    } catch (e) {
      print("Erro ao ir para localização atual: $e");
      Get.snackbar(
        'Erro',
        'Não foi possível navegar para sua localização',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
