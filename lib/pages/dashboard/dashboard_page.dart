import 'package:flutter/material.dart';
import 'package:university/components/app_bar_component.dart';
import 'package:university/components/drawer_component.dart';
import 'package:university/components/forms/register_studant_form.dart';
import 'package:university/components/text_studant.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final ScrollController _scrollController = ScrollController();

  void _scrollToRegisterForm() {
    _scrollController.animateTo(
      600.0,
      duration: const Duration(seconds: 1),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarComponent(),
      drawer: const DrawerComponent(),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            bool isLargeScreen = constraints.maxWidth > 1100;
            bool isSmallScreen = constraints.maxWidth < 600;
            return Column(
              children: [
                Stack(
                  children: [
                    SizedBox(
                      height: 520,
                      width: double.infinity,
                      child: Image.asset(
                        '/home/kaiogoes/university/assets/images/studants.jpg',
                        fit: BoxFit.cover,
                        alignment: Alignment.centerLeft,
                      ),
                    ),
                    Positioned(
                      top: 80,
                      left: isSmallScreen
                          ? 0
                          : MediaQuery.of(context).size.height * 0.25,
                      child: SizedBox(
                        width: isSmallScreen ? 380 : 500,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextStudant(
                            function: _scrollToRegisterForm,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Transform.translate(
                        offset: const Offset(0, -50), // Ajuste a posição Y aqui
                        child: SizedBox(
                          width: isLargeScreen
                              ? MediaQuery.of(context).size.width * 0.52
                              : MediaQuery.of(context).size.width * 0.9,
                          child:
                              RegisterStudantForm(isSmallScreen: isSmallScreen),
                        ),
                      ),
                      const Text('Conteúdo do Dashboard'),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
