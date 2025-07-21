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
  Map<String, UserFirebase> teachersMap =
      {}; // Para busca rápida de professores
  Map<String, Map<DateTime, String>> presencaMap = {};
  bool isLoadingData = true; // Unificado para todas as cargas iniciais
  bool isGeneratingExcel = false; // Novo estado para geração de excel

  @override
  void initState() {
    super.initState();
    _loadAllData(); // Chamada única para carregar tudo em paralelo
  }

  // Carrega todos os dados iniciais em paralelo
  _loadAllData() async {
    try {
      await Future.wait([
        _loadUserInClass(),
        _loadTeachers(), // Carrega professores em paralelo
        _loadSubjectsAndNotes(), // Carrega matérias e suas notas
        _loadUserNotes(),
      ]);

      setState(() {
        isLoadingData = false;
      });
    } catch (e) {
      log("Erro ao carregar todos os dados: $e");
      setState(() {
        isLoadingData = false;
      });
      // Poderia exibir um erro ao usuário aqui
    }
  }

  Future<void> _loadUserInClass() async {
    try {
      var users = await AuthUserService()
          .getUsersByUids(uids: widget.classFirebase.students);
      setState(() {
        listUser = users..sort((a, b) => a.name.compareTo(b.name));
      });
    } catch (e) {
      log("Erro ao carregar alunos na turma: $e");
    }
  }

  // Carrega as matérias e, em seguida, as notas para cada matéria
  Future<void> _loadSubjectsAndNotes() async {
    try {
      var subjects = await SubjectService()
          .getSubjectsByUids(uids: widget.classFirebase.subject);

      // Carrega notas para todas as matérias em paralelo
      List<Future<void>> noteLoadFutures = [];
      for (var subject in subjects) {
        noteLoadFutures
            .add(_loadNotes(subjectId: subject.uid, teacherId: subject.userId));
      }
      await Future.wait(noteLoadFutures);

      setState(() {
        listSubject = subjects;
      });
    } catch (e) {
      log("Erro ao carregar matérias na turma: $e");
    }
  }

  Future<void> _loadTeachers() async {
    try {
      Map<String, List<UserFirebase>> fetchedUsers =
          await AuthUserService().getAllUsers();

      List<UserFirebase> fetchedTeachers = fetchedUsers['teachers'] ?? [];
      var activeTeachers =
          fetchedTeachers.where((teacher) => teacher.isActive).toList();

      // Otimização: Criar um mapa de professores para busca O(1)
      teachersMap = {for (var t in activeTeachers) t.uid: t};

      setState(() {
        listTeacher = activeTeachers;
      });
    } catch (e) {
      log('Erro ao carregar professores: $e');
    }
  }

  Future<void> _loadUserNotes() async {
    try {
      var userNotes = await UserNoteService().getListUserNote(
        classId: widget.classFirebase.uid,
      );

      setState(() {
        listUserNote = userNotes;
      });
    } catch (e) {
      log("Erro ao carregar notas de usuário: $e");
    }
  }

  Future<void> _loadNotes(
      {required String subjectId, required String teacherId}) async {
    try {
      var notes = await NoteService().getListNotesByClass(
        userId: teacherId,
        classId: widget.classFirebase.uid,
        subjectId: subjectId,
      );

      // Adiciona notas de forma segura, evitando duplicatas e garantindo que o setState não seja chamado em excesso.
      // A atualização do estado é feita uma única vez após o carregamento de todas as notas em _loadSubjectsAndNotes.
      // Se _loadNotes for chamado individualmente em outro contexto, o setState seria necessário aqui.
      // Como estamos agrupando, podemos apenas adicionar à lista.
      listNotes.addAll(notes.where((newNote) =>
          !listNotes.any((existingNote) => existingNote.uid == newNote.uid)));
    } catch (e) {
      log('Erro ao carregar notas da matéria $subjectId: $e');
    }
  }

  Future<void> _loadPresence(
      {required String subjectId, required String teacherId}) async {
    final service = AttendenceListService();
    // Limpa o mapa de presença para evitar dados de matérias anteriores
    presencaMap = {};

    List<Future<void>> presenceFutures = [];
    for (final aluno in listUser) {
      presenceFutures.add(() async {
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
      }()); // Imediatamente invoca a função assíncrona
    }
    await Future.wait(presenceFutures);
    setState(() {}); // Atualiza a UI após todas as presenças serem carregadas
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
                      isLoadingData
                          ? const Center(child: CircularProgressIndicator())
                          : listSubject.isEmpty
                              ? const Center(
                                  child: Text("Nenhuma Matéria adicionada"),
                                )
                              : SizedBox(
                                  height: listSubject.length * 5,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: listSubject.length,
                                    itemBuilder: (context, index) {
                                      final subject = listSubject[index];
                                      // Usa o mapa para busca O(1)
                                      var teacher = teachersMap[subject.userId];

                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(right: 12.0),
                                        child: isGeneratingExcel
                                            ? ElevatedButton.icon(
                                                onPressed: null,
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
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      const Color.fromARGB(
                                                          255, 69, 106, 185),
                                                ),
                                              )
                                            : ElevatedButton.icon(
                                                onPressed: () async {
                                                  if (teacher == null) {
                                                    // Tratar caso o professor não seja encontrado
                                                    log("Professor não encontrado para a matéria ${subject.title}");
                                                    return;
                                                  }
                                                  setState(() =>
                                                      isGeneratingExcel = true);

                                                  await _loadPresence(
                                                    subjectId: subject.uid,
                                                    teacherId: teacher.uid,
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
                                                        .classFirebase.endDate,
                                                    teacherName: teacher.name,
                                                    listNotes: listNotes,
                                                    presencaMap: presencaMap,
                                                    listUserNote: listUserNote,
                                                  );

                                                  setState(() =>
                                                      isGeneratingExcel =
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
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      const Color.fromARGB(
                                                          255, 69, 106, 185),
                                                ),
                                              ),
                                      );
                                    },
                                  ),
                                ),
                      const SizedBox(height: 5),
                      const Text("Visualize as notas dos Alunos"),
                      const SizedBox(height: 20),
                      isLoadingData
                          ? const Center(
                              child: CircularProgressIndicator(),
                            )
                          : listUser.isEmpty
                              ? const Center(
                                  child: Text("Nenhum aluno encontrado."),
                                )
                              : ListView.builder(
                                  shrinkWrap:
                                      true, // Importante para evitar erros de altura
                                  physics:
                                      const NeverScrollableScrollPhysics(), // Desabilita o scroll interno
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
                                                // Usa o mapa para busca O(1)
                                                var teacher =
                                                    teachersMap[subject.userId];
                                                return Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
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
                                                            var matchingNotes =
                                                                listNotes.where(
                                                              (n) =>
                                                                  n.uid ==
                                                                  userNote
                                                                      .noteId,
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
                                                        style: const TextStyle(
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
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              1,
                                                      color:
                                                          const Color.fromARGB(
                                                              255,
                                                              133,
                                                              215,
                                                              226),
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
