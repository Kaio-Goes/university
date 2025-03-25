import 'package:flutter/material.dart';
import 'package:university/components/app_bar_user_component.dart';
import 'package:university/components/create_note_card.dart';
import 'package:university/components/footer.dart';
import 'package:university/core/models/class_firebase.dart';
import 'package:university/core/models/note.dart';
import 'package:university/core/models/subject_module.dart';
import 'package:university/core/services/auth_user_service.dart';
import 'package:university/core/services/note_service.dart';

class CreateNotesPage extends StatefulWidget {
  final ClassFirebase classFirebase;
  final List<SubjectModule> listSubject;
  const CreateNotesPage(
      {super.key, required this.classFirebase, required this.listSubject});

  @override
  State<CreateNotesPage> createState() => _CreateNotesPageState();
}

class _CreateNotesPageState extends State<CreateNotesPage> {
  List<Note> listNotes = [];
  final _formKey = GlobalKey<FormState>();
  TextEditingController titleController = TextEditingController();
  TextEditingController noteController = TextEditingController();

  _clickButton({
    required String title,
    required String note,
    required String userId,
    required String classId,
  }) async {
    bool formOk = _formKey.currentState!.validate();

    if (!formOk) {
      return;
    }

    String formattedNote = note.replaceAll(',', '.');

    try {
      await NoteService()
          .createNote(
              title: title,
              note: formattedNote,
              userId: userId,
              classId: classId)
          .then((_) {
        sucessNoteCreate(
            // ignore: use_build_context_synchronously
            context: context,
            classFirebase: widget.classFirebase,
            listSubject: widget.listSubject);
      });
    } catch (e) {
      Exception('Erro create notes $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  _loadNotes() async {
    try {
      var notes = await NoteService().getListNotesByClass(
          userId: AuthUserService().currentUser!.uid,
          classId: widget.classFirebase.uid);

      setState(() {
        listNotes = notes;
      });
    } catch (e) {
      Exception('Erro ao carregar notas do usuário $e');
    }
  }

  double get totalSum =>
      listNotes.fold(0, (sum, note) => sum + double.parse(note.value));
  double get average => listNotes.isNotEmpty ? totalSum / 2 : 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarUserComponent(userFirebase: AuthUserService().currentUser),
      body: SingleChildScrollView(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // bool isSmallScreen = constraints.maxWidth < 800;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 15),
                      Text(
                        "Turma ${widget.classFirebase.name}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                          "Adicionar notas Trabalhos ou Provas para a matéria ${widget.listSubject.where((subject) => widget.classFirebase.subject.contains(subject.uid)).map((subject) => subject.title).join(', ')} "),
                      const SizedBox(height: 20),
                      TextButton.icon(
                        onPressed: () {
                          createNoteCard(
                            context: context,
                            formKey: _formKey,
                            titleController: titleController,
                            noteController: noteController,
                            onPressed: () {
                              _clickButton(
                                  title: titleController.text,
                                  note: noteController.text,
                                  userId: AuthUserService().currentUser!.uid,
                                  classId: widget.classFirebase.uid);
                            },
                          );
                        },
                        label: const Text("Adicionar"),
                        icon: const Icon(Icons.note_add_rounded),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: listNotes.length * 120,
                        child: ListView.builder(
                          itemCount: listNotes.length,
                          itemBuilder: (context, index) {
                            final note = listNotes[index];
                            return Card.outlined(
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),
                                hoverColor: Colors.grey[200],
                                title: Text(
                                  note.title,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800),
                                ),
                                subtitle: Text(
                                  "Nota: ${note.value}",
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600),
                                ),
                                leading: Container(
                                  height: 50,
                                  width: 50,
                                  decoration: BoxDecoration(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.note_alt_rounded,
                                    color: Colors.white,
                                  ),
                                ),
                                trailing: PopupMenuButton<String>(
                                  icon: const Icon(Icons.more_vert),
                                  onSelected: (String result) {
                                    setState(() {
                                      titleController.text = note.title;
                                      noteController.text =
                                          note.value.replaceAll('.', ',');
                                    });
                                    if (result == "Edit") {
                                      createNoteCard(
                                        title: "Editar Prova/Trabalho",
                                        context: context,
                                        formKey: _formKey,
                                        titleController: titleController,
                                        noteController: noteController,
                                        onPressed: () async {
                                          bool formOk =
                                              _formKey.currentState!.validate();

                                          if (!formOk) {
                                            return;
                                          }

                                          String formattedNote = noteController
                                              .text
                                              .replaceAll(',', '.');
                                          try {
                                            await NoteService()
                                                .updateNote(
                                              uid: note.uid,
                                              title: titleController.text,
                                              note: formattedNote,
                                              userId: AuthUserService()
                                                  .currentUser!
                                                  .uid,
                                              classId: note.classId,
                                            )
                                                .then((_) {
                                              sucessNoteCreate(
                                                  // ignore: use_build_context_synchronously
                                                  context: context,
                                                  classFirebase:
                                                      widget.classFirebase,
                                                  listSubject:
                                                      widget.listSubject);
                                            });
                                          } catch (e) {
                                            Exception(
                                                "Erro update note in user $e");
                                          }
                                        },
                                      );
                                    } else if (result == "Delete") {}
                                  },
                                  itemBuilder: (BuildContext context) =>
                                      <PopupMenuEntry<String>>[
                                    const PopupMenuItem<String>(
                                      value: "Edit",
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('Editar'),
                                          Icon(Icons.edit, size: 16)
                                        ],
                                      ),
                                    ),
                                    // const PopupMenuItem<String>(
                                    //   value: 'Delete',
                                    //   child: Row(
                                    //     mainAxisAlignment:
                                    //         MainAxisAlignment.spaceBetween,
                                    //     children: [
                                    //       Text('Excluir'),
                                    //       Icon(
                                    //         Icons.delete,
                                    //         size: 16,
                                    //         color: Colors.red,
                                    //       )
                                    //     ],
                                    //   ),
                                    // ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      Card(
                        margin: const EdgeInsets.only(top: 20),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "Soma Total das Notas:",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    totalSum.toStringAsFixed(2),
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "Média das Notas:",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    average.toStringAsFixed(2),
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                    ),
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
                const Footer(),
              ],
            );
          },
        ),
      ),
    );
  }
}
