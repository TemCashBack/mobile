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
            title: Text('Tem Cashback'),
            backgroundColor: primaryThemeColor,
            titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
            iconTheme: IconThemeData(
              color: Colors.white, // Cor do ícone do Drawer
            ),
          ),
          bottomNavigationBar: Container(
            constraints: BoxConstraints(maxHeight: 60.0),
            child: Material(
              color: primaryThemeColor[800],
              child: TabBar(
                labelColor: Colors.purple[100],
                unselectedLabelColor: Colors.white,
                tabs: [
                  Tab(
                    text: 'Lista',
                    icon: Icon(Icons.list),
                  ),
                  Tab(
                    text: 'Mapa',
                    icon: Icon(Icons.map_outlined),
                  )
                ],
              ),
            ),
          ),
          body: TabBarView(
            physics: NeverScrollableScrollPhysics(),
            children: [ListaPage(), MapaPage()],
          )),
    );
  }
}
