import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/controllers/LocationController.dart';
import 'package:mobile/data/models/CategoryModel.dart';
import 'package:mobile/data/models/CompanyModel.dart';
import 'package:mobile/data/repositories/CategoryRepository.dart';
import 'package:mobile/data/repositories/CompanyRepository.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de empresas'),
        backgroundColor: defaultTheme[800],
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 15),
      ),
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(color: defaultTheme),
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
                        padding:
                            EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            textStyle: TextStyle(fontSize: 12),
                            foregroundColor: Colors.white,
                            backgroundColor:
                                defaultTheme, // Cor do texto (branco)
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero, // Borda reta
                            ),
                            padding: EdgeInsets.symmetric(
                                vertical: 2, horizontal: 15),
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
                                var entityCompany =
                                    CompanyModel.fromJson(docMap);
                                return Card(
                                  child: ListTile(
                                    contentPadding: EdgeInsets.all(15),
                                    leading: (entityCompany.foto != "")
                                        ? Image.network(entityCompany.foto)
                                        : Image.asset(
                                            'lib/ui/assets/logo-round.png'),
                                    title: Text(entityCompany.nomeFantasia),
                                    subtitle: !entityCompany.isOnline
                                        ? Text(
                                            '${entityCompany.endereco}, ${entityCompany.numero}  ${entityCompany.bairro} - ${entityCompany.municipio}/${entityCompany.uf}')
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
      ),
    );
  }
}
