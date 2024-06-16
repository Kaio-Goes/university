import 'package:flutter/material.dart';

class DrawerComponent extends StatelessWidget {
  const DrawerComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text(
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
              // Navegação para Home
              Navigator.pop(context); // Fecha o drawer
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('Sobre'),
            onTap: () {
              // Navegação para Sobre
              Navigator.pop(context); // Fecha o drawer
            },
          ),
          ListTile(
            leading: const Icon(Icons.contact_mail),
            title: const Text('Contato'),
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
