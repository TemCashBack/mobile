import 'package:flutter/material.dart';
import 'package:mobile/modules/estabelecimentos/lista/lista_page.dart';
import 'package:mobile/modules/estabelecimentos/mapa/mapa_page.dart';
import 'package:mobile/ui/theme/app_styles.dart';
import 'package:mobile/ui/widgets/app_app_bar.dart';
import 'package:mobile/ui/widgets/drawer_custom.dart';

class EstabelecimentosPage extends StatelessWidget {
  const EstabelecimentosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        drawer: CustomDrawer(),
        appBar: AppLogoAppBar(actions: [AppLogoAppBar.menuButton(context)]),
        body: Column(
          children: [
            Expanded(
              child: TabBarView(
                physics: const NeverScrollableScrollPhysics(),
                children: const [
                  MapaPage(),
                  ListaPage(),
                ],
              ),
            ),
            SafeArea(
              top: false,
              child: Material(
                color: AppColors.header,
                child: TabBar(
                  tabs: const [
                    Tab(text: 'Mapa', icon: Icon(Icons.map_outlined, size: 20)),
                    Tab(text: 'Lista', icon: Icon(Icons.list_rounded, size: 20)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
