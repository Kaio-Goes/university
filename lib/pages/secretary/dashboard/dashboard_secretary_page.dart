import 'package:flutter/material.dart';
import 'package:university/components/app_bar_secretary_component.dart';
import 'package:university/components/card_count.dart';
import 'package:university/components/drawer_secretary_component.dart';
import 'package:university/components/footer.dart';
import 'package:university/core/models/user_teacher.dart';
import 'package:university/services/auth_service.dart';
import 'package:university/services/teacher_service.dart';

class DashboardSecretaryPage extends StatefulWidget {
  const DashboardSecretaryPage({super.key});

  @override
  State<DashboardSecretaryPage> createState() => _DashboardSecretaryPageState();
}

class _DashboardSecretaryPageState extends State<DashboardSecretaryPage> {
  List<UserTeacher> teachers = [];

  @override
  void initState() {
    super.initState();
    _loadTeachers();
  }

  Future<void> _loadTeachers() async {
    try {
      List<UserTeacher> fetchedTeachers =
          await TeacherService().getAllTeacher();
      setState(() {
        teachers = fetchedTeachers;
      });
    } catch (e) {
      // print('Erro ao carregar professores: $e');
    }
  }

  @override
  void dispose() {
    super.dispose();
    teachers.clear(); // Limpar a lista ao sair da página
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarSecretaryComponent(name: AuthService().currentUser?.name),
      drawer: const DrawerSecretaryComponent(),
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
                          children: cardBuild(
                              countTeacher: teachers.length.toString()),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: cardBuild(
                              countTeacher: teachers.length.toString()),
                        ),
                ),
                Text(teachers.length
                    .toString()), // Exibe o número de professores
                const Footer()
              ],
            );
          },
        ),
      ),
    );
  }
}

List<Widget> cardBuild({required String countTeacher}) {
  return [
    const CardCount(
      count: '16',
      typeCount: 'Alunos Ativos',
      color: Colors.blue,
    ),
    const SizedBox(width: 15, height: 15), // Ajuste de espaçamento
    CardCount(
      count: countTeacher,
      typeCount: 'Professores Ativos',
      color: Colors.purple,
    ),
    const SizedBox(width: 15, height: 15), // Ajuste de espaçamento
    const CardCount(
      count: '16',
      typeCount: 'Turmas Ativas',
      color: Colors.pinkAccent,
    ),
  ];
}
