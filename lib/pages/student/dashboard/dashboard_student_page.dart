import 'package:flutter/material.dart';
import 'package:university/components/app_bar_user_component.dart';
import 'package:university/components/footer.dart';
import 'package:university/core/models/class_firebase.dart';
import 'package:university/core/services/auth_user_service.dart';
import 'package:university/core/services/class_service.dart';
import 'package:university/core/utilities/styles.constants.dart';
import 'package:university/pages/student/notes/notes_class_page.dart';

class DashboardStudentPage extends StatefulWidget {
  const DashboardStudentPage({super.key});

  @override
  State<DashboardStudentPage> createState() => _DashboardStudentPageState();
}

class _DashboardStudentPageState extends State<DashboardStudentPage> {
  List<ClassFirebase> listClass = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadClassesUser();
  }

  _loadClassesUser() async {
    try {
      await AuthUserService().loadUserFromCache();

      var classes = await ClassService().getClassesByStudentUid(
          studentUid: AuthUserService().currentUser!.uid);

      setState(() {
        listClass = classes;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      Exception("Erro loading classes in user $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarUserComponent(userFirebase: AuthUserService().currentUser),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  const Text(
                    'Cursos',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : listClass.isEmpty
                          ? const Center(
                              child: Text(
                                  "Não possui nenhuma turma, informe ao seu administrador"),
                            )
                          : Wrap(
                              spacing: 16,
                              runSpacing: 16,
                              children: listClass.map((classe) {
                                return SizedBox(
                                  width: 450,
                                  height: 230,
                                  child: Card(
                                    elevation: 1,
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Wrap(
                                            spacing:
                                                8, // Espaço entre ícone e texto
                                            children: [
                                              const Icon(
                                                Icons.school,
                                                color: Color.fromARGB(
                                                    255, 166, 196, 219),
                                                size: 20,
                                              ),
                                              Text(
                                                "Turma: ${classe.name}",
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          Wrap(
                                            spacing:
                                                8, // Espaço entre ícone e texto
                                            children: [
                                              const Icon(
                                                Icons.date_range,
                                                color: Color.fromARGB(
                                                    255, 166, 196, 219),
                                                size: 20,
                                              ),
                                              Text(
                                                  "Período: ${classe.startDate} a ${classe.endDate}")
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          Wrap(
                                            spacing:
                                                8, // Espaço entre ícone e texto
                                            children: [
                                              const Icon(
                                                Icons.computer,
                                                color: Color.fromARGB(
                                                    255, 166, 196, 219),
                                                size: 20,
                                              ),
                                              Text(
                                                  "Tipo da Turma: ${classe.typeClass}")
                                            ],
                                          ),
                                          const SizedBox(height: 30),
                                          Center(
                                            child: ElevatedButton(
                                              onPressed: () {
                                                Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        NotesClassPage(
                                                      classFirebase: classe,
                                                    ),
                                                  ),
                                                );
                                              },
                                              style: ElevatedButton.styleFrom(
                                                  elevation: 5,
                                                  backgroundColor: colorPrimaty,
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 45)),
                                              child: const Text(
                                                "Ver Notas",
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                ],
              ),
            ),
            const SizedBox(height: 330),
            const Footer(),
          ],
        ),
      ),
    );
  }
}
