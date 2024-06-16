import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80.0), // Altura da AppBar
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          title: Transform.translate(
            offset: const Offset(0, 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Container(
                      height: 60,
                      child: Image.asset(
                        "assets/images/annamery.png",
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 120),
                    TextButton(
                      onPressed: () {
                        // Navegação para Home
                      },
                      child: const Text(
                        'Início',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    const SizedBox(width: 10),
                    TextButton(
                      onPressed: () {
                        // Navegação para Sobre
                      },
                      child: const Text(
                        'Sobre',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    const SizedBox(width: 10),
                    TextButton(
                      onPressed: () {
                        // Navegação para Contato
                      },
                      child: const Text(
                        'Contato',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon:
                          const Icon(Icons.account_circle, color: Colors.black),
                      onPressed: () {
                        // Ação de perfil
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: const Center(
        child: Text('Conteúdo do Dashboard'),
      ),
    );
  }
}
