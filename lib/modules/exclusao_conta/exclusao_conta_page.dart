import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:mobile/modules/exclusao_conta/exclusao_conta_controller.dart';

class ExclusaoContaPage extends GetView<ExclusaoContaController> {
  const ExclusaoContaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Exclusão de Conta'),
        backgroundColor: Colors.black,
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                border: Border.all(color: Colors.red.shade200),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  FaIcon(
                    FontAwesomeIcons.triangleExclamation,
                    color: Colors.red,
                    size: 24,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Atenção: Esta ação é irreversível',
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            Text(
              'O que será excluído:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            _buildItemExclusao(
              FontAwesomeIcons.coins,
              'Histórico de Cashback',
              'Todos os cashbacks recebidos e utilizados',
            ),
            SizedBox(height: 12),
            _buildItemExclusao(
              FontAwesomeIcons.mapLocationDot,
              'Check-ins Realizados',
              'Histórico de visitas aos estabelecimentos',
            ),
            SizedBox(height: 12),
            _buildItemExclusao(
              FontAwesomeIcons.user,
              'Dados Pessoais',
              'Informações do perfil e preferências',
            ),
            SizedBox(height: 12),
            _buildItemExclusao(
              FontAwesomeIcons.userXmark,
              'Conta de Usuário',
              'Acesso ao aplicativo será removido',
            ),
            SizedBox(height: 32),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Importante:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• Esta ação não pode ser desfeita\n'
                    '• Todos os dados serão permanentemente excluídos\n'
                    '• Você perderá todo o saldo de cashback disponível\n'
                    '• Será necessário criar uma nova conta para usar o app novamente',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => controller.mostrarDialogoConfirmacao(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FaIcon(
                      FontAwesomeIcons.trash,
                      size: 18,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Excluir Minha Conta',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildItemExclusao(IconData icon, String titulo, String descricao) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.red.shade100,
            borderRadius: BorderRadius.circular(6),
          ),
          child: FaIcon(
            icon,
            color: Colors.red.shade600,
            size: 16,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              Text(
                descricao,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
