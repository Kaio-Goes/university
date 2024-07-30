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
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  bool _passwordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarSecretaryComponent(),
      drawer: const DrawerSecretaryComponent(),
      body: SingleChildScrollView(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            bool isSmallScreen = constraints.maxWidth < 800;
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
                                  horizontal: isSmallScreen ? 15 : 40),
                              child: isSmallScreen
                                  ? Form(
                                      key: _formKey,
                                      child: Wrap(
                                        spacing: 20,
                                        runSpacing: 20,
                                        children: [
                                          builFormCreateTeacherPartOne(
                                            context: context,
                                            isSmallScreen: isSmallScreen,
                                            nameController: nameController,
                                            cpfController: cpfController,
                                            passwordController:
                                                passwordController,
                                            passwordVisible: _passwordVisible,
                                            togglePasswordVisibility: () {
                                              setState(() {
                                                _passwordVisible =
                                                    !_passwordVisible;
                                              });
                                            },
                                          ),
                                          builFormCreateTeacherPartTwo(
                                              context: context,
                                              isSmallScreen: isSmallScreen,
                                              emailController: emailController,
                                              phoneController: phoneController)
                                        ],
                                      ),
                                    )
                                  : Form(
                                      key: _formKey,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          builFormCreateTeacherPartOne(
                                            context: context,
                                            isSmallScreen: isSmallScreen,
                                            nameController: nameController,
                                            cpfController: cpfController,
                                            passwordController:
                                                passwordController,
                                            passwordVisible: _passwordVisible,
                                            togglePasswordVisibility: () {
                                              setState(() {
                                                _passwordVisible =
                                                    !_passwordVisible;
                                              });
                                            },
                                          ),
                                          builFormCreateTeacherPartTwo(
                                              context: context,
                                              isSmallScreen: isSmallScreen,
                                              emailController: emailController,
                                              phoneController: phoneController)
                                        ],
                                      ),
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

Widget builFormCreateTeacherPartOne(
    {required BuildContext context,
    required bool isSmallScreen,
    required TextEditingController nameController,
    required TextEditingController cpfController,
    required TextEditingController passwordController,
    required bool passwordVisible,
    required Function() togglePasswordVisibility}) {
  var widthInput = isSmallScreen
      ? MediaQuery.of(context).size.width * 1
      : MediaQuery.of(context).size.width * 0.35;
  return Column(
    children: [
      textFormField(
          controller: nameController,
          validator: (value) => validInputNome(value),
          hint: 'Digite o nome do Professor',
          label: 'Nome',
          size: widthInput),
      const SizedBox(height: 25),
      textFormField(
          controller: cpfController,
          validator: (value) => validatorCpf(value),
          hint: 'Digite o CPF',
          inputFormatters: [formatterCpf],
          label: 'CPF',
          size: widthInput),
      const SizedBox(height: 25),
      textFormField(
          controller: passwordController,
          validator: (value) => validatorPassword(value),
          hint: 'Digite a senha',
          password: true,
          passwordVisible: passwordVisible,
          label: 'Senha',
          togglePasswordVisibility: togglePasswordVisibility,
          size: widthInput),
    ],
  );
}

Widget builFormCreateTeacherPartTwo({
  required BuildContext context,
  required bool isSmallScreen,
  required TextEditingController emailController,
  required TextEditingController phoneController,
}) {
  var widthInput = isSmallScreen
      ? MediaQuery.of(context).size.width * 1
      : MediaQuery.of(context).size.width * 0.38;
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      textFormField(
          controller: emailController,
          validator: (value) => validInputEmail(value),
          hint: 'Digite o seu e-mail',
          label: 'E-mail',
          size: widthInput),
      const SizedBox(height: 25),
      textFormField(
          controller: phoneController,
          validator: (value) => validInputPhone(value),
          inputFormatters: [phoneMask],
          hint: 'Digite o seu telefone',
          label: 'Telefone',
          size: widthInput),
      const SizedBox(height: 100),
    ],
  );
}
