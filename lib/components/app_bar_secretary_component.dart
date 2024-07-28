import 'package:flutter/material.dart';

appBarSecretaryComponent() {
  return PreferredSize(
    preferredSize: const Size.fromHeight(80.0), // Altura da AppBar
    child: LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          // Tamanho de tela para celular
          return AppBar(
            backgroundColor: Colors.white,
            elevation: 1,
            leading: Builder(
              builder: (context) {
                return IconButton(
                  icon: const Icon(Icons.menu, color: Colors.black),
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                );
              },
            ),
            title: SizedBox(
              height: 60,
              child: Image.asset(
                "assets/images/annamery.png",
                fit: BoxFit.cover,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.account_circle, color: Colors.black),
                onPressed: () {
                  // Ação de perfil
                },
              ),
            ],
          );
        } else {
          // Tamanho de tela para desktop
          return AppBar(
            backgroundColor: Colors.white,
            elevation: 1,
            title: Transform.translate(
              offset: const Offset(0, 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        height: 60,
                        child: Image.asset(
                          "assets/images/annamery.png",
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Text(
                        'Admin fulano ',
                        style: TextStyle(fontSize: 16),
                      ),
                      IconButton(
                        icon: const Icon(Icons.account_circle,
                            size: 34, color: Colors.black),
                        onPressed: () {
                          // Ação de perfil
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }
      },
    ),
  );
}
