import 'package:flutter/material.dart';
import 'package:university/components/app_bar_user_component.dart';
import 'package:university/components/footer.dart';
import 'package:university/core/models/class_firebase.dart';
import 'package:university/core/models/user_firebase.dart';
import 'package:university/core/services/auth_user_service.dart';
import 'package:university/core/utilities/styles.constants.dart';

class AddNotesStudentPage extends StatefulWidget {
  final ClassFirebase classe;
  const AddNotesStudentPage({super.key, required this.classe});

  @override
  State<AddNotesStudentPage> createState() => _AddNotesStudentPageState();
}

class _AddNotesStudentPageState extends State<AddNotesStudentPage> {
  List<UserFirebase> listUser = [];
  bool isLoading = true;

  @override
  initState() {
    super.initState();
    _loadUserInClass();
  }

  _loadUserInClass() async {
    try {
      var users =
          await AuthUserService().getUsersByUids(uids: widget.classe.students);

      setState(() {
        listUser = users..sort((a, b) => a.name.compareTo(b.name));
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      Exception("Erro loading student in class $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarUserComponent(userFirebase: AuthUserService().currentUser),
      body: SingleChildScrollView(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 15),
                      Text(
                        "Alunos da Turma ${widget.classe.name}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text("Adicionar notas aos Alunos"),
                      const SizedBox(height: 20),
                      isLoading
                          ? const Center(
                              child: CircularProgressIndicator(),
                            )
                          : listUser.isEmpty
                              ? const Center(
                                  child: Text("Nenhum aluno encontrado."),
                                )
                              : SizedBox(
                                  height: listUser.length * 120,
                                  child: ListView.builder(
                                    itemCount: listUser.length,
                                    itemBuilder: (context, index) {
                                      final user = listUser[index];
                                      return Card.outlined(
                                        child: ListTile(
                                          contentPadding:
                                              const EdgeInsets.all(16),
                                          hoverColor: Colors.grey[200],
                                          title: Text(
                                            user.name,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                            style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w800),
                                          ),
                                          subtitle: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Email: ${user.email}",
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                                style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                              Text("Celular: ${user.phone}")
                                            ],
                                          ),
                                          leading: Container(
                                            height: 50,
                                            width: 50,
                                            decoration: BoxDecoration(
                                              color: colorPrimaty,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: const Icon(
                                              Icons.person,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                      const SizedBox(height: 15),
                    ],
                  ),
                ),
                const Footer(),
              ],
            );
          },
        ),
      ),
    );
  }
}
