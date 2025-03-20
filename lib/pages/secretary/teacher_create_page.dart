import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:university/components/app_bar_user_component.dart';
import 'package:university/components/drawer_secretary_component.dart';
import 'package:university/components/footer.dart';
import 'package:university/components/text_fields.dart';
import 'package:university/components/validation/validation.dart';
import 'package:university/core/models/user_firebase.dart';
import 'package:university/core/utilities/styles.constants.dart';
import 'package:university/pages/secretary/dashboard/dashboard_secretary_page.dart';
import 'package:university/services/auth_user_service.dart';
import 'package:university/services/send_email.dart';

class TeacherCreatePage extends StatefulWidget {
  final UserFirebase? userTeacher;
  const TeacherCreatePage({super.key, this.userTeacher});

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
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();

    if (widget.userTeacher != null) {
      editResquest();
    }
  }

  void editResquest() {
    nameController.text = widget.userTeacher!.name;
    surnameController.text = widget.userTeacher!.surname!;
    emailController.text = widget.userTeacher!.email;
    cpfController.text = widget.userTeacher!.cpf;
    phoneController.text = widget.userTeacher!.phone;
  }

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

    if (widget.userTeacher == null) {
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

        usersRef.child(uid).set(
          {
            'uid': uid,
            'email': email,
            'name': name,
            'surname': surname,
            'cpf': cpf,
            'phone': phone,
            'role': 'teacher',
            'isActive': true
          },
        ).then((_) async {
          showDialog(
            // ignore: use_build_context_synchronously
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Sucesso"),
                content: const Text("Professor criado com sucesso!"),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                              builder: (context) =>
                                  const DashboardSecretaryPage()),
                          (Route<dynamic> route) => false);
                    },
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                    child: const Text(
                      "Ir para o ínicio",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              );
            },
          );

          await SendEmail().sendEmailCreateTeacher(
            email: email,
            password: password,
            name: name,
            surname: surname,
            cpf: cpf,
            phone: phone,
          );
        });
      } catch (e) {
        setState(() {
          _errorMessage = "E-mail já utilizado, exclua a conta com esse e-mail";
        });
      }
    } else {
      try {
        String uid = widget.userTeacher!.uid;

        // Atualizando usuário no Realtime Database (sem o campo e-mail)
        DatabaseReference usersRef =
            FirebaseDatabase.instance.ref().child('users');
        usersRef.child(uid).update(
          {
            'name': name,
            'surname': surname,
            'cpf': cpf,
            'phone': phone,
            'isActive': widget.userTeacher!.isActive,
          },
        ).then((_) {
          _showSuccessDialog();
        });
      } catch (e) {
        setState(() {
          _errorMessage = "Erro ao atualizar o usuário";
        });
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Sucesso"),
          content: const Text("Operação realizada com sucesso!"),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (context) => const DashboardSecretaryPage()),
                    (Route<dynamic> route) => false);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: const Text(
                "Ir para o início",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarUserComponent(userFirebase: AuthUserService().currentUser),
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
                                                emailController:
                                                    emailController,
                                                nameController: nameController,
                                                phoneController:
                                                    phoneController,
                                                userTeacher:
                                                    widget.userTeacher),
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
                                              userTeacher: widget.userTeacher,
                                              isActive:
                                                  widget.userTeacher?.isActive,
                                              onChangedIsActive: (value) {
                                                setState(() {
                                                  widget.userTeacher?.isActive =
                                                      value;
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
                                                    isSmallScreen:
                                                        isSmallScreen,
                                                    nameController:
                                                        nameController,
                                                    emailController:
                                                        emailController,
                                                    phoneController:
                                                        phoneController,
                                                    userTeacher:
                                                        widget.userTeacher),
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
                                                  userTeacher:
                                                      widget.userTeacher,
                                                  isActive: widget
                                                      .userTeacher?.isActive,
                                                  onChangedIsActive: (value) {
                                                    setState(() {
                                                      widget.userTeacher
                                                          ?.isActive = value;
                                                    });
                                                  },
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                const SizedBox(height: 20),
                                if (_errorMessage.isNotEmpty)
                                  Text(
                                    _errorMessage,
                                    style: const TextStyle(color: Colors.red),
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
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          widget.userTeacher != null
                                              ? 'Salvar'
                                              : 'Adicionar',
                                          style: const TextStyle(
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
  required UserFirebase? userTeacher,
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
          readOnly: userTeacher != null ? true : false,
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

Widget builFormCreateTeacherPartTwo(
    {required BuildContext context,
    required bool isSmallScreen,
    required TextEditingController surnameController,
    required TextEditingController cpfController,
    required TextEditingController passwordController,
    required bool passwordVisible,
    required Function() togglePasswordVisibility,
    required UserFirebase? userTeacher,
    bool? isActive,
    Function(bool)? onChangedIsActive}) {
  var widthInput = isSmallScreen
      ? MediaQuery.of(context).size.width * 1
      : MediaQuery.of(context).size.width * 0.38;
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      userTeacher != null
          ? const SizedBox(height: 1)
          : const SizedBox(height: 19),
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
      userTeacher != null
          ? const Text('')
          : textFormField(
              controller: passwordController,
              validator: (value) => validatorPassword(value),
              hint: 'Digite a senha',
              password: true,
              passwordVisible: passwordVisible,
              label: 'Senha',
              togglePasswordVisibility: togglePasswordVisibility,
              size: widthInput),
      userTeacher != null
          ? const SizedBox(height: 5)
          : const SizedBox(height: 0),
      userTeacher != null
          ? SizedBox(
              width: widthInput,
              child: SwitchListTile(
                title: const Text('Ativar?'),
                value: isActive ?? true,
                onChanged: onChangedIsActive,
              ),
            )
          : const Text('')
    ],
  );
}
