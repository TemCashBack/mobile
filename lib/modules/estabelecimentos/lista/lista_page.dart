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
import 'package:mobile/ui/widgets/company_bottom_sheet.dart';
import 'package:mobile/ui/widgets/progress_indicator_custom.dart';

class ListaPage extends GetView<ListaController> {
  const ListaPage({super.key});

  @override
  Widget build(BuildContext context) {
    final locationController = Get.find<LocationController>();
    TextEditingController searchController = TextEditingController();
    List<DocumentSnapshot> empresas = [];
    final categoriesRepository = CategoryRepository();
    final companiesRepository = CompanyRepository();
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(color: Colors.black),
          padding: EdgeInsets.all(5),
          child: TextField(
            cursorColor: Colors.grey,
            controller: searchController,
            onChanged: (text) {
              controller.term.value = text;
              controller.category.value = '';
            },
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
          ),
        ),
        Container(
          decoration: const BoxDecoration(color: Colors.black),
          padding: const EdgeInsets.fromLTRB(5, 0, 5, 5),
          child: StreamBuilder<QuerySnapshot>(
            stream: categoriesRepository.getAllCategories(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Center(child: ProgressIndicatorCustom()),
                );
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const SizedBox.shrink();
              }

              final categoryItems = snapshot.data!.docs.map((doc) {
                final json = jsonEncode(doc.data());
                final docMap = jsonDecode(json) as Map<String, dynamic>;
                return CategoryModel.fromJson(docMap);
              }).toList();

              return Obx(
                () => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: controller.category.value.isEmpty
                          ? null
                          : controller.category.value,
                      isExpanded: true,
                      hint: const Text(
                        'Filtrar por categoria',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black87,
                      ),
                      dropdownColor: Colors.white,
                      items: [
                        const DropdownMenuItem<String>(
                          value: '',
                          child: Text(
                            'Todas as categorias',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                        ...categoryItems.map(
                          (category) => DropdownMenuItem<String>(
                            value: category.description,
                            child: Text(
                              category.description,
                              style: const TextStyle(fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        controller.category.value = value ?? '';
                        if (value != null && value.isNotEmpty) {
                          controller.term.value = '';
                          searchController.clear();
                        }
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: StreamBuilder<QuerySnapshot>(
              stream: companiesRepository.getAllCompanies(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: ProgressIndicatorCustom(),
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
