import 'package:flutter/material.dart';
import 'package:university/components/app_bar_secretary_component.dart';
import 'package:university/components/drawer_secretary_component.dart';
import 'package:university/components/footer.dart';
import 'package:university/components/text_fields.dart';
import 'package:university/components/validation/validation.dart';
import 'package:university/core/utilities/styles.constants.dart';

class TeacherCreatePage extends StatefulWidget {
  const TeacherCreatePage({super.key});

  @override
  State<TeacherCreatePage> createState() => _TeacherCreatePageState();
}

class _TeacherCreatePageState extends State<TeacherCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final cpfController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarSecretaryComponent(),
      drawer: const DrawerSecretaryComponent(),
      body: SingleChildScrollView(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            bool isSmallScreen = constraints.maxWidth < 600;
            return Column(
              children: [
                const SizedBox(height: 25),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.90,
                  child: Card(
                    elevation: 8,
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Criar um novo Professor',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Assim que criado é enviado no e-mail do Professor sua conta.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 13),
                          ),
                          const SizedBox(height: 20),
                          Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: isSmallScreen ? 15 : 10),
                              child: isSmallScreen
                                  ? Wrap(
                                      spacing: 20, // Espaçamento entre os itens
                                      runSpacing:
                                          20, // Espaçamento entre as linhas
                                      children: [
                                        builFormCreateTeacher(
                                            context: context,
                                            isSmallScreen: isSmallScreen,
                                            formKey: _formKey,
                                            nameController: nameController,
                                            cpfController: cpfController)
                                      ],
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        builFormCreateTeacher(
                                            context: context,
                                            isSmallScreen: isSmallScreen,
                                            formKey: _formKey,
                                            nameController: nameController,
                                            cpfController: cpfController)
                                      ],
                                    )),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                const Footer(),
              ],
            );
          },
        ),
      ),
    );
  }
}

Widget builFormCreateTeacher({
  required BuildContext context,
  required bool isSmallScreen,
  required Key formKey,
  required TextEditingController nameController,
  required TextEditingController cpfController,
}) {
  var widthInput = isSmallScreen
      ? MediaQuery.of(context).size.width * 1
      : MediaQuery.of(context).size.width * 0.30;
  return Form(
    key: formKey,
    child: Column(
      children: [
        textFormField(
            controller: nameController,
            validator: (value) => validInputNome(value),
            hint: 'Digite o nome do Professor',
            label: 'Nome',
            size: widthInput),
        textFormField(
            controller: cpfController,
            validator: (value) => validatorCpf(value),
            hint: 'Digite o CPF',
            inputFormatters: [formatterCpf],
            label: 'CPF',
            size: widthInput)
      ],
    ),
  );
}
