import 'package:flutter/material.dart';
import 'package:university/components/app_bar_user_component.dart';
import 'package:university/components/drawer_secretary_component.dart';
import 'package:university/components/footer.dart';
import 'package:university/core/models/class_firebase.dart';
import 'package:university/core/models/user_firebase.dart';
import 'package:university/core/services/auth_user_service.dart';
import 'package:university/core/services/class_service.dart';

class HistoryNotesPage extends StatefulWidget {
  final UserFirebase user;
  const HistoryNotesPage({super.key, required this.user});

  @override
  State<HistoryNotesPage> createState() => _HistoryNotesPageState();
}

class _HistoryNotesPageState extends State<HistoryNotesPage> {
  List<ClassFirebase> listClass = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadClassesUser();
  }

  _loadClassesUser() async {
    try {
      var classes = await ClassService()
          .getClassesByStudentUid(studentUid: widget.user.uid);

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
      drawer: const DrawerSecretaryComponent(),
      body: SingleChildScrollView(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // bool isSmallScreen = constraints.maxWidth < 800;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Aluno ${widget.user.name}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text("Histórico de notas do Aluno"),
                      const SizedBox(height: 20),
                      isLoading
                          ? const Center(
                              child: CircularProgressIndicator(),
                            )
                          : listClass.isEmpty
                              ? const Center(
                                  child: Text("Nenhuma classe encontrada"),
                                )
                              : SizedBox(
                                  height: listClass.length * 130,
                                  child: ListView.builder(
                                    itemCount: listClass.length,
                                    itemBuilder: (context, index) {
                                      final classe = listClass[index];

                                      return Card.outlined(
                                        child: ListTile(
                                          contentPadding:
                                              const EdgeInsets.all(16),
                                          hoverColor: Colors.grey[200],
                                          title: Text(
                                            classe.name,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                            style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w800),
                                          ),
                                          subtitle: SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: Column(
                                              children: [
                                                Text(
                                                    "Périodo: ${classe.startDate} a ${classe.endDate}"),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                )
                    ],
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
