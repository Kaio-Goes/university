import 'package:flutter/material.dart';
import 'package:university/components/app_bar_component.dart';
import 'package:university/components/drawer_component.dart';
import 'package:university/core/utilities/styles.constants.dart';

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
              Positioned(
                top: 80,
                left: 250,
                child: Container(
                  width: 500,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 45,
                        width: 200,
                        decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.all(Radius.circular(20))),
                        child: const Center(
                          child: Text(
                            'GRADUAÇÃO 2024.2',
                            style: textBold,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      const Text(
                        'Transforme o seu futuro com o Anna Nery',
                        style: texTitleCard,
                      ),
                      const Text(
                        'Inscreva-se no nosso vestibular. São mais de 30 opções de cursos, nas modalidades Presencial, Híbrido e EaD. Só no UniProjeção você tem acesso a bolsas de até 100%!',
                        style: TextStyle(color: Colors.white),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 29, 25, 51),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: const Text('Iniciar Inscrição'),
                          ),
                          const SizedBox(width: 20),
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(0, 255, 255, 255),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: const Text('Ver cursos'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
          const Text('Conteúdo do Dashboard'),
        ],
      ),
    );
  }
}
