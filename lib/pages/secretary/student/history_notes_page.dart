import 'package:flutter/material.dart';
import 'package:university/components/app_bar_user_component.dart';
import 'package:university/components/drawer_secretary_component.dart';
import 'package:university/components/footer.dart';
import 'package:university/core/models/class_firebase.dart';
import 'package:university/core/models/note.dart';
import 'package:university/core/models/subject_module.dart';
import 'package:university/core/models/user_firebase.dart';
import 'package:university/core/models/user_note.dart';
import 'package:university/core/services/auth_user_service.dart';
import 'package:university/core/services/class_service.dart';
import 'package:university/core/services/note_service.dart';
import 'package:university/core/services/subject_service.dart';
import 'package:university/core/services/user_note_service.dart';

class HistoryNotesPage extends StatefulWidget {
  final UserFirebase user;
  const HistoryNotesPage({super.key, required this.user});

  @override
  State<HistoryNotesPage> createState() => _HistoryNotesPageState();
}

class _HistoryNotesPageState extends State<HistoryNotesPage> {
  List<ClassFirebase> listClass = [];
  List<SubjectModule> listSubject = [];
  List<Note> listNotes = [];
  List<UserNote> listUserNote = [];

  bool isLoading = true;
  bool isLoadingUserNote = true;

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
      _loadSubjects();
    } catch (e) {
      setState(() => isLoading = false);
      Exception("Erro loading classes in user $e");
    }
  }

  _loadSubjects() async {
    try {
      List<String> subjectUids = [];

      // Coleta os IDs de todas as matérias de todas as turmas
      for (var classe in listClass) {
        subjectUids.addAll(classe.subject);
      }

      // Remove duplicatas caso uma matéria esteja em mais de uma turma
      subjectUids = subjectUids.toSet().toList();

      var subjects =
          await SubjectService().getSubjectsByUids(uids: subjectUids);

      setState(() {
        listSubject = subjects;
      });

      for (var classe in listClass) {
        for (var subject in subjects) {
          if (classe.subject.contains(subject.uid)) {
            await _loadNotes(
              subjectId: subject.uid,
              teacherId: subject.userId,
              classId: classe.uid,
            );
          }
        }
      }

      for (var classe in listClass) {
        await _loadUserNotes(classId: classe.uid);
      }
    } catch (e) {
      Exception("Erro carregando matérias: $e");
    }
  }

  _loadNotes(
      {required String subjectId,
      required String teacherId,
      required String classId}) async {
    try {
      var notes = await NoteService().getListNotesByClass(
        userId: teacherId,
        classId: classId,
        subjectId: subjectId,
      );

      setState(() {
        listNotes.addAll(notes.where((newNote) =>
            !listNotes.any((existingNote) => existingNote.uid == newNote.uid)));
      });
    } catch (e) {
      Exception('Erro ao carregar notas do usuário $e');
    }
  }

  _loadUserNotes({required classId}) async {
    try {
      // uid do logado vai no teacherId :)
      var userNotes = await UserNoteService().getListUserNote(
        classId: classId,
      );

      setState(() {
        isLoadingUserNote = false;
        listUserNote.addAll(userNotes);
      });
    } catch (e) {
      setState(() => isLoadingUserNote = false);
      Exception("Erro loaging User Notes $e");
    }
  }

  double _calculateTotalScoreBySubject(
      String userId, String subjectId, String classId) {
    return listUserNote
        .where((userNote) =>
            userNote.userId == userId &&
            userNote.subjectId == subjectId &&
            userNote.classId == classId)
        .map((userNote) => double.tryParse(userNote.value) ?? 0.0)
        .fold(0.0, (sum, value) => sum + value);
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
                        "Aluno(a) ${widget.user.name}",
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
                                  height: listClass.length * 250,
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
                                                fontSize: 17,
                                                fontWeight: FontWeight.w800),
                                          ),
                                          subtitle: SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                    "Périodo: ${classe.startDate} a ${classe.endDate}"),
                                                const Text(
                                                  "Matérias:",
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: listSubject
                                                      .where((subject) => classe
                                                          .subject
                                                          .contains(
                                                              subject.uid))
                                                      .map(
                                                        (subject) => Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Row(
                                                              children: [
                                                                SizedBox(
                                                                  width: 180,
                                                                  child: Text(
                                                                    subject
                                                                        .title,
                                                                    style:
                                                                        const TextStyle(
                                                                      fontSize:
                                                                          16,
                                                                    ),
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    maxLines: 1,
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                    width: 20),
                                                                Wrap(
                                                                  spacing: 12.0,
                                                                  children:
                                                                      isLoadingUserNote
                                                                          ? [
                                                                              const SizedBox(height: 15, width: 15, child: CircularProgressIndicator())
                                                                            ]
                                                                          : listUserNote
                                                                              .where((userNote) => userNote.userId == widget.user.uid && userNote.subjectId == subject.uid && userNote.classId == classe.uid)
                                                                              .expand(
                                                                              (userNote) {
                                                                                var matchingNotes = listNotes.where(
                                                                                  (n) => n.uid == userNote.noteId,
                                                                                );

                                                                                return matchingNotes.map(
                                                                                  (note) => Chip(
                                                                                    label: Text("${note.title}: ${userNote.value.replaceAll(".", ",")}"),
                                                                                  ),
                                                                                );
                                                                              },
                                                                            ).toList(),
                                                                ),
                                                                const SizedBox(
                                                                    width: 20),
                                                                Text(
                                                                  "Soma: ${_calculateTotalScoreBySubject(widget.user.uid, subject.uid, classe.uid).toStringAsFixed(2).replaceAll('.', ',')}",
                                                                  style: const TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                              ],
                                                            ),
                                                            const SizedBox(
                                                                height: 5),
                                                            Container(
                                                              height: 1,
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  1,
                                                              color: const Color
                                                                  .fromARGB(
                                                                  255,
                                                                  133,
                                                                  215,
                                                                  226),
                                                            ),
                                                            const SizedBox(
                                                                height: 5),
                                                          ],
                                                        ),
                                                      )
                                                      .toList(),
                                                ),
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
