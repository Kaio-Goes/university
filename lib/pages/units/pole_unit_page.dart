import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:university/components/app_bar_component.dart';
import 'package:university/components/drawer_component.dart';
import 'package:university/components/footer.dart';

class PoleUnitPage extends StatelessWidget {
  final String pole;
  final String address;
  final String phone;
  const PoleUnitPage(
      {super.key,
      required this.pole,
      required this.address,
      required this.phone});

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
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
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
                      top: 40,
                      left: isSmallScreen
                          ? 0
                          : MediaQuery.of(context).size.height * 0.25,
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
                              Text(pole,
                                  style: const TextStyle(
                                      fontSize: 35, color: Colors.white)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(
                    top: 60,
                    left: isSmallScreen
                        ? 10
                        : MediaQuery.of(context).size.height * 0.25,
                    right: isSmallScreen
                        ? 10
                        : MediaQuery.of(context).size.height * 0.25,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Text('Sobre o Curso',
                              style: TextStyle(
                                  fontSize: 28, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 25),
                          SizedBox(
                            height: 300,
                            width: 500,
                            child: Image.asset(
                              'assets/images/memberannanery.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(height: 25),
                          SizedBox(
                            width: isSmallScreen
                                ? MediaQuery.of(context).size.width * 0.9
                                : MediaQuery.of(context).size.width * 0.38,
                            child: Text(
                              'O polo disponibiliza toda a estrutura de atendimento, incluindo laboratórios com computadores e conexão à internet, oferecendo suporte e apoio aos cursos na modalidade EAD.\n\n O espaço conta com salas de aula e de  reunião para realização de atividades presenciais e  facilitar a interação entre os alunos. A unidade conta ainda  com corpo de atendimento  formado por secretária e técnico de informática.',
                              textAlign: isSmallScreen
                                  ? TextAlign.center
                                  : TextAlign.start,
                              style: const TextStyle(
                                height: 1.8,
                              ),
                            ),
                          )
                        ],
                      ),
                      Column(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width * 0.30,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.black12,
                                width: 1,
                              ),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(12)),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 30, vertical: 40),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Informações',
                                    style: TextStyle(
                                        fontSize: 21,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 25),
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on, size: 25),
                                      const SizedBox(width: 5),
                                      Expanded(
                                        child: Text(
                                          address,
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      const Icon(Icons.phone, size: 25),
                                      const SizedBox(width: 5),
                                      Expanded(
                                        child: Text(
                                          phone,
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      SvgPicture.asset(
                                        'assets/images/whatsapp.svg',
                                        height: 25,
                                        colorFilter: const ColorFilter.mode(
                                          Colors.white,
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      Expanded(
                                        child: Text(
                                          phone,
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 45),
                const Footer()
              ],
            );
          },
        ),
      ),
    );
  }
}
