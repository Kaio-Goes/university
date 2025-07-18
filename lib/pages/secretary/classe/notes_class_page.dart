import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:university/components/app_bar_user_component.dart';
import 'package:university/components/drawer_secretary_component.dart';
import 'package:university/components/footer.dart';
import 'package:university/core/models/class_firebase.dart';
import 'package:university/core/models/note.dart';
import 'package:university/core/models/subject_module.dart';
import 'package:university/core/models/user_firebase.dart';
import 'package:university/core/models/user_note.dart';
import 'package:university/core/services/attendence_list_service.dart';
import 'package:university/core/services/auth_user_service.dart';
import 'package:university/core/services/generate_excel_service.dart';
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
  Map<String, Map<DateTime, String>> presencaMap = {};
  bool isLoading = true;
  bool isLoadingTeacher = true;
  bool isLoadingSubject = true;
  bool isLoadingUserNote = true;

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
        log(users.length.toString());
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
        isLoadingSubject = false;
      });

      for (var subject in subjects) {
        await _loadNotes(subjectId: subject.uid, teacherId: subject.userId);
      }
    } catch (e) {
      setState(() => isLoadingSubject = false);
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
        isLoadingTeacher = false;
        listTeacher = activeTeachers;
      });
    } catch (e) {
      setState(() => isLoadingTeacher = false);
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
        isLoadingUserNote = false;
      });
    } catch (e) {
      setState(() => isLoadingUserNote = false);
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

  Future<void> _loadPresence(
      {required String subjectId, required String teacherId}) async {
    final service = AttendenceListService();

    for (final aluno in listUser) {
      final attendenceList = await service.getAttendenceList(
          studentId: aluno.uid,
          teacherId: teacherId,
          classId: widget.classFirebase.uid,
          subjectId: subjectId);

      for (final presence in attendenceList) {
        final date = presence.dateClass;

        final inputFormat = DateFormat('dd/MM/yyyy');
        final parsedDate = inputFormat.parse(date);

        presencaMap[aluno.uid] ??= {};
        presencaMap[aluno.uid]![parsedDate] = presence.status;
      }
    }

    setState(() {});
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
                      const SizedBox(height: 20),
                      const Text("Visualize Diário de Classe pelas Matérias"),
                      const SizedBox(height: 5),
                      isLoadingSubject
                          ? const Center(child: CircularProgressIndicator())
                          : listSubject.isEmpty
                              ? const Center(
                                  child: Text("Nenhuma Matéria adicionada"),
                                )
                              : SizedBox(
                                  height: listSubject.length * 20,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: listSubject.length,
                                    itemBuilder: (context, index) {
                                      final subject = listSubject[index];

                                      var teacher = listTeacher
                                          .where((t) => t.uid == subject.userId)
                                          .firstOrNull;
                                      return Wrap(
                                        spacing: 12,
                                        runSpacing: 12,
                                        children: [
                                          isLoadingTeacher
                                              ? ElevatedButton.icon(
                                                  onPressed:
                                                      null, // desabilita enquanto carrega
                                                  icon: const SizedBox(
                                                    height: 20,
                                                    width: 20,
                                                    child:
                                                        CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  label: const Text(
                                                    'Gerando...',
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        const Color.fromARGB(
                                                            255, 69, 106, 185),
                                                  ),
                                                )
                                              : ElevatedButton.icon(
                                                  onPressed: () async {
                                                    setState(() =>
                                                        isLoadingTeacher =
                                                            true);

                                                    await _loadPresence(
                                                      subjectId: subject.uid,
                                                      teacherId: teacher!.uid,
                                                    );

                                                    generateExcel(
                                                      users: listUser,
                                                      subject: subject,
                                                      daysWeeksSubject:
                                                          subject.daysWeek,
                                                      classTitle: widget
                                                          .classFirebase.name,
                                                      stardDateClass: widget
                                                          .classFirebase
                                                          .startDate,
                                                      endDateClass: widget
                                                          .classFirebase
                                                          .endDate,
                                                      teacherName: teacher.name,
                                                      listNotes: listNotes,
                                                      presencaMap: presencaMap,
                                                      listUserNote:
                                                          listUserNote,
                                                    );

                                                    setState(() =>
                                                        isLoadingTeacher =
                                                            false);
                                                  },
                                                  iconAlignment:
                                                      IconAlignment.end,
                                                  label: Text(
                                                    subject.title,
                                                    style: const TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                  icon: const Icon(
                                                    Icons.description_outlined,
                                                    color: Colors.white,
                                                  ),
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        const Color.fromARGB(
                                                            255, 69, 106, 185),
                                                  ),
                                                ),
                                          const SizedBox(width: 5)
                                        ],
                                      );
                                    },
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
                                  height: listUser.length * 300,
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
                                                fontSize: 17,
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
                                                    fontWeight: FontWeight.w700,
                                                  ),
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
                                                                fontSize: 16,
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
                                                                        const CircularProgressIndicator()
                                                                      ]
                                                                    : listUserNote
                                                                        .where((userNote) =>
                                                                            userNote.userId == user.uid &&
                                                                            userNote.subjectId ==
                                                                                subject.uid)
                                                                        .expand((userNote) {
                                                                        // Filtra todas as notas que correspondem ao userNote.noteId
                                                                        var matchingNotes =
                                                                            listNotes.where(
                                                                          (n) =>
                                                                              n.uid ==
                                                                              userNote.noteId,
                                                                        );

                                                                        // Mapeia cada nota correspondente para um Chip
                                                                        return matchingNotes
                                                                            .map(
                                                                          (note) =>
                                                                              Chip(
                                                                            label:
                                                                                Text("${note.title}: ${userNote.value.replaceAll(".", ",")}"),
                                                                            backgroundColor: const Color.fromARGB(
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
                                                      Text(
                                                        "Módulo ${subject.module}",
                                                        style: const TextStyle(
                                                            fontSize: 12),
                                                      ),
                                                      const SizedBox(height: 5),
                                                      Container(
                                                        height: 1,
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            1,
                                                        color: const Color
                                                            .fromARGB(
                                                            255, 133, 215, 226),
                                                      ),
                                                      const SizedBox(height: 5),
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
