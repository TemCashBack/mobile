import 'dart:async';

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
import 'package:mobile/ui/widgets/company_bottom_sheet.dart';
import 'package:mobile/ui/widgets/progress_indicator_custom.dart';

class MapaPage extends StatefulWidget {
  const MapaPage({super.key});

  @override
  State<MapaPage> createState() => _MapaPageState();
}

class _MapaPageState extends State<MapaPage> {
  final companiesRepository = Get.find<CompanyRepository>();
  final Completer<GoogleMapController> _googleMapController = Completer();
  final LocationController locationController = Get.find<LocationController>();
  final CustomInfoWindowController _customInfoWindowController =
      CustomInfoWindowController();

  BitmapDescriptor? _markerIcon;
  bool _loadingIcon = true;
  String? _iconError;

  @override
  void initState() {
    super.initState();
    _loadCustomIcon();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestLocationIfNeeded();
    });
  }

  @override
  void dispose() {
    _customInfoWindowController.dispose();
    super.dispose();
  }

  Future<void> _requestLocationIfNeeded() async {
    if (locationController.currentPosition.value != null) return;

    final granted = await locationController.ensureLocationAccess();
    if (granted) {
      await locationController.requestLocation();
    }
  }

  Future<void> _loadCustomIcon() async {
    try {
      final icon = await BitmapDescriptor.asset(
        const ImageConfiguration(size: Size(20, 26)),
        'lib/ui/assets/gps.png',
      );
      if (!mounted) return;
      setState(() {
        _markerIcon = icon;
        _loadingIcon = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _markerIcon = BitmapDescriptor.defaultMarker;
        _loadingIcon = false;
        _iconError = null;
      });
    }
  }

  CompanyModel? _tryParseCompany(DocumentSnapshot doc) {
    try {
      final map = CompanyModel.mapFromFirestore(doc.data());
      if (!CompanyModel.isVisibleFromJson(map)) return null;
      if (!CompanyModel.isMappableFromJson(map)) return null;
      return CompanyModel.fromFirestore(doc.data(), documentId: doc.id);
    } catch (_) {
      return null;
    }
  }

  Map<MarkerId, Marker> _buildMarkers(
    List<DocumentSnapshot> documents,
    BuildContext context,
  ) {
    final markers = <MarkerId, Marker>{};
    final icon = _markerIcon ?? BitmapDescriptor.defaultMarker;

    for (final doc in documents) {
      final company = _tryParseCompany(doc);
      if (company == null) continue;

      final markerId = MarkerId(doc.id);
      markers[markerId] = Marker(
        icon: icon,
        markerId: markerId,
        position: LatLng(
          company.geolocalizacao.lat,
          company.geolocalizacao.lng,
        ),
        onTap: () {
          CompanyBottomSheet(context: context).showCompany(
            doc.id,
            company,
            locationController.currentPosition.value,
          );
          _customInfoWindowController.addInfoWindow?.call(
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
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.store, color: Colors.white, size: 30),
                          const SizedBox(width: 8.0),
                          Flexible(
                            child: Text(
                              company.nomeFantasia,
                              style: const TextStyle(color: Colors.white),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            LatLng(company.geolocalizacao.lat, company.geolocalizacao.lng),
          );
        },
      );
    }

    return markers;
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingIcon) {
      return const Scaffold(
        primary: false,
        body: Center(child: ProgressIndicatorCustom()),
      );
    }

    if (_iconError != null) {
      return Scaffold(
        primary: false,
        body: Center(child: Text(_iconError!)),
      );
    }

    return Scaffold(
      primary: false,
      body: StreamBuilder<QuerySnapshot>(
        stream: companiesRepository.getPhysicalCompanies(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('Não foi possível carregar o mapa.'),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: ProgressIndicatorCustom());
          }

          final documents = snapshot.data!.docs.where((doc) {
            final map = CompanyModel.mapFromFirestore(doc.data());
            return CompanyModel.isVisibleFromJson(map) &&
                CompanyModel.isMappableFromJson(map);
          }).toList();

          final markers = _buildMarkers(documents, context);

          return Obx(() {
            if (locationController.isLoadingLocation.value) {
              return const Center(
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

            if (!locationController.hasLocationPermission.value) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.location_off, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text('Permissão de localização necessária'),
                    const SizedBox(height: 8),
                    const Text(
                      'Este app precisa de acesso à sua localização para funcionar',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () async {
                        await locationController.requestLocationPermission();
                      },
                      child: const Text('Conceder Permissão'),
                    ),
                  ],
                ),
              );
            }

            if (locationController.currentPosition.value == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.gps_off, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text('Não foi possível obter sua localização'),
                    const SizedBox(height: 8),
                    const Text('Verifique se o GPS está ativado'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () async {
                        await locationController.requestLocation();
                      },
                      child: const Text('Tentar Novamente'),
                    ),
                  ],
                ),
              );
            }

            final position = locationController.currentPosition.value!;

            return Stack(
              fit: StackFit.expand,
              children: [
                GoogleMap(
                  onTap: (_) {
                    _customInfoWindowController.hideInfoWindow?.call();
                  },
                  onCameraMove: (_) {
                    _customInfoWindowController.onCameraMove?.call();
                  },
                  markers: Set<Marker>.of(markers.values),
                  mapType: MapType.normal,
                  initialCameraPosition: CameraPosition(
                    target: LatLng(position.latitude, position.longitude),
                    zoom: 15.0,
                  ),
                  onMapCreated: (GoogleMapController googleMapsController) {
                    if (!_googleMapController.isCompleted) {
                      _googleMapController.complete(googleMapsController);
                    }
                    _customInfoWindowController.googleMapController =
                        googleMapsController;
                  },
                  gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                    Factory<PanGestureRecognizer>(PanGestureRecognizer.new),
                  },
                  myLocationButtonEnabled: true,
                  myLocationEnabled: true,
                ),
                CustomInfoWindow(
                  controller: _customInfoWindowController,
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
                      padding: const EdgeInsets.all(5),
                      color: Colors.black,
                      child: TypeAheadField<CompanyModel>(
                        builder: (context, controller, focusNode) {
                          return TextField(
                            cursorColor: Colors.grey,
                            controller: controller,
                            focusNode: focusNode,
                            obscureText: false,
                            decoration: const InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.black, width: 1),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(),
                              hintText: 'Pesquise um estabelecimento',
                            ),
                            style: const TextStyle(fontSize: 12),
                          );
                        },
                        suggestionsCallback: (pattern) async {
                          if (pattern.isEmpty) return const <CompanyModel>[];
                          final term = pattern.toLowerCase();
                          return documents
                              .map(_tryParseCompany)
                              .whereType<CompanyModel>()
                              .where(
                                (c) =>
                                    c.nomeFantasia.toLowerCase().contains(term),
                              )
                              .toList();
                        },
                        itemBuilder: (context, suggestion) {
                          return ListTile(
                            leading: const FaIcon(
                              FontAwesomeIcons.building,
                              color: Colors.black,
                            ),
                            title: Text(suggestion.nomeFantasia),
                            subtitle: Text(suggestion.razaoSocial),
                          );
                        },
                        onSelected: gotoCompany,
                        loadingBuilder: (context) =>
                            const Text('Carregando...'),
                        errorBuilder: (context, error) =>
                            const Text('Ocorreu um erro ao carregar...'),
                        emptyBuilder: (context) => const Padding(
                          padding: EdgeInsets.all(10),
                          child: Text('Nenhum estabelecimento encontrado'),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          });
        },
      ),
      floatingActionButton: FloatingActionButton.small(
        onPressed: currentLocation,
        child: const Icon(Icons.my_location),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }

  Future<void> gotoCompany(CompanyModel companyModel) async {
    final controller = await _googleMapController.future;
    await controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          bearing: 192.8334901395799,
          target: LatLng(
            companyModel.geolocalizacao.lat,
            companyModel.geolocalizacao.lng,
          ),
          zoom: 18.0,
        ),
      ),
    );
  }

  Future<void> currentLocation() async {
    if (locationController.currentPosition.value == null) {
      await _requestLocationIfNeeded();
      return;
    }

    final controller = await _googleMapController.future;
    await controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          bearing: 192.8334901395799,
          target: LatLng(
            locationController.currentPosition.value!.latitude,
            locationController.currentPosition.value!.longitude,
          ),
          zoom: 18.0,
        ),
      ),
    );
  }
}
