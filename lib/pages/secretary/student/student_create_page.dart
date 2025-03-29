import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:university/components/app_bar_user_component.dart';
import 'package:university/components/drawer_secretary_component.dart';
import 'package:university/components/footer.dart';
import 'package:university/components/text_fields.dart';
import 'package:university/components/validation/validation.dart';
import 'package:university/core/models/user_firebase.dart';
import 'package:university/core/utilities/alerts.dart';
import 'package:university/core/utilities/styles.constants.dart';
import 'package:university/pages/secretary/dashboard/dashboard_secretary_page.dart';
import 'package:university/core/services/auth_user_service.dart';
import 'package:university/core/services/send_email.dart';

class StudantCreatePage extends StatefulWidget {
  final UserFirebase? userStudent;
  const StudantCreatePage({super.key, this.userStudent});

  @override
  State<StudantCreatePage> createState() => _StudantCreatePageState();
}

class _StudantCreatePageState extends State<StudantCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final rgController = TextEditingController();
  final cpfController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  String? _selectedSex;
  final birthDateController = TextEditingController();
  final addressController = TextEditingController();
  final cepController = TextEditingController();
  bool _passwordVisible = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();

    if (widget.userStudent != null) {
      editResquest();
    }
  }

  void editResquest() {
    nameController.text = widget.userStudent!.name;
    emailController.text = widget.userStudent!.email;
    rgController.text = widget.userStudent!.rg!;
    cpfController.text = widget.userStudent!.cpf;
    phoneController.text = widget.userStudent!.phone;
    _selectedSex = widget.userStudent!.sex;
    birthDateController.text = widget.userStudent!.birthDate!;
    cepController.text = widget.userStudent!.cep!;
    addressController.text = widget.userStudent!.address!;
  }

  String generateRegistration() {
    String year = DateTime.now().year.toString();
    String randomDigits =
        (100000 + (DateTime.now().millisecondsSinceEpoch % 900000))
            .toString()
            .substring(0, 6);
    return '$year$randomDigits';
  }

  Future<String> generateUniqueRegistration() async {
    String registration;
    DatabaseReference usersRef = FirebaseDatabase.instance.ref().child('users');
    DataSnapshot snapshot;

    do {
      registration = generateRegistration();
      snapshot = await usersRef
          .orderByChild('registration')
          .equalTo(registration)
          .get();
    } while (snapshot.value != null); // Verifica se o registro já existe

    return registration;
  }

  _clickButton({
    required String email,
    required String password,
    required String name,
    required String cpf,
    required String rg,
    required String phone,
    required String sex,
    required String birthDate,
    required String cep,
    required String address,
  }) async {
    bool formOk = _formKey.currentState!.validate();

    if (!formOk) {
      return;
    }

    if (widget.userStudent == null) {
      try {
        String uniqueRegistration = await generateUniqueRegistration();

        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        String uid = userCredential.user!.uid;

        // Adicionando usuário ao Realtime Database
        DatabaseReference usersRef =
            FirebaseDatabase.instance.ref().child('users');

        print(uniqueRegistration);

        usersRef.child(uid).set(
          {
            'uid': uid,
            'registration': uniqueRegistration,
            'email': email,
            'name': name,
            'cpf': cpf,
            'rg': rg,
            'sex': sex,
            'birth_date': birthDate,
            'cep': cep,
            'address': address,
            'phone': phone,
            'role': 'student',
            'isActive': true,
            'created_at': DateTime.now().toLocal().toString(),
            'updated_at': DateTime.now().toLocal().toString(),
          },
        ).then((_) async {
          showDialog(
            // ignore: use_build_context_synchronously
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Sucesso"),
                content: const Text("Aluno criado com sucesso!"),
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
          await SendEmail().sendEmailCreateStudent(
              email: email,
              password: password,
              name: name,
              rg: rg,
              cpf: cpf,
              phone: phone);
        });
      } catch (e) {
        setState(() {
          _errorMessage =
              "E-mail já utilizado, exclua a conta com esse e-mail $e";
        });
      }
    } else {
      try {
        String uid = widget.userStudent!.uid;

        // Atualizando usuário no Realtime Database (sem o campo e-mail)
        DatabaseReference usersRef =
            FirebaseDatabase.instance.ref().child('users');
        usersRef.child(uid).update(
          {
            'name': name,
            'cpf': cpf,
            'phone': phone,
            'isActive': widget.userStudent!.isActive,
            'updated_at': DateTime.now().toLocal().toString(),
          },
        ).then((_) {
          // ignore: use_build_context_synchronously
          showSuccessDialog(context);
        });
      } catch (e) {
        setState(() {
          _errorMessage = "Erro ao atualizar o usuário";
        });
      }
    }
  }

  _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      setState(() {
        controller.text =
            "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
      });
    }
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

            var widthInput = isSmallScreen
                ? MediaQuery.of(context).size.width * 1
                : MediaQuery.of(context).size.width * 0.38;

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
                            'Criar um novo Aluno(a)',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Assim que criado é enviado no e-mail do Aluno a sua conta.',
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
                                              userStudent: widget.userStudent,
                                              selectedSex: _selectedSex,
                                              onChanged: (sex) {
                                                setState(() {
                                                  _selectedSex = sex;
                                                });
                                              },
                                              addressController:
                                                  addressController,
                                            ),
                                            builFormCreateTeacherPartTwo(
                                              context: context,
                                              isSmallScreen: isSmallScreen,
                                              rgController: rgController,
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
                                              birthDate: textFormField(
                                                controller: birthDateController,
                                                validator: (value) =>
                                                    validateBirthDate(value),
                                                inputFormatters: [
                                                  MaskTextInputFormatter(
                                                    mask: '##/##/####',
                                                    filter: {
                                                      "#": RegExp(r'^[0-9]*$')
                                                    },
                                                    type: MaskAutoCompletionType
                                                        .lazy,
                                                  )
                                                ],
                                                hint:
                                                    'Selecione a Data de Nascimento',
                                                label: 'Data de Nascimento',
                                                size: widthInput,
                                                onTap: () async {
                                                  FocusScope.of(context)
                                                      .unfocus();
                                                  await _selectDate(context,
                                                      birthDateController);
                                                },
                                              ),
                                              userStudent: widget.userStudent,
                                              isActive:
                                                  widget.userStudent?.isActive,
                                              onChangedIsActive: (value) {
                                                setState(() {
                                                  widget.userStudent?.isActive =
                                                      value;
                                                });
                                              },
                                              cepController: cepController,
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
                                                  userStudent:
                                                      widget.userStudent,
                                                  selectedSex: _selectedSex,
                                                  onChanged: (sex) {
                                                    setState(() {
                                                      _selectedSex = sex;
                                                    });
                                                  },
                                                  addressController:
                                                      addressController,
                                                ),
                                                builFormCreateTeacherPartTwo(
                                                  context: context,
                                                  isSmallScreen: isSmallScreen,
                                                  rgController: rgController,
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
                                                  birthDate: textFormField(
                                                    controller:
                                                        birthDateController,
                                                    validator: (value) =>
                                                        validateBirthDate(
                                                            value),
                                                    inputFormatters: [
                                                      MaskTextInputFormatter(
                                                        mask: '##/##/####',
                                                        filter: {
                                                          "#": RegExp(
                                                              r'^[0-9]*$')
                                                        },
                                                        type:
                                                            MaskAutoCompletionType
                                                                .lazy,
                                                      )
                                                    ],
                                                    hint:
                                                        'Selecione a Data de Nascimento',
                                                    label: 'Data de Nascimento',
                                                    size: widthInput,
                                                    onTap: () async {
                                                      FocusScope.of(context)
                                                          .unfocus();
                                                      await _selectDate(context,
                                                          birthDateController);
                                                    },
                                                  ),
                                                  userStudent:
                                                      widget.userStudent,
                                                  isActive: widget
                                                      .userStudent?.isActive,
                                                  onChangedIsActive: (value) {
                                                    setState(() {
                                                      widget.userStudent
                                                          ?.isActive = value;
                                                    });
                                                  },
                                                  cepController: cepController,
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
                                        email: emailController.text,
                                        rg: rgController.text,
                                        phone: phoneController.text,
                                        sex: _selectedSex!,
                                        birthDate: birthDateController.text,
                                        address: addressController.text,
                                        cep: cepController.text,
                                        password: passwordController.text,
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          widget.userStudent != null
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
  required UserFirebase? userStudent,
  required String? selectedSex,
  required TextEditingController addressController,
  required void Function(String?)? onChanged,
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
        label: 'Nome Completo',
        size: widthInput,
      ),
      const SizedBox(height: 25),
      textFormField(
        controller: emailController,
        validator: (value) => validInputEmail(value),
        hint: 'Digite seu e-mail',
        label: 'E-mail',
        readOnly: userStudent != null ? true : false,
        size: widthInput,
      ),
      const SizedBox(height: 25),
      SizedBox(
        width: widthInput,
        child: dropDownField(
            label: 'Sexo',
            select: selectedSex,
            onChanged: onChanged,
            items: <String>['Masculino', 'Feminino'].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            hintText: 'Selecione o sexo',
            validator: (value) => validatorDropdown(value)),
      ),
      const SizedBox(height: 25),
      textFormField(
        controller: phoneController,
        validator: (value) => validInputPhone(value),
        hint: 'Digite o Telefone',
        inputFormatters: [phoneMask],
        label: 'Telefone',
        size: widthInput,
      ),
      const SizedBox(height: 25),
      textFormField(
        controller: addressController,
        validator: (value) {
          return null;
        },
        hint: 'Digite o endereço',
        label: 'Endereço',
        size: widthInput,
      ),
    ],
  );
}

