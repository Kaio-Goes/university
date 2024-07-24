import 'package:flutter/material.dart';
import 'package:university/components/app_bar_component.dart';
import 'package:university/components/drawer_component.dart';
import 'package:university/components/footer.dart';

class PoleUnitPage extends StatelessWidget {
  final String pole;
  const PoleUnitPage({super.key, required this.pole});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarComponent(),
      drawer: const DrawerComponent(),
      body: SingleChildScrollView(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            bool isSmallScreen = constraints.maxWidth < 600;
            return Column(
              children: [
                Stack(
                  children: [
                    Container(
                      height: 180,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Color.fromARGB(255, 4, 19, 63),
                            Color.fromARGB(255, 4, 19, 88),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 30,
                      left: isSmallScreen
                          ? 0
                          : MediaQuery.of(context).size.height * 0.20,
                      child: SizedBox(
                        width: isSmallScreen ? 400 : 600,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Início > Unidades > $pole',
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 16),
                              ),
                              const SizedBox(height: 10),
                              Text('Nossas unidades',
                                  style: TextStyle(
                                      fontSize: 35, color: Colors.white)),
                              SizedBox(height: 10),
                              Text(
                                'Conheça mais sobre as nossas unidades.',
                                style: TextStyle(
                                  color: Color.fromARGB(255, 226, 223, 223),
                                  fontSize: 13.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Footer()
              ],
            );
          },
        ),
      ),
    );
  }
}
