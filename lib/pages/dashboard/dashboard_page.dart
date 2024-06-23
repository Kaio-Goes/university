import 'package:flutter/material.dart';
import 'package:university/components/app_bar_component.dart';
import 'package:university/components/drawer_component.dart';
import 'package:university/components/text_fields.dart';
import 'package:university/components/text_studant.dart';
import 'package:university/components/validation/validation.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final ctrlName = TextEditingController();

    return Scaffold(
      appBar: appBarComponent(),
      drawer: const DrawerComponent(),
      body: SingleChildScrollView(
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
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: TextStudant(),
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
                          child: Card(
                            color: Colors.white,
                            elevation: 8,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 40, vertical: 40),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    'Comece sua inscrição no nosso vestibular',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  const Text(
                                    'Nosso time de consultores entrará em contato para tirar suas dúvidas',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 13),
                                  ),
                                  const SizedBox(height: 20),
                                  Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 30),
                                      child: Form(
                                        key: formKey,
                                        child: isSmallScreen
                                            ? Wrap(
                                                spacing:
                                                    20, // Espaçamento entre os itens
                                                runSpacing:
                                                    20, // Espaçamento entre as linhas
                                                children: [
                                                  textFormField(
                                                    controller: ctrlName,
                                                    validator: validInputNome,
                                                    hint:
                                                        "Digite seu nome completo",
                                                    label: "Nome e sobrenome",
                                                    size: MediaQuery.of(context)
                                                            .size
                                                            .width *
                                                        1,
                                                  ),
                                                  textFormField(
                                                    controller: ctrlName,
                                                    validator: validInputNome,
                                                    label: "Celular",
                                                    hint: "(61) 99999-9999",
                                                    size: MediaQuery.of(context)
                                                            .size
                                                            .width *
                                                        1,
                                                  ),
                                                  textFormField(
                                                    controller: ctrlName,
                                                    validator: validInputNome,
                                                    hint: "Digite seu e-mail",
                                                    label: "E-mail:",
                                                    size: MediaQuery.of(context)
                                                            .size
                                                            .width *
                                                        1,
                                                  ),
                                                  textFormField(
                                                    controller: ctrlName,
                                                    validator: validInputNome,
                                                    hint: "Selecione",
                                                    label: "Modalidade:",
                                                    size: MediaQuery.of(context)
                                                            .size
                                                            .width *
                                                        1,
                                                  ),
                                                  textFormField(
                                                    controller: ctrlName,
                                                    validator: validInputNome,
                                                    hint: "Selecione",
                                                    label: "Escolha seu curso:",
                                                    size: MediaQuery.of(context)
                                                            .size
                                                            .width *
                                                        1,
                                                  ),
                                                  textFormField(
                                                    controller: ctrlName,
                                                    validator: validInputNome,
                                                    hint: "Selecione",
                                                    label:
                                                        "Unidade de interesse:",
                                                    size: MediaQuery.of(context)
                                                            .size
                                                            .width *
                                                        1,
                                                  ),
                                                ],
                                              )
                                            : Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Column(
                                                    children: [
                                                      textFormField(
                                                          controller: ctrlName,
                                                          validator:
                                                              validInputNome,
                                                          hint:
                                                              "Digite seu nome completo",
                                                          label:
                                                              "Nome e sobrenome",
                                                          size: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.2),
                                                      const SizedBox(
                                                          height: 25),
                                                      textFormField(
                                                          controller: ctrlName,
                                                          validator:
                                                              validInputNome,
                                                          label: "Celular",
                                                          hint:
                                                              "(61) 99999-9999",
                                                          size: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.2),
                                                      const SizedBox(
                                                          height: 25),
                                                      textFormField(
                                                          controller: ctrlName,
                                                          validator:
                                                              validInputNome,
                                                          hint: "Selecione",
                                                          label: "Modalidade:",
                                                          size: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.2),
                                                    ],
                                                  ),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      const SizedBox(height: 5),
                                                      textFormField(
                                                          controller: ctrlName,
                                                          validator:
                                                              validInputNome,
                                                          hint:
                                                              "Digite seu e-mail",
                                                          label: "E-mail:",
                                                          size: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.2),
                                                      const SizedBox(
                                                          height: 25),
                                                      textFormField(
                                                          controller: ctrlName,
                                                          validator:
                                                              validInputNome,
                                                          hint: "Selecione",
                                                          label:
                                                              "Escolha seu curso:",
                                                          size: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.2),
                                                      const SizedBox(
                                                          height: 25),
                                                      textFormField(
                                                          controller: ctrlName,
                                                          validator:
                                                              validInputNome,
                                                          hint: "Selecione",
                                                          label:
                                                              "Unidade de interesse:",
                                                          size: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.2),
                                                      const SizedBox(height: 5),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                      )),
                                ],
                              ),
                            ),
                          ),
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
