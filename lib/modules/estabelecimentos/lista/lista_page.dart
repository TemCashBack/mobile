import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/controllers/location_controller.dart';
import 'package:mobile/data/models/category_model.dart';
import 'package:mobile/data/models/company_model.dart';
import 'package:mobile/data/repositories/category_repository.dart';
import 'package:mobile/data/repositories/company_repository.dart';
import 'package:mobile/modules/estabelecimentos/lista/lista_controller.dart';
import 'package:mobile/ui/theme/colors.dart';
import 'package:mobile/ui/widgets/company_bottom_sheet.dart';

class ListaPage extends StatelessWidget {
  const ListaPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ListaController controller = Get.put(ListaController());
    final LocationController locationController = Get.put(LocationController());
    TextEditingController searchController = TextEditingController();
    List<DocumentSnapshot> empresas = [];
    List<DocumentSnapshot> categories = [];
    final categoriesRepository = CategoryRepository();
    final companiesRepository = CompanyRepository();
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(color: primaryThemeColor),
          padding: EdgeInsets.all(5),
          child: TextField(
            controller: searchController,
            onChanged: (text) {
              controller.term.value = text;
              controller.category.value = '';
            },
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(),
              hintText: 'Pesquise um estabelecimento',
            ),
            style: TextStyle(fontSize: 12),
          ),
        ),
        Expanded(
          flex: 1,
          child: StreamBuilder(
            stream: categoriesRepository.getAllCategories(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: CircularProgressIndicator(),
                  ),
                );
              } else {
                categories = snapshot.data!.docs;
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (BuildContext context, int index) {
                    DocumentSnapshot item = categories[index];
                    String json = jsonEncode(item.data());
                    Map<String, dynamic> docMap = jsonDecode(json);
                    var entityCategory = CategoryModel.fromJson(docMap);
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          textStyle: TextStyle(fontSize: 12),
                          foregroundColor: Colors.white,
                          backgroundColor:
                              primaryThemeColor, // Cor do texto (branco)
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero, // Borda reta
                          ),
                          padding:
                              EdgeInsets.symmetric(vertical: 2, horizontal: 15),
                        ),
                        onPressed: () {
                          controller.category.value =
                              entityCategory.description;
                          controller.term.value = '';
                        },
                        child: Text(entityCategory.description),
                      ),
                    );
                  },
                  itemCount: categories.length,
                );
              }
            },
          ),
        ),
        Expanded(
          flex: 11,
          child: SingleChildScrollView(
            child: StreamBuilder<QuerySnapshot>(
              stream: companiesRepository.getAllCompanies(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: CircularProgressIndicator(),
                    ),
                  );
                } else {
                  if (snapshot.hasData) {
                    return Obx(() {
                      empresas = snapshot.data!.docs;
                      //Search
                      if (controller.term.value.isNotEmpty) {
                        empresas = empresas.where((element) {
                          return element
                              .get('nomeFantasia')
                              .toString()
                              .toLowerCase()
                              .contains(controller.term.value.toLowerCase());
                        }).toList();
                      }
                      if (controller.category.value.isNotEmpty) {
                        empresas = empresas.where((element) {
                          return element
                              .get('categoria')
                              .toString()
                              .toLowerCase()
                              .contains(
                                  controller.category.value.toLowerCase());
                        }).toList();
                      }

                      if (empresas.isNotEmpty) {
                        return ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemBuilder: (BuildContext context, int index) {
                              DocumentSnapshot item = empresas[index];
                              String json = jsonEncode(item.data());
                              Map<String, dynamic> docMap = jsonDecode(json);
                              var entityCompany = CompanyModel.fromJson(docMap);
                              return Card(
                                child: ListTile(
                                  contentPadding:
                                      EdgeInsets.fromLTRB(20, 0, 20, 0),
                                  leading: (entityCompany.foto != "")
                                      ? Image.network(
                                          entityCompany.foto,
                                          height: 40,
                                        )
                                      : Image.asset(
                                          'lib/ui/assets/logo-round.png',
                                          height: 40,
                                        ),
                                  title: Text(
                                    entityCompany.nomeFantasia,
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  subtitle: !entityCompany.isOnline
                                      ? Text(
                                          '${entityCompany.endereco}, ${entityCompany.numero}  ${entityCompany.bairro} - ${entityCompany.municipio}/${entityCompany.uf}',
                                          style: TextStyle(fontSize: 10),
                                        )
                                      : Text('Serviço on-line'),
                                  onTap: () {
                                    CompanyBottomSheet(context: context)
                                        .showCompany(
                                            entityCompany.id,
                                            entityCompany,
                                            locationController
                                                .currentPosition.value);
                                  },
                                ),
                              );
                            },
                            itemCount: empresas.length);
                      } else {
                        return Text('Nada encontrado!');
                      }
                    });
                  } else {
                    return Text('Nada encontrado!');
                  }
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}
