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
import 'package:mobile/ui/theme/app_styles.dart';
import 'package:mobile/ui/theme/colors.dart';
import 'package:mobile/ui/widgets/app_section_title.dart';
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
          color: AppColors.header,
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Column(
            children: [
              TextField(
                controller: searchController,
                onChanged: (text) {
                  controller.term.value = text;
                  controller.category.value = '';
                },
                decoration: const InputDecoration(
                  hintText: 'Pesquise um estabelecimento',
                  prefixIcon: Icon(Icons.search_rounded),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              StreamBuilder<QuerySnapshot>(
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
                    () => InputDecorator(
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.surface,
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: controller.category.value.isEmpty
                              ? null
                              : controller.category.value,
                          isExpanded: true,
                          hint: const Text('Filtrar por categoria'),
                          items: [
                            const DropdownMenuItem<String>(
                              value: '',
                              child: Text('Todas as categorias'),
                            ),
                            ...categoryItems.map(
                              (category) => DropdownMenuItem<String>(
                                value: category.description,
                                child: Text(
                                  category.description,
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
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: companiesRepository.getAllCompanies(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: ProgressIndicatorCustom());
              }

              if (!snapshot.hasData) {
                return const AppEmptyState(message: 'Nenhum estabelecimento encontrado.');
              }

              return Obx(() {
                empresas = snapshot.data!.docs;
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
                        .contains(controller.category.value.toLowerCase());
                  }).toList();
                }

                if (empresas.isEmpty) {
                  return const AppEmptyState(
                    message: 'Nenhum resultado para os filtros selecionados.',
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 16),
                  itemCount: empresas.length,
                  itemBuilder: (context, index) {
                    final item = empresas[index];
                    final json = jsonEncode(item.data());
                    final docMap = jsonDecode(json) as Map<String, dynamic>;
                    final entityCompany = CompanyModel.fromJson(docMap);

                    return Card(
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(14),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                          child: entityCompany.foto.isNotEmpty
                              ? Image.network(
                                  entityCompany.foto,
                                  height: 48,
                                  width: 48,
                                  fit: BoxFit.cover,
                                )
                              : Image.asset(
                                  'lib/ui/assets/logo-round.png',
                                  height: 48,
                                  width: 48,
                                  fit: BoxFit.cover,
                                ),
                        ),
                        title: Text(
                          entityCompany.nomeFantasia,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            entityCompany.isOnline
                                ? 'Serviço on-line'
                                : '${entityCompany.endereco}, ${entityCompany.numero} • ${entityCompany.municipio}/${entityCompany.uf}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                        trailing: Icon(
                          Icons.chevron_right_rounded,
                          color: primaryThemeColor.shade600,
                        ),
                        onTap: () {
                          CompanyBottomSheet(context: context).showCompany(
                            entityCompany.id,
                            entityCompany,
                            locationController.currentPosition.value,
                          );
                        },
                      ),
                    );
                  },
                );
              });
            },
          ),
        ),
      ],
    );
  }
}
