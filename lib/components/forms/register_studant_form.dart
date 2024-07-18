import 'package:flutter/material.dart';
import 'package:university/components/text_fields.dart';
import 'package:university/components/validation/validation.dart';
import 'package:university/core/utilities/styles.constants.dart';

class RegisterStudantForm extends StatefulWidget {
  final bool isSmallScreen;
  const RegisterStudantForm({super.key, required this.isSmallScreen});

  @override
  State<RegisterStudantForm> createState() => _RegisterStudantFormState();
}

class _RegisterStudantFormState extends State<RegisterStudantForm> {
  final _formKey = GlobalKey<FormState>();
  final _ctrlName = TextEditingController();
  final _ctrlPhone = TextEditingController();
  final _ctrlEmail = TextEditingController();
  String? _selectedModality;

  _clickButton() async {
    bool formOk = _formKey.currentState!.validate();

    if (!formOk) {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  key: _formKey,
                  child: Column(
                    children: [
                      widget.isSmallScreen
                          ? Wrap(
                              spacing: 20, // Espaçamento entre os itens
                              runSpacing: 20, // Espaçamento entre as linhas
                              children: [
                                textFormField(
                                  controller: _ctrlName,
                                  validator: validInputNome,
                                  hint: "Digite seu nome completo",
                                  label: "Nome e sobrenome",
                                  size: MediaQuery.of(context).size.width * 1,
                                ),
                                textFormField(
                                  controller: _ctrlPhone,
                                  validator: validInputPhone,
                                  textInputType: TextInputType.phone,
                                  inputFormatters: [phoneMask],
                                  label: "Celular",
                                  hint: "(61) 99999-9999",
                                  size: MediaQuery.of(context).size.width * 1,
                                ),
                                textFormField(
                                  controller: _ctrlEmail,
                                  validator: validInputEmail,
                                  hint: "Digite seu e-mail",
                                  textInputType: TextInputType.emailAddress,
                                  label: "E-mail:",
                                  size: MediaQuery.of(context).size.width * 1,
                                ),
                                dropDownField(
                                    label: 'Modalidade',
                                    select: _selectedModality,
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedModality = value;
                                      });
                                    },
                                    hintText: 'Selecione a Modalidade',
                                    items:
                                        <String>['Noturno'].map((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                    validator: (value) =>
                                        validatorDropdown(value)),
                                textFormField(
                                  controller: _ctrlName,
                                  validator: validInputNome,
                                  hint: "Selecione",
                                  label: "Escolha seu curso:",
                                  size: MediaQuery.of(context).size.width * 1,
                                ),
                                textFormField(
                                  controller: _ctrlName,
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
                                        controller: _ctrlName,
                                        validator: validInputNome,
                                        hint: "Digite seu nome completo",
                                        label: "Nome e sobrenome",
                                        size:
                                            MediaQuery.of(context).size.width *
                                                0.2),
                                    const SizedBox(height: 25),
                                    textFormField(
                                        controller: _ctrlPhone,
                                        validator: validInputPhone,
                                        label: "Celular",
                                        hint: "(61) 99999-9999",
                                        textInputType: TextInputType.phone,
                                        inputFormatters: [phoneMask],
                                        size:
                                            MediaQuery.of(context).size.width *
                                                0.2),
                                    const SizedBox(height: 25),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.2,
                                      child: dropDownField(
                                          label: 'Modalidade',
                                          select: _selectedModality,
                                          onChanged: (value) {
                                            setState(() {
                                              _selectedModality = value;
                                            });
                                          },
                                          hintText: 'Selecione a Modalidade',
                                          items: <String>['Noturno']
                                              .map((String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(value),
                                            );
                                          }).toList(),
                                          validator: (value) =>
                                              validatorDropdown(value)),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 5),
                                    textFormField(
                                        controller: _ctrlEmail,
                                        validator: validInputEmail,
                                        hint: "Digite seu e-mail",
                                        textInputType:
                                            TextInputType.emailAddress,
                                        label: "E-mail:",
                                        size:
                                            MediaQuery.of(context).size.width *
                                                0.2),
                                    const SizedBox(height: 25),
                                    textFormField(
                                        controller: _ctrlName,
                                        validator: validInputNome,
                                        hint: "Selecione",
                                        label: "Escolha seu curso:",
                                        size:
                                            MediaQuery.of(context).size.width *
                                                0.2),
                                    const SizedBox(height: 25),
                                    textFormField(
                                        controller: _ctrlName,
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
                            onPressed: () {
                              _clickButton();
                            },
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
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Ao enviar seus dados, você autoriza que a Anna Nery entre em contato e declara estar ciente da da nossa Política de Privacidade.',
                        style: textStylePlaceholder,
                        textAlign: TextAlign.center,
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
