import 'package:flutter/material.dart';
import 'package:university/components/drawer_component.dart';
import 'package:university/components/footer.dart';

class DashboardSecretaryPage extends StatefulWidget {
  const DashboardSecretaryPage({super.key});

  @override
  State<DashboardSecretaryPage> createState() => _DashboardSecretaryPageState();
}

class _DashboardSecretaryPageState extends State<DashboardSecretaryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [Text('dasadd'), Footer()],
      ),
    );
  }
}
