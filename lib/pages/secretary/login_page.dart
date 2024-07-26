import 'package:flutter/material.dart';
import 'package:university/components/text_fields.dart';
import 'package:university/components/validation/validation.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _passwordVisible = false;

  Future<void> _login() async {
    bool formOk = _formKey.currentState!.validate();

    if (!formOk) {
      return;
    }

    // try {
    //   await FirebaseAuth.instance.signInWithEmailAndPassword(
    //     email: _emailController.text,
    //     password: _passwordController.text,
    //   );
    //   // Navegue para a próxima tela ou mostre uma mensagem de sucesso
    // } catch (e) {
    //   print(e);
    //   // Mostre uma mensagem de erro
    // }
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
            height: 380,
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
