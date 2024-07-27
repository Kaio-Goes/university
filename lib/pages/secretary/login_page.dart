import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:university/components/text_fields.dart';
import 'package:university/components/validation/validation.dart';
import 'package:university/pages/landingPage/dashboard/dashboard_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
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

          if (role == 'admin') {
            // Navegar para a próxima tela ou mostrar uma mensagem de sucesso
            // ignore: use_build_context_synchronously
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => const DashboardPage()));
          } else {
            setState(() {
              _errorMessage = 'Acesso negado. Você não é um administrador.';
            });
          }
        } else {
          setState(() {
            _errorMessage = 'Usuário não encontrado no banco de dados.';
          });
        }
      } catch (e) {
        setState(() {
          _errorMessage =
              'Erro ao acessar o banco de dados. Por favor, tente novamente.';
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
