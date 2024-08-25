import 'package:flutter/material.dart';
import 'package:university/pages/landingPage/dashboard/dashboard_page.dart';
import 'package:university/pages/secretary/class_create_page.dart';
import 'package:university/pages/secretary/dashboard/dashboard_secretary_page.dart';
import 'package:university/pages/secretary/student_create_page.dart';
import 'package:university/pages/secretary/teacher_create_page.dart';
import 'package:university/services/auth_secretary_service.dart';

class DrawerSecretaryComponent extends StatelessWidget {
  const DrawerSecretaryComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue[300],
            ),
            child: const Text(
              'Menu',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Início'),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const DashboardSecretaryPage()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.school),
            title: const Text('Cadastrar Turmas'),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const ClassCreatePage()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.person_add_alt_1),
            title: const Text('Cadastrar Professor'),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const TeacherCreatePage()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.person_add_alt),
            title: const Text('Cadastrar Aluno'),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const StudantCreatePage()));
            },
          ),
          const SizedBox(height: 230),
          ListTile(
            leading: const Icon(
              Icons.exit_to_app,
              color: Colors.red,
            ),
            title: const Text('Sair'),
            onTap: () async {
              AuthSecretaryService().logout();
              // ignore: use_build_context_synchronously
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                      builder: (context) => const DashboardPage()),
                  (Route<dynamic> route) => false);
            },
          ),
        ],
      ),
    );
  }
}
