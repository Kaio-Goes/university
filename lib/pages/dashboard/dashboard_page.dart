import 'package:flutter/material.dart';
import 'package:university/components/app_bar_component.dart';
import 'package:university/components/drawer_component.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarComponent(),
      drawer: const DrawerComponent(),
      body: Column(
        children: [
          Stack(
            children: [
              SizedBox(
                height: 520,
                width: double.infinity,
                child: Image.asset(
                  '/home/kaiogoes/university/assets/images/studants.jpg', // Certifique-se de que o caminho está correto
                  fit: BoxFit.cover,
                  alignment: Alignment.centerRight,
                ),
              ),
            ],
          ),
          const Text('Conteúdo do Dashboard'),
        ],
      ),
    );
  }
}
