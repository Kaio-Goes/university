import 'package:flutter/material.dart';
import 'package:university/components/app_bar_user_component.dart';
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
  List<SubjectModule> listSubject = [];
  List<UserFirebase> listTeacher = [];
  List<Note> listNotes = [];
  List<UserNote> listUserNote = [];

  bool isLoadingSubject = true;
  bool isLoadingUserNote = true;

  @override
  void initState() {
    super.initState();
    _loadSubjects();
    _loadTeachers();
    _loadUserNotes();
  }

  _loadSubjects() async {
    try {
      var subjects = await SubjectService()
          .getSubjectsByUids(uids: widget.classFirebase.subject);

      setState(() {
        isLoadingSubject = false;
        listSubject = subjects;
      });

      for (var subject in subjects) {
        await _loadNotes(subjectId: subject.uid, teacherId: subject.userId);
      }
    } catch (e) {
      setState(() => isLoadingSubject = false);
      Exception("Erro carregando matérias: $e");
    }
  }

  Future _loadTeachers() async {
    try {
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

  _loadUserNotes() async {
    try {
      var userNotes = await UserNoteService().getListUserNote(
        classId: widget.classFirebase.uid,
        userId: AuthUserService().currentUser!.uid,
      );

      setState(() {
        listUserNote = userNotes;
        isLoadingUserNote = false;
      });
    } catch (e) {
      setState(() => isLoadingUserNote = false);
      Exception("Erro loaging User Notes $e");
    }
  }

  double _calculateTotalScoreBySubject(String userId, String subjectId) {
    return listUserNote
            .where((userNote) =>
                userNote.userId == userId && userNote.subjectId == subjectId)
            .map((userNote) => double.tryParse(userNote.value) ?? 0.0)
            .fold(0.0, (sum, value) => sum + value) /
        2;
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
                      Text(
                        "Turma: ${widget.classFirebase.name}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text("Visualize suas notas"),
                      const SizedBox(height: 20),
                      isLoadingSubject
                          ? const Center(child: CircularProgressIndicator())
                          : listSubject.isEmpty
                              ? const Center(child: Text("Não possui Matérias"))
                              : SizedBox(
                                  height: listSubject.length * 220,
                                  child: ListView.builder(
                                    itemCount: listSubject.length,
                                    itemBuilder: (context, index) {
                                      final subject = listSubject[index];

                                      var teacher = listTeacher
                                          .where((t) => t.uid == subject.userId)
                                          .firstOrNull;

                                      return Card.outlined(
                                        child: ListTile(
                                          contentPadding:
                                              const EdgeInsets.all(16),
                                          hoverColor: Colors.grey[200],
                                          title: Text(
                                            subject.title,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                            style: const TextStyle(
                                                fontSize: 17,
                                                fontWeight: FontWeight.w800),
                                          ),
                                          subtitle: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              if (teacher != null)
                                                Text(
                                                  "Professor ${teacher.name} ${teacher.surname}",
                                                  style: const TextStyle(
                                                      fontSize: 16),
                                                ),
                                              Text("Módulo: ${subject.module}"),
                                              Text(
                                                  "Dias de Aulas: ${subject.daysWeek.replaceAll('[', '').replaceAll(']', '')}"),
                                              Text(
                                                  "Horário: ${subject.startHour} as ${subject.endHour}"),
                                              Text(
                                                  "Total de Horas: ${subject.hour}hr"),
                                              const SizedBox(height: 10),
                                              isLoadingUserNote
                                                  ? const SizedBox(
                                                      height: 15,
                                                      width: 15,
                                                      child:
                                                          CircularProgressIndicator(),
                                                    )
                                                  : Wrap(
                                                      spacing: 8.0,
                                                      runSpacing: 4.0,
                                                      children: listUserNote
                                                          .where((userNote) =>
                                                              userNote.userId ==
                                                                  AuthUserService()
                                                                      .currentUser!
                                                                      .uid &&
                                                              userNote.subjectId ==
                                                                  subject.uid)
                                                          .expand((userNote) {
                                                        var matchingNotes =
                                                            listNotes.where(
                                                          (n) =>
                                                              n.uid ==
                                                              userNote.noteId,
                                                        );
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
                                              const SizedBox(height: 10),
                                              Text(
                                                "Média: ${_calculateTotalScoreBySubject(AuthUserService().currentUser!.uid, subject.uid).toStringAsFixed(2).replaceAll('.', ',')}",
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                )
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                const Footer(),
              ],
            );
          },
        ),
      ),
    );
  }
}
