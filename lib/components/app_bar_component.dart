import 'package:flutter/material.dart';
import 'package:university/core/utilities/styles.constants.dart';
import 'package:university/pages/landingPage/dashboard/dashboard_page.dart';
import 'package:university/pages/landingPage/units/units_page.dart';

appBarComponent() {
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
                mainAxisAlignment: MainAxisAlignment.center,
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
                      const SizedBox(width: 120),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) => const DashboardPage()),
                          );
                        },
                        child: const Text(
                          'Início',
                          style: textTitle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) => const UnitsPage()),
                          );
                        },
                        child: const Text(
                          'Unidades',
                          style: textTitle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      // TextButton(
                      //   onPressed: () {
                      //     // Navegação para Contato
                      //   },
                      //   child: const Text(
                      //     'Contato',
                      //     style: textTitle,
                      //   ),
                      // ),
                    ],
                  ),
                  // Row(
                  //   children: [
                  //     IconButton(
                  //       icon: const Icon(Icons.account_circle,
                  //           color: Colors.black),
                  //       onPressed: () {
                  //         // Ação de perfil
                  //       },
                  //     ),
                  //   ],
                  // ),
                ],
              ),
            ),
          );
        }
      },
    ),
  );
}
