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

class MapaPage extends StatelessWidget {
  final companiesRepository = CompanyRepository();

  final Completer<GoogleMapController> _googleMapController = Completer();
  final LocationController locationController = Get.put(LocationController());

  MapaPage({super.key});

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
            return Center(child: CircularProgressIndicator());
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
                    print("Empresas: ${entityCompany.nomeFantasia}");
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
                                    color: primaryThemeColor,
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
                              Triangle.isosceles(
                                edge: Edge.BOTTOM,
                                child: Container(
                                  color: primaryThemeColor,
                                  width: 20.0,
                                  height: 10.0,
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
                    if (locationController.currentPosition.value == null) {
                      return Center(
                          child: CircularProgressIndicator()); // Carregando
                    } else {
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
                                color: primaryThemeColor,
                                child: TypeAheadField(
                                  builder: (context, controller, focusNode) {
                                    return TextField(
                                      controller: controller,
                                      focusNode: focusNode,
                                      obscureText: false,
                                      decoration: InputDecoration(
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
                    }
                  });
                } else {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: CircularProgressIndicator(),
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
