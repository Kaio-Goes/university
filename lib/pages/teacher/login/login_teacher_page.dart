import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:university/components/text_fields.dart';
import 'package:university/components/validation/validation.dart';
import 'package:university/core/models/user_firebase.dart';
import 'package:university/pages/teacher/dashboard/dashboard_teacher_page.dart';
import 'package:university/services/auth_user_service.dart';

class LoginTeacherPage extends StatefulWidget {
  const LoginTeacherPage({super.key});

  @override
  State<LoginTeacherPage> createState() => _LoginTeacherPageState();
}

class _LoginTeacherPageState extends State<LoginTeacherPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _resetEmailController = TextEditingController();
  bool _passwordVisible = false;
  String _errorMessage = '';

  Future<void> _login() async {
    bool formOk = _formKey.currentState!.validate();

    if (!formOk) {
      return;
    }

    try {
      // Autenticar o usuário
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      String uid = userCredential.user!.uid;

      try {
        DatabaseReference ref =
            FirebaseDatabase.instance.ref().child('users').child(uid);

        DataSnapshot snapshot = await ref.get();

        if (snapshot.exists) {
          String role = snapshot.child('role').value as String;
          String name = snapshot.child('name').value as String;
          String email = snapshot.child('email').value as String;
          String uid = snapshot.child('uid').value as String;
          String cpf = snapshot.child('cpf').value as String;
          String phone = snapshot.child('phone').value as String;
          String surname = snapshot.child('surname').value as String;
          bool isActive = snapshot.child('isActive').value as bool;

          var user = UserFirebase(
            uid: uid,
            name: name,
            email: email,
            role: role,
            phone: phone,
            surname: surname,
            cpf: cpf,
            isActive: isActive,
          );

          // await AuthService().addUserSecretaryModel(user: user);
          await AuthUserService().addUserModel(user: user);

          if (role == 'teacher') {
            // ignore: use_build_context_synchronously
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                    builder: (context) => const DashboardTeacherPage()),
                (Route<dynamic> route) => false);
          } else {
            setState(() {
              _errorMessage = 'Acesso negado. Você não é um(a) professor(a).';
            });
          }
        } else {
          setState(() {
            _errorMessage = 'Usuário não encontrado no banco de dados.';
          });
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'Acesso negado. Você não é um(a) professor(a).';
        });
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        if (e.code == 'invalid-credential') {
          _errorMessage =
              'E-mail ou senha inválido. Verifique e digite novamente.';
        } else {
          _errorMessage = 'Erro desconhecido: ${e.message}';
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao realizar login. Por favor, tente novamente.';
      });
    }
  }

  Future<void> _resetPassword() async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Recuperação de Senha'),
          content: TextField(
            controller: _resetEmailController,
            decoration: const InputDecoration(
              hintText: 'Digite seu e-mail',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final String email = _resetEmailController.text.trim();
                if (email.isNotEmpty) {
                  try {
                    await FirebaseAuth.instance
                        .sendPasswordResetEmail(email: email);
                    // ignore: use_build_context_synchronously
                    Navigator.of(context).pop();
                    // ignore: use_build_context_synchronously
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('E-mail de recuperação enviado!'),
                      ),
                    );
                  } on FirebaseAuthException catch (e) {
                    // ignore: use_build_context_synchronously
                    Navigator.of(context).pop();
                    // ignore: use_build_context_synchronously
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Erro: ${e.message}'),
                      ),
                    );
                  }
                }
              },
              child: const Text('Enviar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 209, 227, 240),
      body: Center(
        child: Card(
          elevation: 3,
          color: Colors.white,
          child: SizedBox(
            height: 450,
            width: 400,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 5),
                SizedBox(
                  height: 60,
                  child: Image.asset(
                    "assets/images/annamery.png",
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Column(
                          children: [
                            textFormField(
                              controller: _emailController,
                              validator: (value) => validInputEmail(value),
                              hint: 'Digite seu e-mail',
                              label: 'E-mail',
                              size: MediaQuery.of(context).size.width * 0.9,
                            ),
                            const SizedBox(height: 20),
                            textFormField(
                              controller: _passwordController,
                              validator: (value) => validatorPassword(value),
                              hint: 'Digite sua senha',
                              label: 'Senha',
                              size: MediaQuery.of(context).size.width * 0.9,
                              password: true,
                              passwordVisible: _passwordVisible,
                              togglePasswordVisibility: () {
                                setState(() {
                                  _passwordVisible = !_passwordVisible;
                                });
                              },
                            ),
                            const SizedBox(height: 20),
                            if (_errorMessage.isNotEmpty)
                              Text(
                                _errorMessage,
                                style: const TextStyle(color: Colors.red),
                              ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromARGB(255, 29, 108, 122),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: const Text('LOGIN'),
                            ),
                            const SizedBox(height: 20),
                            TextButton(
                              onPressed: _resetPassword,
                              child: const Text('Esqueceu sua senha?'),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