Widget builFormCreateTeacherPartTwo({
  required BuildContext context,
  required bool isSmallScreen,
  required TextEditingController rgController,
  required TextEditingController cpfController,
  required TextEditingController passwordController,
  required bool passwordVisible,
  required Function() togglePasswordVisibility,
  required UserFirebase? userStudent,
  required TextEditingController cepController,
  bool? isActive,
  Function(bool)? onChangedIsActive,
  required Widget birthDate,
}) {
  var widthInput = isSmallScreen
      ? MediaQuery.of(context).size.width * 1
      : MediaQuery.of(context).size.width * 0.38;
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      userStudent != null
          ? const SizedBox(height: 1)
          : const SizedBox(height: 19),
      textFormField(
          controller: rgController,
          validator: (value) => validatorRg(value),
          inputFormatters: [formatterRg],
          hint: 'Digite o RG',
          label: 'RG',
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
      birthDate,
      const SizedBox(height: 25),
      textFormField(
        controller: cepController,
        validator: (value) {
          return null;
        },
        inputFormatters: [
          MaskTextInputFormatter(
            mask: '#####-###',
            filter: {"#": RegExp(r'^[0-9]*$')},
            type: MaskAutoCompletionType.lazy,
          )
        ],
        hint: "Digiete o CEP",
        label: 'CEP',
        size: widthInput,
      ),
      const SizedBox(height: 25),
      userStudent != null
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
      userStudent != null
          ? const SizedBox(height: 5)
          : const SizedBox(height: 0),
      userStudent != null
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
