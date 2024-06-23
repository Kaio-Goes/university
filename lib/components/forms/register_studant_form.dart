import 'package:flutter/material.dart';
import 'package:university/components/text_fields.dart';
import 'package:university/components/validation/validation.dart';

class RegisterStudantForm extends StatefulWidget {
  final bool isSmallScreen;
  const RegisterStudantForm({super.key, required this.isSmallScreen});

  @override
  State<RegisterStudantForm> createState() => _RegisterStudantFormState();
}

class _RegisterStudantFormState extends State<RegisterStudantForm> {
  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final ctrlName = TextEditingController();
    return Card(
      color: Colors.white,
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
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
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Form(
                  key: formKey,
                  child: Column(
                    children: [
                      widget.isSmallScreen
                          ? Wrap(
                              spacing: 20, // Espaçamento entre os itens
                              runSpacing: 20, // Espaçamento entre as linhas
                              children: [
                                textFormField(
                                  controller: ctrlName,
                                  validator: validInputNome,
                                  hint: "Digite seu nome completo",
                                  label: "Nome e sobrenome",
                                  size: MediaQuery.of(context).size.width * 1,
                                ),
                                textFormField(
                                  controller: ctrlName,
                                  validator: validInputNome,
                                  label: "Celular",
                                  hint: "(61) 99999-9999",
                                  size: MediaQuery.of(context).size.width * 1,
                                ),
                                textFormField(
                                  controller: ctrlName,
                                  validator: validInputNome,
                                  hint: "Digite seu e-mail",
                                  label: "E-mail:",
                                  size: MediaQuery.of(context).size.width * 1,
                                ),
                                textFormField(
                                  controller: ctrlName,
                                  validator: validInputNome,
                                  hint: "Selecione",
                                  label: "Modalidade:",
                                  size: MediaQuery.of(context).size.width * 1,
                                ),
                                textFormField(
                                  controller: ctrlName,
                                  validator: validInputNome,
                                  hint: "Selecione",
                                  label: "Escolha seu curso:",
                                  size: MediaQuery.of(context).size.width * 1,
                                ),
                                textFormField(
                                  controller: ctrlName,
                                  validator: validInputNome,
                                  hint: "Selecione",
                                  label: "Unidade de interesse:",
                                  size: MediaQuery.of(context).size.width * 1,
                                ),
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  children: [
                                    textFormField(
                                        controller: ctrlName,
                                        validator: validInputNome,
                                        hint: "Digite seu nome completo",
                                        label: "Nome e sobrenome",
                                        size:
                                            MediaQuery.of(context).size.width *
                                                0.2),
                                    const SizedBox(height: 25),
                                    textFormField(
                                        controller: ctrlName,
                                        validator: validInputNome,
                                        label: "Celular",
                                        hint: "(61) 99999-9999",
                                        size:
                                            MediaQuery.of(context).size.width *
                                                0.2),
                                    const SizedBox(height: 25),
                                    textFormField(
                                        controller: ctrlName,
                                        validator: validInputNome,
                                        hint: "Selecione",
                                        label: "Modalidade:",
                                        size:
                                            MediaQuery.of(context).size.width *
                                                0.2),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 5),
                                    textFormField(
                                        controller: ctrlName,
                                        validator: validInputNome,
                                        hint: "Digite seu e-mail",
                                        label: "E-mail:",
                                        size:
                                            MediaQuery.of(context).size.width *
                                                0.2),
                                    const SizedBox(height: 25),
                                    textFormField(
                                        controller: ctrlName,
                                        validator: validInputNome,
                                        hint: "Selecione",
                                        label: "Escolha seu curso:",
                                        size:
                                            MediaQuery.of(context).size.width *
                                                0.2),
                                    const SizedBox(height: 25),
                                    textFormField(
                                        controller: ctrlName,
                                        validator: validInputNome,
                                        hint: "Selecione",
                                        label: "Unidade de interesse:",
                                        size:
                                            MediaQuery.of(context).size.width *
                                                0.2),
                                  ],
                                ),
                              ],
                            ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 40,
                        child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Enviar Dados ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Icon(
                                  color: Colors.white,
                                  Icons.arrow_forward_outlined,
                                  size: 13,
                                )
                              ],
                            )),
                      )
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
