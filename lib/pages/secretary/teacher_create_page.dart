import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
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
  final surnameController = TextEditingController();
  final cpfController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  bool _passwordVisible = false;

  _clickButton({
    required String email,
    required String password,
    required String name,
    required String surname,
    required String cpf,
    required String phone,
  }) async {
    bool formOk = _formKey.currentState!.validate();

    if (!formOk) {
      return;
    }

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String uid = userCredential.user!.uid;

      // Adicionando usuário ao Realtime Database
      DatabaseReference usersRef =
          FirebaseDatabase.instance.ref().child('users');
      usersRef.child(uid).set({
        'email': email,
        'name': name,
        'surname': surname,
        'cpf': cpf,
        'phone': phone,
        'role': 'teacher',
      });
    } catch (e) {
      print('Erro ao criar usuário: $e');
    }
  }

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
                            child: Column(
                              children: [
                                isSmallScreen
                                    ? Form(
                                        key: _formKey,
                                        child: Wrap(
                                          spacing: 20,
                                          runSpacing: 20,
                                          children: [
                                            builFormCreateTeacherPartOne(
                                              context: context,
                                              isSmallScreen: isSmallScreen,
                                              emailController: emailController,
                                              nameController: nameController,
                                              phoneController: phoneController,
                                            ),
                                            builFormCreateTeacherPartTwo(
                                              context: context,
                                              isSmallScreen: isSmallScreen,
                                              surnameController:
                                                  surnameController,
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
                                            )
                                          ],
                                        ),
                                      )
                                    : Form(
                                        key: _formKey,
                                        child: Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                builFormCreateTeacherPartOne(
                                                  context: context,
                                                  isSmallScreen: isSmallScreen,
                                                  nameController:
                                                      nameController,
                                                  emailController:
                                                      emailController,
                                                  phoneController:
                                                      phoneController,
                                                ),
                                                builFormCreateTeacherPartTwo(
                                                  context: context,
                                                  isSmallScreen: isSmallScreen,
                                                  surnameController:
                                                      surnameController,
                                                  cpfController: cpfController,
                                                  passwordController:
                                                      passwordController,
                                                  passwordVisible:
                                                      _passwordVisible,
                                                  togglePasswordVisibility: () {
                                                    setState(() {
                                                      _passwordVisible =
                                                          !_passwordVisible;
                                                    });
                                                  },
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                const SizedBox(height: 20),
                                SizedBox(
                                  height: 40,
                                  width: 200,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      _clickButton(
                                          cpf: cpfController.text,
                                          name: nameController.text,
                                          surname: surnameController.text,
                                          email: emailController.text,
                                          phone: phoneController.text,
                                          password: passwordController.text);
                                    },
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue),
                                    child: const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Adicionar',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
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

Widget builFormCreateTeacherPartOne({
  required BuildContext context,
  required bool isSmallScreen,
  required TextEditingController nameController,
  required TextEditingController emailController,
  required TextEditingController phoneController,
}) {
  var widthInput = isSmallScreen
      ? MediaQuery.of(context).size.width * 1
      : MediaQuery.of(context).size.width * 0.35;
  return Column(
    children: [
      textFormField(
          controller: nameController,
          validator: (value) => validInputNome(value),
          hint: 'Digite o primeiro nome',
          label: 'Nome',
          size: widthInput),
      const SizedBox(height: 25),
      textFormField(
          controller: emailController,
          validator: (value) => validInputEmail(value),
          hint: 'Digite seu e-mail',
          label: 'E-mail',
          size: widthInput),
      const SizedBox(height: 25),
      textFormField(
          controller: phoneController,
          validator: (value) => validInputPhone(value),
          hint: 'Digite o Telefone',
          inputFormatters: [phoneMask],
          label: 'Telefone',
          size: widthInput),
    ],
  );
}

Widget builFormCreateTeacherPartTwo({
  required BuildContext context,
  required bool isSmallScreen,
  required TextEditingController surnameController,
  required TextEditingController cpfController,
  required TextEditingController passwordController,
  required bool passwordVisible,
  required Function() togglePasswordVisibility,
}) {
  var widthInput = isSmallScreen
      ? MediaQuery.of(context).size.width * 1
      : MediaQuery.of(context).size.width * 0.38;
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      textFormField(
          controller: surnameController,
          validator: (value) => validInputNome(value),
          hint: 'Digite o sobrenome',
          label: 'Sobrenome',
          size: widthInput),
      const SizedBox(height: 25),
      textFormField(
          controller: cpfController,
          validator: (value) => validatorCpf(value),
          inputFormatters: [formatterCpf],
          hint: 'Digite o CPF',
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
