import 'package:flutter/material.dart';
import 'package:university/components/add_notes_card.dart';
import 'package:university/components/app_bar_user_component.dart';
import 'package:university/components/footer.dart';
import 'package:university/core/models/class_firebase.dart';
import 'package:university/core/models/note.dart';
import 'package:university/core/models/user_firebase.dart';
import 'package:university/core/models/user_note.dart';
import 'package:university/core/services/auth_user_service.dart';
import 'package:university/core/services/note_service.dart';
import 'package:university/core/services/user_note_service.dart';
import 'package:university/core/utilities/styles.constants.dart';

class AddNotesStudentPage extends StatefulWidget {
  final ClassFirebase classe;
  const AddNotesStudentPage({super.key, required this.classe});

  @override
  State<AddNotesStudentPage> createState() => _AddNotesStudentPageState();
}

class _AddNotesStudentPageState extends State<AddNotesStudentPage> {
  List<UserFirebase> listUser = [];
  List<Note> listNotes = [];
  List<UserNote> listUserNote = [];
  bool isLoading = true;

  @override
  initState() {
    super.initState();
    _loadUserInClass();
    _loadNotes();
    _loadUserNotes();
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

  _loadNotes() async {
    try {
      var notes = await NoteService().getListNotesByClass(
          userId: AuthUserService().currentUser!.uid,
          classId: widget.classe.uid);

      setState(() {
        listNotes = notes;
      });
    } catch (e) {
      Exception('Erro ao carregar notas do usuário $e');
    }
  }

  _loadUserNotes({String? studentId}) async {
    try {
      // uid do logado vai no teacherId :)
      var userNotes = await UserNoteService().getListUserNote(
          classId: widget.classe.uid,
          userId: studentId,
          teacherId: AuthUserService().currentUser!.uid);

      setState(() {
        listUserNote = userNotes;
      });
    } catch (e) {
      Exception("Erro loaging User Notes $e");
    }
  }

  String _calculateAverage(Map<String, String> userNotesUidMap) {
    List<double> validNotes = userNotesUidMap.values
        .where((value) => value != "N/A")
        .map((value) => double.tryParse(value.replaceAll(',', '.')) ?? 0.0)
        .toList();

    if (validNotes.isEmpty) return "N/A";

    double sum = validNotes.reduce((a, b) => a + b);
    double average = sum;

    return average.toStringAsFixed(2);
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

                                      Map<String, String> userNotesUidMap = {
                                        for (var userNote in listUserNote.where(
                                            (note) => note.userId == user.uid))
                                          userNote.noteId: userNote.value
                                      };

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
                                          subtitle: SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      "Email: ${user.email}",
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 1,
                                                      style: const TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w600),
                                                    ),
                                                    Text(
                                                        "Celular: ${user.phone}")
                                                  ],
                                                ),
                                                const SizedBox(width: 20),
                                                Wrap(
                                                  spacing: 12.0,
                                                  children:
                                                      listNotes.map((note) {
                                                    // Pegando a nota correspondente do userNotesUidMap
                                                    String userNoteValue =
                                                        userNotesUidMap[
                                                                    note.uid]
                                                                ?.replaceAll(
                                                                    '.', ',') ??
                                                            "N/A";

                                                    return Chip(
                                                      label: Text(
                                                          '${note.title}: $userNoteValue'),
                                                    );
                                                  }).toList(),
                                                ),
                                                const SizedBox(width: 20),
                                                Text(
                                                    "Soma das Notas: ${_calculateAverage(userNotesUidMap)}"),
                                              ],
                                            ),
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
                                          trailing: ElevatedButton.icon(
                                            onPressed: () async {
                                              if (listNotes.isEmpty) {
                                                showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return AlertDialog(
                                                      title: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          const Text(
                                                              "Não permitido"),
                                                          IconButton(
                                                            onPressed: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            },
                                                            icon: const Icon(
                                                                Icons.close),
                                                          )
                                                        ],
                                                      ),
                                                      content: const Text(
                                                          "Para adicionar nota ao Aluno é necessario criar as notas"),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () {
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                          style: ElevatedButton.styleFrom(
                                                              elevation: 5,
                                                              backgroundColor:
                                                                  Colors
                                                                      .redAccent,
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          30)),
                                                          child: const Text(
                                                            'Entendi',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white),
                                                          ),
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );
                                              } else {
                                                // Mostra um diálogo de carregamento enquanto busca as notas
                                                showDialog(
                                                  context: context,
                                                  barrierDismissible:
                                                      false, // Impede fechar enquanto carrega
                                                  builder: (context) {
                                                    return const AlertDialog(
                                                      content: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          CircularProgressIndicator(),
                                                          SizedBox(height: 16),
                                                          Text(
                                                              "Carregando notas..."),
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                );

                                                // Aguarda carregar os dados
                                                await _loadUserNotes(
                                                    studentId: user.uid);

                                                // Fecha o diálogo de carregamento
                                                if (context.mounted) {
                                                  Navigator.pop(context);
                                                }

                                                // Exibe o modal de notas
                                                addNotesCard(
                                                  // ignore: use_build_context_synchronously
                                                  context: context,
                                                  user: user,
                                                  classe: widget.classe,
                                                  listNotes: listNotes,
                                                  listUserNotes: listUserNote,
                                                );
                                              }
                                            },
                                            style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    const Color.fromARGB(
                                                        255, 69, 106, 185)),
                                            icon: const Icon(
                                              Icons.edit,
                                              color: Colors.white,
                                            ),
                                            iconAlignment: IconAlignment.end,
                                            label: const Text(
                                              "NOTAS",
                                              style: TextStyle(
                                                  color: Colors.white),
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
