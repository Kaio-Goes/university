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
import 'package:university/core/services/note_service.dart';
import 'package:university/core/services/subject_service.dart';
import 'package:university/core/services/user_note_service.dart';

class NotesClassPage extends StatefulWidget {
  final ClassFirebase classFirebase;
  const NotesClassPage({super.key, required this.classFirebase});

  @override
  State<NotesClassPage> createState() => _NotesClassPageState();
}

class _NotesClassPageState extends State<NotesClassPage> {
  List<UserFirebase> listUser = [];
  List<UserFirebase> listTeacher = [];
  List<Note> listNotes = [];
  List<UserNote> listUserNote = [];
  List<SubjectModule> listSubject = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserInClass();
    _loadSubjects();
    _loadTeachers();
    _loadUserNotes();
  }

  _loadUserInClass() async {
    try {
      var users = await AuthUserService()
          .getUsersByUids(uids: widget.classFirebase.students);

      setState(() {
        listUser = users..sort((a, b) => a.name.compareTo(b.name));
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      Exception("Erro loading student in class $e");
    }
  }

  _loadSubjects() async {
    try {
      var subjects = await SubjectService()
          .getSubjectsByUids(uids: widget.classFirebase.subject);

      setState(() {
        listSubject = subjects;
      });

      for (var subject in subjects) {
        await _loadNotes(subjectId: subject.uid, teacherId: subject.userId);
      }
    } catch (e) {
      Exception("Erro loadgin subjects in class $e");
    }
  }

  Future _loadTeachers() async {
    try {
      // Problemas com as duas requisições rodando ao mesmo tempo por isso o delayed
      await Future.delayed(const Duration(seconds: 1));
      Map<String, List<UserFirebase>> fetchedUsers =
          await AuthUserService().getAllUsers();

      List<UserFirebase> fetchedTeachers = fetchedUsers['teachers'] ?? [];

      var activeTeachers =
          fetchedTeachers.where((teacher) => teacher.isActive).toList();
      setState(() {
        listTeacher = activeTeachers;
      });
    } catch (e) {
      Exception('Erro loading users$e');
    }
  }

  _loadUserNotes() async {
    try {
      // uid do logado vai no teacherId :)
      var userNotes = await UserNoteService().getListUserNote(
        classId: widget.classFirebase.uid,
      );

      setState(() {
        listUserNote = userNotes;
      });
    } catch (e) {
      Exception("Erro loaging User Notes $e");
    }
  }

  _loadNotes({required String subjectId, required String teacherId}) async {
    try {
      var notes = await NoteService().getListNotesByClass(
        userId: teacherId,
        classId: widget.classFirebase.uid,
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

  double _calculateTotalScoreBySubject(String userId, String subjectId) {
    return listUserNote
        .where((userNote) =>
            userNote.userId == userId && userNote.subjectId == subjectId)
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
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Turma ${widget.classFirebase.name}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text("Visualize as notas dos Alunos"),
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
                                  height: listUser.length * 130,
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
                                          subtitle: SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  "Matérias:",
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w700),
                                                ),
                                                const SizedBox(height: 5),
                                                ...listSubject.map((subject) {
                                                  var teacher = listTeacher
                                                      .where((t) =>
                                                          t.uid ==
                                                          subject.userId)
                                                      .firstOrNull;
                                                  return Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      const SizedBox(height: 5),
                                                      Row(
                                                        children: [
                                                          SizedBox(
                                                            width: 180,
                                                            child: Text(
                                                              subject.title,
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 15,
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
                                                            children: listUserNote
                                                                .where((userNote) =>
                                                                    userNote.userId ==
                                                                        user
                                                                            .uid &&
                                                                    userNote.subjectId ==
                                                                        subject
                                                                            .uid)
                                                                .expand(
                                                                    (userNote) {
                                                              // Filtra todas as notas que correspondem ao userNote.noteId
                                                              var matchingNotes =
                                                                  listNotes
                                                                      .where(
                                                                (n) =>
                                                                    n.uid ==
                                                                    userNote
                                                                        .noteId,
                                                              );

                                                              // Mapeia cada nota correspondente para um Chip
                                                              return matchingNotes
                                                                  .map(
                                                                (note) => Chip(
                                                                  label: Text(
                                                                      "${note.title}: ${userNote.value.replaceAll(".", ",")}"),
                                                                  backgroundColor:
                                                                      const Color
                                                                          .fromARGB(
                                                                          24,
                                                                          224,
                                                                          248,
                                                                          250),
                                                                ),
                                                              );
                                                            }).toList(),
                                                          ),
                                                          const SizedBox(
                                                              width: 20),
                                                          Text(
                                                            "Soma: ${_calculateTotalScoreBySubject(user.uid, subject.uid).toStringAsFixed(2).replaceAll('.', ',')}",
                                                            style: const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                        ],
                                                      ),
                                                      if (teacher != null)
                                                        Text(
                                                          "Professor ${teacher.name} ${teacher.surname}",
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 12),
                                                        ),
                                                      const SizedBox(height: 5)
                                                    ],
                                                  );
                                                }),
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
