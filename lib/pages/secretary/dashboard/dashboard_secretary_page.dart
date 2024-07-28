import 'package:flutter/material.dart';
import 'package:university/components/app_bar_secretary_component.dart';
import 'package:university/components/card_count.dart';
import 'package:university/components/drawer_component.dart';
import 'package:university/components/footer.dart';
import 'package:university/services/auth_service.dart';

class DashboardSecretaryPage extends StatefulWidget {
  const DashboardSecretaryPage({super.key});

  @override
  State<DashboardSecretaryPage> createState() => _DashboardSecretaryPageState();
}

class _DashboardSecretaryPageState extends State<DashboardSecretaryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarSecretaryComponent(name: AuthService().currentUser?.name),
      drawer: const DrawerComponent(),
      body: SingleChildScrollView(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            bool isSmallScreen = constraints.maxWidth < 600;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: isSmallScreen
                      ? Column(
                          children: cardBuild(),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: cardBuild(),
                        ),
                ),
                const Footer()
              ],
            );
          },
        ),
      ),
    );
  }
}

List<Widget> cardBuild() {
  return const [
    CardCount(
      count: '16',
      typeCount: 'Alunos Ativos',
      color: Colors.blue,
    ),
    SizedBox(width: 15, height: 15), // Ajuste de espaçamento
    CardCount(
      count: '16',
      typeCount: 'Professores Ativos',
      color: Colors.purple,
    ),
    SizedBox(width: 15, height: 15), // Ajuste de espaçamento
    CardCount(
      count: '16',
      typeCount: 'Turmas Ativas',
      color: Colors.pinkAccent,
    ),
  ];
}
