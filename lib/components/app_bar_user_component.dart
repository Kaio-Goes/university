import 'package:flutter/material.dart';
import 'package:university/core/models/user_firebase.dart';
import 'package:university/pages/landingPage/dashboard/dashboard_page.dart';
import 'package:university/core/services/auth_user_service.dart';

appBarUserComponent({UserFirebase? userFirebase, Widget? leading}) {
  return PreferredSize(
    preferredSize: const Size.fromHeight(80.0), // Altura da AppBar
    child: LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          // Tamanho de tela para celular
          return AppBar(
            backgroundColor: Colors.white,
            elevation: 1,
            leading: leading,
            title: SizedBox(
              height: 60,
              child: Image.asset(
                "assets/images/annamery.png",
                fit: BoxFit.cover,
              ),
            ),
            actions: [
              Row(
                children: [
                  Text(
                    userFirebase != null
                        ? userFirebase.role == "admin"
                            ? 'Admin ${userFirebase.name} '
                            : userFirebase.role == "teacher"
                                ? 'Professor ${userFirebase.name}'
                                : 'Aluno ${userFirebase.name}'
                        : "Não logado",
                    style: const TextStyle(fontSize: 16),
                  ),
                  PopupMenuButton<int>(
                    icon: const Icon(Icons.account_circle, color: Colors.black),
                    onSelected: (int result) async {
                      if (result == 0) {
                        AuthUserService().logout();
                        Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (context) => const DashboardPage()),
                            (Route<dynamic> route) => false);
                      }
                    },
                    itemBuilder: (BuildContext context) =>
                        <PopupMenuEntry<int>>[
                      const PopupMenuItem<int>(
                        value: 0,
                        child: ListTile(
                          leading: Icon(
                            Icons.exit_to_app,
                            color: Colors.red,
                          ),
                          title: Text('Sair'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          );
        } else {
          // Tamanho de tela para desktop
          return AppBar(
            backgroundColor: Colors.white,
            elevation: 1,
            leading: leading,
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
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        userFirebase != null
                            ? userFirebase.role == "admin"
                                ? 'Admin ${userFirebase.name} '
                                : userFirebase.role == "teacher"
                                    ? 'Professor ${userFirebase.name}'
                                    : 'Aluno ${userFirebase.name}'
                            : "Não logado",
                        style: const TextStyle(fontSize: 16),
                      ),
                      PopupMenuButton<int>(
                        icon: const Icon(Icons.account_circle,
                            size: 34, color: Colors.black),
                        onSelected: (int result) async {
                          if (result == 0) {
                            AuthUserService().logout();
                            // ignore: use_build_context_synchronously
                            Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const DashboardPage()),
                                (Route<dynamic> route) => false);
                          }
                        },
                        itemBuilder: (BuildContext context) =>
                            <PopupMenuEntry<int>>[
                          const PopupMenuItem<int>(
                            value: 0,
                            child: ListTile(
                              leading: Icon(
                                Icons.exit_to_app,
                                color: Colors.red,
                              ),
                              title: Text('Sair'),
                            ),
                          ),
                        ],
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
