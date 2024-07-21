import 'package:flutter/material.dart';
import 'package:university/components/app_bar_component.dart';
import 'package:university/components/drawer_component.dart';
import 'package:university/components/footer.dart';

class UnitsPage extends StatelessWidget {
  const UnitsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarComponent(),
      drawer: const DrawerComponent(),
      body: SingleChildScrollView(
        child: Column(
          children: [Footer()],
        ),
      ),
    );
  }
}
