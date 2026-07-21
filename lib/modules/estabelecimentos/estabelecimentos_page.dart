import 'package:flutter/material.dart';
import 'package:mobile/modules/estabelecimentos/lista/lista_page.dart';
import 'package:mobile/modules/estabelecimentos/mapa/mapa_page.dart';
import 'package:mobile/ui/theme/colors.dart';
import 'package:mobile/ui/widgets/drawer_custom.dart';

class EstabelecimentosPage extends StatelessWidget {
  const EstabelecimentosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
          drawer: CustomDrawer(),
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Row(
              children: [
                Image.asset(
                  'lib/ui/assets/logo.png',
                  height: 40,
                ),
              ],
            ),
            actions: [
              Builder(
                builder: (context) => IconButton(
                  icon: Icon(Icons.menu), // Ícone de notificações
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                ),
              )
            ],
            backgroundColor: Colors.black,
            titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
            iconTheme: IconThemeData(
              color: Colors.white, // Cor do ícone do Drawer
            ),
          ),
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
                  color: Colors.black,
                  child: TabBar(
                    indicatorColor: Colors.white,
                    labelColor: secondaryThemeColor,
                    unselectedLabelColor: Colors.white,
                    tabs: const [
                      Tab(
                        text: 'Mapa',
                        icon: Icon(Icons.map_outlined),
                      ),
                      Tab(
                        text: 'Lista',
                        icon: Icon(Icons.list),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          )),
    );
  }
}
