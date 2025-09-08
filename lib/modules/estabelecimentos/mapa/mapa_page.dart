import 'dart:async';
import 'dart:convert';

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

class _MapaPageState extends State<MapaPage> {
  final companiesRepository = CompanyRepository();
  final Completer<GoogleMapController> _googleMapController = Completer();
  final LocationController locationController = Get.put(LocationController());

  @override
  void initState() {
    super.initState();
    // Solicitar localização quando a página for inicializada
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestLocationIfNeeded();
    });
  }

  Future<void> _requestLocationIfNeeded() async {
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
  }

  Future<BitmapDescriptor> _loadCustomIcon() async {
    return await BitmapDescriptor.asset(
        ImageConfiguration(size: Size(20, 26)), 'lib/ui/assets/gps.png');
  }

  @override
  Widget build(BuildContext context) {
    List<DocumentSnapshot> empresas = [];
    Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
    CustomInfoWindowController customInfoWindowController =
        CustomInfoWindowController();

    return Scaffold(
      body: FutureBuilder(
        future: _loadCustomIcon(), // Carregar o ícone customizado
        builder: (context, snapShotIcon) {
          if (snapShotIcon.connectionState == ConnectionState.waiting) {
            return Center(child: ProgressIndicatorCustom());
          } else if (snapShotIcon.hasError) {
            return Center(child: Text('Erro ao carregar o ícone'));
          } else if (snapShotIcon.hasData) {
            return StreamBuilder<QuerySnapshot>(
              stream: companiesRepository.getPhysicalCompanies(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  MarkerId markerId;
                  Marker marker;
                  final List<DocumentSnapshot> documents = snapshot.data!.docs;
                  documents.map((doc) {
                    String json = jsonEncode(doc.data());
                    Map<String, dynamic> docMap = jsonDecode(json);
                    var entityCompany = CompanyModel.fromJson(docMap);
                    markerId = MarkerId(doc.id);
                    marker = Marker(
                      icon: snapShotIcon.data ?? BitmapDescriptor.defaultMarker,
                      markerId: markerId,
                      position: LatLng(entityCompany.geolocalizacao.lat,
                          entityCompany.geolocalizacao.lng),
                      onTap: () {
                        CompanyBottomSheet(context: context).showCompany(
                            doc.id,
                            entityCompany,
                            locationController.currentPosition.value);
                        customInfoWindowController.addInfoWindow!(
                          Column(
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  width: double.infinity,
                                  height: double.infinity,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.store,
                                          color: Colors.white,
                                          size: 30,
                                        ),
                                        SizedBox(
                                          width: 8.0,
                                        ),
                                        Text(
                                          entityCompany.nomeFantasia,
                                          style: TextStyle(color: Colors.white),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          LatLng(entityCompany.geolocalizacao.lat,
                              entityCompany.geolocalizacao.lng),
                        );
                      },
                    );
                    markers[markerId] = marker;
                  }).toList();

                  return Obx(() {
                    empresas = snapshot.data!.docs;

                    // Verificar se está carregando localização
                    if (locationController.isLoadingLocation.value) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ProgressIndicatorCustom(),
                            SizedBox(height: 16),
                            Text('Obtendo sua localização...'),
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
                            Icon(Icons.location_off,
                                size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text('Permissão de localização necessária'),
                            SizedBox(height: 8),
                            Text(
                                'Este app precisa de acesso à sua localização para funcionar'),
                            SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () async {
                                await locationController
                                    .requestLocationPermission();
                              },
                              child: Text('Conceder Permissão'),
                            ),
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
                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        GoogleMap(
                          onTap: (position) {
                            customInfoWindowController.hideInfoWindow!();
                          },
                          onCameraMove: (position) {
                            customInfoWindowController.onCameraMove!();
                          },
                          markers: Set<Marker>.of(markers.values),
                          mapType: MapType.normal,
                          initialCameraPosition: CameraPosition(
                            target: LatLng(
                              locationController
                                  .currentPosition.value!.latitude,
                              locationController
                                  .currentPosition.value!.longitude,
                            ),
                            zoom: 15.0,
                          ),
                          onMapCreated:
                              (GoogleMapController googleMapsController) {
                            if (!_googleMapController.isCompleted) {
                              _googleMapController
                                  .complete(googleMapsController);
                            }
                            customInfoWindowController.googleMapController =
                                googleMapsController;
                          },
                          // ignore: prefer_collection_literals
                          gestureRecognizers: Set()
                            ..add(Factory<PanGestureRecognizer>(
                                () => PanGestureRecognizer())),
                          myLocationButtonEnabled: true,
                          myLocationEnabled: true,
                        ),
                        CustomInfoWindow(
                          controller: customInfoWindowController,
                          height: 60,
                          width: 250,
                          offset: 40,
                        ),
                        Positioned(
                          top: 0,
                          left: 0,
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: Container(
                              padding: EdgeInsets.all(5),
                              color: Colors.black,
                              child: TypeAheadField(
                                builder: (context, controller, focusNode) {
                                  return TextField(
                                    cursorColor: Colors.grey,
                                    controller: controller,
                                    focusNode: focusNode,
                                    obscureText: false,
                                    decoration: InputDecoration(
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.black, width: 1),
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
                                  if (pattern.isNotEmpty) {
                                    List<DocumentSnapshot> searched =
                                        empresas.where((element) {
                                      return element
                                          .get('nomeFantasia')
                                          .toString()
                                          .toLowerCase()
                                          .contains(pattern.toLowerCase());
                                    }).toList();
                                    return searched.map((e) {
                                      var a = jsonEncode(e.data());
                                      return CompanyModel.fromJson(
                                          jsonDecode(a));
                                    }).toList();
                                  } else {
                                    return null;
                                  }
                                },
                                itemBuilder:
                                    (context, CompanyModel suggestion) {
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
                                  await gotoCompany(suggestion);
                                },
                                loadingBuilder: (context) =>
                                    const Text('Carregando...'),
                                errorBuilder: (context, error) => const Text(
                                    'Ocorreu um erro ao carregar...'),
                                emptyBuilder: (context) => Padding(
                                    padding: EdgeInsets.all(10),
                                    child: Text(
                                        'Nenhum estabelecimento encontrado')),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  });
                } else {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: ProgressIndicatorCustom(),
                    ),
                  );
                }
              },
            );
          } else {
            return Center(child: Text('Erro ao carregar ícone'));
          }
        },
      ),
      floatingActionButton: FloatingActionButton.small(
          onPressed: () async => await currentLocation(),
          child: Icon(Icons.my_location)),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }

  Future<void> gotoCompany(CompanyModel companyModel) async {
    final GoogleMapController controller = await _googleMapController.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        bearing: 192.8334901395799,
        target: LatLng(
            companyModel.geolocalizacao.lat, companyModel.geolocalizacao.lng),
        zoom: 18.0,
      ),
    ));
  }

  Future<void> currentLocation() async {
    if (locationController.currentPosition.value == null) {
      // Se não tem localização, solicitar
      await _requestLocationIfNeeded();
      return;
    }

    final GoogleMapController controller = await _googleMapController.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        bearing: 192.8334901395799,
        target: LatLng(locationController.currentPosition.value!.latitude,
            locationController.currentPosition.value!.longitude),
        zoom: 18.0,
      ),
    ));
  }
}
