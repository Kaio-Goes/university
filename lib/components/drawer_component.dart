import 'package:flutter/material.dart';
import 'package:university/pages/dashboard/dashboard_page.dart';
import 'package:university/pages/units/units_page.dart';

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
          // ListTile(
          //   leading: const Icon(Icons.contact_mail),
          //   title: const Text('Contato'),
          //   onTap: () {
          //     // Navegação para Contato
          //     Navigator.pop(context); // Fecha o drawer
          //   },
          // ),
        ],
      ),
    );
  }
}
