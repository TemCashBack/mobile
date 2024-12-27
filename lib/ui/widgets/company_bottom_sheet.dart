import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:mobile/controllers/MapsAvalibleController.dart';
import 'package:mobile/controllers/UserController.dart';
import 'package:mobile/data/models/CompanyModel.dart';
import 'package:mobile/data/repositories/CheckinRepository.dart';
import 'package:mobile/ui/widgets/buttons/CheckinButton.dart';
import 'package:mobile/ui/widgets/buttons/DriveToButton.dart';
import 'package:mobile/ui/widgets/buttons/PhoneButton.dart';
import 'package:url_launcher/url_launcher.dart';

class CompanyBottomSheet {
  BuildContext context;
  final userController = Get.put(UserController());
  MapsAvalibleController mapsAvalibleController =
      Get.put(MapsAvalibleController());

  CompanyBottomSheet({required this.context});

  double distance = 0.0;

  showAlert(String mensagem) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(
          'ATENÇÃO',
          textAlign: TextAlign.center,
        ),
        content: Text(
          mensagem,
          textAlign: TextAlign.center,
        ),
        actions: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, 'OK'),
                    child: const Text('OK'),
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
            height: MediaQuery.of(context).size.height * 0.80,
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
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 2),
                              child: !companyModel.isOnline
                                  ? Text(
                                      '${companyModel.endereco}, ${companyModel.numero} ')
                                  : Text('Serviço on-line'),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 2),
                              child: !companyModel.isOnline
                                  ? Text(
                                      '${companyModel.bairro} - ${companyModel.municipio}/${companyModel.uf}')
                                  : Text(''),
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
                Container(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  width: MediaQuery.of(context).size.width,
                  child: companyModel.discounts.length > 1
                      ? Text(
                          'Nossos Descontos',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        )
                      : Text(
                          'Nosso desconto',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                ),
                Expanded(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemBuilder: (BuildContext context, int index) {
                      return Text(companyModel.discounts[index]);
                    },
                    itemCount: companyModel.discounts.length,
                    separatorBuilder: (BuildContext context, int index) {
                      return Divider();
                    },
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      CheckinButton(
                        onPressed: () =>
                            _calcDistance(id, companyModel, currentLocation),
                      ),
                      if (!companyModel.isOnline) ...[
                        for (var map
                            in mapsAvalibleController.availableMaps.value ??
                                []) ...[
                          DriveToButton(
                            onPressed: () => map.showMarker(
                              coords: Coords(companyModel.geolocalizacao.lat,
                                  companyModel.geolocalizacao.lng),
                              title: companyModel.nomeFantasia,
                              description: companyModel.categoria,
                            ),
                          )
                        ]
                      ],
                      if (companyModel.telefones.isNotEmpty) ...[
                        PhoneButton(
                            onPressed: () => {
                                  launchUrl(Uri.http(
                                      'tel://${companyModel.telefones[0]}'))
                                })
                      ]
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
    CheckinRepository checkinRepository = CheckinRepository();
    distance = Geolocator.distanceBetween(
        currentLocation.latitude,
        currentLocation.longitude,
        modelCompany.geolocalizacao.lat,
        modelCompany.geolocalizacao.lng);
    if (distance > 10) {
      mensagem = 'Você deve estar mais próximo para efetuar o check-in.';
      await showAlert(mensagem);
    } else {
      // logica de como deve fazer o filtro e validade
      // pode-se fazer até 3 checkin no mesmo lugar no mesmo dia
      var qtd = await checkinRepository.getCheckIns(
          id, userController.user.uid, DateTime.now());
      if (qtd < 1) {
        await checkinRepository.addCheckin(
            id, userController.user.uid, DateTime.now());
        mensagem = 'Checkin feito';
        await showAlert(mensagem);
      } else {
        mensagem = 'Você já fez checkin hoje!';
        await showAlert(mensagem);
      }
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
