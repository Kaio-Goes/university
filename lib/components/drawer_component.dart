import 'package:flutter/material.dart';
import 'package:university/pages/landingPage/dashboard/dashboard_page.dart';
import 'package:university/pages/landingPage/units/units_page.dart';

class DrawerComponent extends StatelessWidget {
  const DrawerComponent({super.key});

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
                  builder: (context) => const DashboardPage()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.business),
            title: const Text('Unidades'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const UnitsPage()),
              );
            },
          ),
          const SizedBox(height: 320),
          ListTile(
            leading: const Icon(Icons.account_circle_rounded),
            title: const Text('Área do Aluno'),
            onTap: () {
              // Navegação para Contato
              Navigator.pop(context); // Fecha o drawer
            },
          ),
          ListTile(
            leading: const Icon(Icons.store_mall_directory_outlined),
            title: const Text('Área da Secretaria'),
            onTap: () {
              // Navegação para Contato
              Navigator.pop(context); // Fecha o drawer
            },
          ),
        ],
      ),
    );
  }
}
