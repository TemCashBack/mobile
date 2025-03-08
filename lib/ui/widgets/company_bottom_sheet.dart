import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:mobile/controllers/auth_controller.dart';
import 'package:mobile/controllers/maps_avalible_controller.dart';
import 'package:mobile/data/models/company_model.dart';
import 'package:mobile/modules/cashback/cashback_controller.dart';
import 'package:mobile/routes/app_routes.dart';
import 'package:mobile/ui/theme/colors.dart';
import 'package:mobile/ui/widgets/buttons/PhoneButton.dart';
import 'package:mobile/ui/widgets/buttons/informar_compra_button.dart';
import 'package:mobile/ui/widgets/progress_indicator_custom.dart';
import 'package:url_launcher/url_launcher.dart';

class CompanyBottomSheet {
  BuildContext context;
  AuthController authController = Get.find<AuthController>();
  MapsAvalibleController mapsAvalibleController =
      Get.put(MapsAvalibleController());

  CompanyBottomSheet({required this.context});

  double distance = 0.0;

  CashbackController cashbackController = Get.put(CashbackController());

  showAlert(String mensagem) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(
          'ATENÇÃO',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.black),
        ),
        content: Text(mensagem,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black, fontSize: 16)),
        actions: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, 'OK'),
                    child: const Text(
                      'OK',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              )
            ],
          )
        ],
      ),
    );
  }

  void showCompany(
      String id, CompanyModel companyModel, Position? currentLocation) {
    if (currentLocation != null) {
      showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (builder) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.40,
            padding: EdgeInsets.all(20),
            color: Colors.transparent,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 4,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: (companyModel.foto != "")
                                  ? Image.network(companyModel.foto,
                                      width: 70, height: 70, fit: BoxFit.fill)
                                  : Image.asset('lib/ui/assets/logo-round.png',
                                      width: 70, height: 70, fit: BoxFit.fill),
                            )
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 10,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 2),
                              child: Text(
                                companyModel.nomeFantasia,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: primaryThemeColor),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 2),
                              child: !companyModel.isOnline
                                  ? Text(
                                      '${companyModel.endereco}, ${companyModel.numero}',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: primaryThemeColor),
                                    )
                                  : Text('Serviço on-line',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: primaryThemeColor)),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 2),
                              child: !companyModel.isOnline
                                  ? Text(
                                      '${companyModel.bairro} - ${companyModel.municipio}/${companyModel.uf}',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: primaryThemeColor),
                                    )
                                  : Text(
                                      '',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: primaryThemeColor),
                                    ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (companyModel.socials.facebook != '') ...[
                                  IconButton(
                                      icon: FaIcon(FontAwesomeIcons.facebook),
                                      onPressed: () async {
                                        launchFacebook(
                                            companyModel.socials.facebook);
                                      }),
                                ],
                                if (companyModel.socials.instagram != '') ...[
                                  IconButton(
                                      icon: FaIcon(FontAwesomeIcons.instagram),
                                      onPressed: () async {
                                        launchInstagram(
                                            companyModel.socials.instagram);
                                      }),
                                ],
                                if (companyModel.socials.whatsapp != '') ...[
                                  IconButton(
                                      icon: FaIcon(FontAwesomeIcons.whatsapp),
                                      onPressed: () async {
                                        launchWhatsApp(
                                            companyModel.socials.whatsapp);
                                      }),
                                ],
                                if (companyModel.socials.linkedin != '') ...[
                                  IconButton(
                                      icon: FaIcon(FontAwesomeIcons.linkedin),
                                      onPressed: () async {
                                        launchLinkedin(
                                            companyModel.socials.linkedin);
                                      }),
                                ],
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      InformarCompraButton(
                        onPressed: () =>
                            _calcDistance(id, companyModel, currentLocation),
                      ),
                      if (companyModel.telefones.isNotEmpty) ...[
                        PhoneButton(
                            onPressed: () => {
                                  launchUrl(Uri.http(
                                      'tel://${companyModel.telefones[0]}'))
                                })
                      ],
                      FutureBuilder<List<AvailableMap>>(
                        future: MapLauncher.installedMaps,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(child: ProgressIndicatorCustom());
                          } else if (snapshot.hasError) {
                            return Center(
                                child: Text('Erro ao carregar mapas'));
                          } else if (!snapshot.hasData ||
                              snapshot.data!.isEmpty) {
                            return Center(
                                child: Text('Nenhum mapa disponível'));
                          }
                          final availableMaps = snapshot.data!;
                          return Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: availableMaps.map((map) {
                                return GestureDetector(
                                  onTap: () async {
                                    await map.showMarker(
                                      coords: Coords(
                                          companyModel.geolocalizacao.lat,
                                          companyModel.geolocalizacao.lng),
                                      title: companyModel.nomeFantasia,
                                    );
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(15),
                                      border: Border.all(
                                          color: primaryThemeColor, width: 1),
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.all(5),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          SvgPicture.asset(
                                            map.icon,
                                            width: 25,
                                            height: 25,
                                            placeholderBuilder: (context) =>
                                                ProgressIndicatorCustom(), // Placeholder enquanto carrega
                                          ),
                                          Text(
                                            map.mapName,
                                            style: TextStyle(fontSize: 10),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      );
    } else {
      showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (builder) {
          return Text('Não foi possivel utilizar a localização');
        },
      );
    }
  }

  void _calcDistance(
      String id, CompanyModel modelCompany, Position currentLocation) async {
    String mensagem;
    distance = Geolocator.distanceBetween(
        currentLocation.latitude,
        currentLocation.longitude,
        modelCompany.geolocalizacao.lat,
        modelCompany.geolocalizacao.lng);
    if (distance > 15) {
      mensagem = 'Você deve estar mais próximo para efetuar a compra.';
      await showAlert(mensagem);
    } else {
      cashbackController.setCompanyId(id);
      Get.toNamed(AppRoutes.CASHBACK);
    }
  }

  launchFacebook(String facebook) async {
    var url = 'https://www.facebook.com/$facebook/';

    if (await canLaunchUrl(Uri.https(url))) {
      await launchUrl(Uri.https(url));
    } else {
      throw 'There was a problem to open the url: $url';
    }
  }

  launchInstagram(String instagram) async {
    var url = 'https://www.instagram.com/$instagram/';
    if (await canLaunchUrl(Uri.https(url))) {
      await launchUrl(Uri.https(url));
    } else {
      throw 'There was a problem to open the url: $url';
    }
  }

  launchWhatsApp(String whatsapp) async {
    var url = 'https://api.whatsapp.com/send?phone=$whatsapp';
    if (await canLaunchUrl(Uri.https(url))) {
      await launchUrl(Uri.https(url));
    } else {
      throw 'There was a problem to open the url: $url';
    }
  }

  launchLinkedin(String linkedin) async {
    var url = linkedin;
    if (await canLaunchUrl(Uri.https(url))) {
      await launchUrl(Uri.https(url));
    } else {
      throw 'There was a problem to open the url: $url';
    }
  }
}
