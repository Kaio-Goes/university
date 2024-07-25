import 'package:flutter/material.dart';
import 'package:university/components/text_fields.dart';
import 'package:university/components/validation/validation.dart';
import 'package:university/core/utilities/styles.constants.dart';
import 'package:university/services/send_email.dart';

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
  String? _selectedCourse;
  String? _selectedUnit;

  _clickButton() async {
    bool formOk = _formKey.currentState!.validate();

    if (!formOk) {
      return;
    }

    var responseSendEmail = await SendEmail().sendEmail(
        name: _ctrlName.text,
        email: _ctrlEmail.text,
        phone: _ctrlPhone.text,
        modality: _selectedModality!,
        course: _selectedCourse!,
        unit: _selectedUnit!);

    if (responseSendEmail.statusCode == 200) {
      showDialog(
        // ignore: use_build_context_synchronously
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Sucesso'),
            content: const Text(
                'Um de nossos consultores entrará em contato com você.'),
            actions: <Widget>[
              ElevatedButton(
                onPressed: () {
                  // Limpar o formulário
                  _formKey.currentState?.reset();
                  _ctrlName.clear();
                  _ctrlPhone.clear();
                  _ctrlEmail.clear();
                  setState(() {
                    _selectedModality = null;
                    _selectedCourse = null;
                    _selectedUnit = null;
                  });

                  Navigator.of(context).pop();
                },
                child: const Text('Combinado!'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final widthResponsive = MediaQuery.of(context).size.width > 1100
        ? MediaQuery.of(context).size.width * 0.2
        : MediaQuery.of(context).size.width * 0.35;
    return Card(
      color: Colors.white,
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
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
                padding: const EdgeInsets.symmetric(horizontal: 50),
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
                                      validatorDropdown(value),
                                ),
                                dropDownField(
                                  label: 'Escolha seu curso',
                                  select: _selectedCourse,
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedCourse = value;
                                    });
                                  },
                                  items: <String>[
                                    'Técnico de Enfermagem',
                                    'Especialização em Sala Vermelha',
                                    'Especialização em Oncologia',
                                    'Especialização em Hemodiálise'
                                  ].map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                  hintText: 'Selecione o curso',
                                  validator: (value) =>
                                      validatorDropdown(value),
                                ),
                                dropDownField(
                                  label: 'Unidade de Interesse',
                                  select: _selectedUnit,
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedUnit = value;
                                    });
                                  },
                                  items: <String>['Planaltina']
                                      .map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                  hintText: 'Selecione a unidade',
                                  validator: (value) =>
                                      validatorDropdown(value),
                                )
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
                                        size: widthResponsive),
                                    const SizedBox(height: 25),
                                    textFormField(
                                        controller: _ctrlPhone,
                                        validator: validInputPhone,
                                        label: "Celular",
                                        hint: "(61) 99999-9999",
                                        textInputType: TextInputType.phone,
                                        inputFormatters: [phoneMask],
                                        size: widthResponsive),
                                    const SizedBox(height: 25),
                                    SizedBox(
                                      width: widthResponsive,
                                      child: dropDownField(
                                          label: 'Modalidade:',
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
                                    textFormField(
                                        controller: _ctrlEmail,
                                        validator: validInputEmail,
                                        hint: "Digite seu e-mail",
                                        textInputType:
                                            TextInputType.emailAddress,
                                        label: "E-mail:",
                                        size: widthResponsive),
                                    const SizedBox(height: 25),
                                    SizedBox(
                                      width: widthResponsive,
                                      child: dropDownField(
                                        label: 'Escolha seu curso',
                                        select: _selectedCourse,
                                        onChanged: (value) {
                                          setState(() {
                                            _selectedCourse = value;
                                          });
                                        },
                                        items: <String>[
                                          'Técnico de Enfermagem',
                                          'Especialização em Sala Vermelha',
                                          'Especialização em Oncologia',
                                          'Especialização em Hemodiálise'
                                        ].map((String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(value),
                                          );
                                        }).toList(),
                                        hintText: 'Selecione o curso',
                                        validator: (value) =>
                                            validatorDropdown(value),
                                      ),
                                    ),
                                    const SizedBox(height: 25),
                                    SizedBox(
                                      width: widthResponsive,
                                      child: dropDownField(
                                        label: 'Unidade de Interesse',
                                        select: _selectedUnit,
                                        onChanged: (value) {
                                          setState(() {
                                            _selectedUnit = value;
                                          });
                                        },
                                        items: <String>['Planaltina']
                                            .map((String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(value),
                                          );
                                        }).toList(),
                                        hintText: 'Selecione a unidade',
                                        validator: (value) =>
                                            validatorDropdown(value),
                                      ),
                                    )
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
