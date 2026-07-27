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
    final categoriesRepository = Get.find<CategoryRepository>();
    final companiesRepository = Get.find<CompanyRepository>();

    return ColoredBox(
      color: AppColors.background,
      child: Column(
        children: [
          _ListaHeader(
            controller: controller,
            categoriesRepository: categoriesRepository,
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: companiesRepository.getAllCompanies(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: ProgressIndicatorCustom());
                }

                if (!snapshot.hasData) {
                  return const AppEmptyState(
                    message: 'Nenhum estabelecimento encontrado.',
                  );
                }

                return Obx(() {
                  var empresas = snapshot.data!.docs;

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
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const AppEmptyState(
                          message:
                              'Nenhum resultado para os filtros selecionados.',
                        ),
                        TextButton(
                          onPressed: controller.clearFilters,
                          child: const Text('Limpar filtros'),
                        ),
                      ],
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      AppSpacing.sm,
                      AppSpacing.md,
                      AppSpacing.lg,
                    ),
                    itemCount: empresas.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      final item = empresas[index];
                      final json = jsonEncode(item.data());
                      final docMap =
                          jsonDecode(json) as Map<String, dynamic>;
                      final company = CompanyModel.fromJson(docMap);

                      return _CompanyListTile(
                        company: company,
                        onTap: () {
                          CompanyBottomSheet(context: context).showCompany(
                            item.id,
                            company,
                            locationController.currentPosition.value,
                          );
                        },
                      );
                    },
                  );
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ListaHeader extends StatelessWidget {
  const _ListaHeader({
    required this.controller,
    required this.categoriesRepository,
  });

  final ListaController controller;
  final CategoryRepository categoriesRepository;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.header,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.sm,
            ),
            child: TextField(
              controller: controller.searchController,
              onChanged: controller.onSearchChanged,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Buscar estabelecimento',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: Obx(() {
                  if (controller.term.value.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return IconButton(
                    tooltip: 'Limpar busca',
                    onPressed: controller.clearSearch,
                    icon: const Icon(Icons.close_rounded),
                  );
                }),
              ),
            ),
          ),
          StreamBuilder<QuerySnapshot>(
            stream: categoriesRepository.getAllCategories(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.only(bottom: AppSpacing.md),
                  child: Center(child: ProgressIndicatorCustom()),
                );
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const SizedBox(height: AppSpacing.sm);
              }

              final categories = snapshot.data!.docs.map((doc) {
                final json = jsonEncode(doc.data());
                final docMap = jsonDecode(json) as Map<String, dynamic>;
                return CategoryModel.fromJson(docMap);
              }).toList();

              return Obx(
                () => _CategoryFilterBar(
                  categories: categories,
                  selected: controller.category.value,
                  onSelected: controller.selectCategory,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CategoryFilterBar extends StatelessWidget {
  const _CategoryFilterBar({
    required this.categories,
    required this.selected,
    required this.onSelected,
  });

  final List<CategoryModel> categories;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text(
            'Categorias',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            children: [
              _CategoryChip(
                label: 'Todas',
                selected: selected.isEmpty,
                onTap: () => onSelected(''),
              ),
              const SizedBox(width: AppSpacing.sm),
              ...categories.map(
                (category) => Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: _CategoryChip(
                    label: category.description,
                    selected: selected == category.description,
                    onTap: () => onSelected(category.description),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? secondaryThemeColor : Colors.white.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(
              color: selected
                  ? secondaryThemeColor.shade300
                  : Colors.white.withValues(alpha: 0.18),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? AppColors.textPrimary : Colors.white,
              fontSize: 13,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class _CompanyListTile extends StatelessWidget {
  const _CompanyListTile({
    required this.company,
    required this.onTap,
  });

  final CompanyModel company;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final address = company.isOnline
        ? 'Serviço on-line'
        : '${company.endereco}, ${company.numero}';
    final city = company.isOnline
        ? null
        : '${company.municipio}/${company.uf}';

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.divider),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              _CompanyThumb(foto: company.foto),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      company.nomeFantasia,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      address,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        height: 1.3,
                      ),
                    ),
                    if (city != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        city,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _MetaChip(
                          icon: company.isOnline
                              ? Icons.language_rounded
                              : Icons.storefront_rounded,
                          label: company.isOnline ? 'On-line' : 'Física',
                          color: company.isOnline
                              ? primaryThemeColor
                              : secondaryThemeColor,
                        ),
                        if (company.categoria.isNotEmpty)
                          _MetaChip(
                            icon: Icons.category_outlined,
                            label: company.categoria,
                            color: primaryThemeColor,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Icon(
                Icons.chevron_right_rounded,
                color: primaryThemeColor.shade600,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompanyThumb extends StatelessWidget {
  const _CompanyThumb({required this.foto});

  final String foto;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.md),
        color: AppColors.background,
        border: Border.all(color: AppColors.divider),
      ),
      clipBehavior: Clip.antiAlias,
      child: foto.isNotEmpty
          ? Image.network(
              foto,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Image.asset(
                'lib/ui/assets/logo-round.png',
                fit: BoxFit.cover,
              ),
            )
          : Image.asset(
              'lib/ui/assets/logo-round.png',
              fit: BoxFit.cover,
            ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final MaterialColor color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color.shade800),
          const SizedBox(width: 4),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 120),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color.shade800,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
