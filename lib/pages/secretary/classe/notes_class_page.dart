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
import 'package:university/pages/secretary/student/student_create_page.dart';

class NotesClassPage extends StatefulWidget {
  final ClassFirebase classFirebase;
  const NotesClassPage({super.key, required this.classFirebase});

  @override
  State<NotesClassPage> createState() => _NotesClassPageState();
}

class _NotesClassPageState extends State<NotesClassPage> {
  List<UserFirebase> listUser = [];
  List<UserFirebase> filteredListUser =
      []; // Nova lista para usuários filtrados
  List<UserFirebase> listTeacher = [];
  List<Note> listNotes = [];
  List<UserNote> listUserNote = [];
  List<SubjectModule> listSubject = [];
  Map<String, UserFirebase> teachersMap = {};
  Map<String, Map<DateTime, String>> presencaMap = {};
  bool isLoadingData = true;
  bool isGeneratingExcel = false;

  final TextEditingController _searchController =
      TextEditingController(); // Controlador para o campo de pesquisa

  @override
  void initState() {
    super.initState();
    _loadAllData();
    _searchController
        .addListener(_filterUsers); // Adiciona listener para filtrar ao digitar
  }

  @override
  void dispose() {
    _searchController.dispose(); // Libera o controlador
    super.dispose();
  }

  // Função para filtrar a lista de usuários
  void _filterUsers() {
    setState(() {
      if (_searchController.text.isEmpty) {
        filteredListUser =
            listUser; // Se a pesquisa estiver vazia, mostra todos
      } else {
        filteredListUser = listUser
            .where((user) => user.name
                .toLowerCase()
                .contains(_searchController.text.toLowerCase()))
            .toList();
      }
    });
  }

  _loadAllData() async {
    try {
      await Future.wait([
        _loadUserInClass(),
        _loadTeachers(),
        _loadSubjectsAndNotes(),
        _loadUserNotes(),
      ]);

      setState(() {
        isLoadingData = false;
        _filterUsers(); // Filtra a lista inicial assim que os dados são carregados
      });
    } catch (e) {
      log("Erro ao carregar todos os dados: $e");
      setState(() {
        isLoadingData = false;
      });
    }
  }

  Future<void> _loadUserInClass() async {
    try {
      var users = await AuthUserService()
          .getUsersByUids(uids: widget.classFirebase.students);
      setState(() {
        listUser = users..sort((a, b) => a.name.compareTo(b.name));
        filteredListUser =
            listUser; // Inicializa a lista filtrada com todos os usuários
      });
    } catch (e) {
      log("Erro ao carregar alunos na turma: $e");
    }
  }

  Future<void> _loadSubjectsAndNotes() async {
    try {
      var subjects = await SubjectService()
          .getSubjectsByUids(uids: widget.classFirebase.subject);

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

      listNotes.addAll(notes.where((newNote) =>
          !listNotes.any((existingNote) => existingNote.uid == newNote.uid)));
    } catch (e) {
      log('Erro ao carregar notas da matéria $subjectId: $e');
    }
  }

  Future<void> _loadPresence(
      {required String subjectId, required String teacherId}) async {
    final service = AttendenceListService();
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
      }());
    }
    await Future.wait(presenceFutures);
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
                                  height: 50,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: listSubject.length,
                                    itemBuilder: (context, index) {
                                      final subject = listSubject[index];
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
                      // Campo de pesquisa
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20.0),
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            labelText: 'Pesquisar Aluno',
                            hintText: 'Digite o nome do aluno',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      _searchController.clear();
                                      _filterUsers(); // Limpa a pesquisa e mostra todos os usuários
                                    },
                                  )
                                : null,
                          ),
                        ),
                      ),
                      isLoadingData
                          ? const Center(
                              child: CircularProgressIndicator(),
                            )
                          : filteredListUser.isEmpty // Usa filteredListUser
                              ? Center(
                                  child: Text(_searchController.text.isEmpty
                                      ? "Nenhum aluno encontrado."
                                      : "Nenhum aluno encontrado com o nome '${_searchController.text}'."),
                                )
                              : ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: filteredListUser
                                      .length, // Usa filteredListUser
                                  itemBuilder: (context, index) {
                                    final user = filteredListUser[
                                        index]; // Usa filteredListUser

                                    return Card.outlined(
                                      color: const Color.fromARGB(
                                          255, 237, 248, 248),
                                      shape: RoundedRectangleBorder(
                                        side: const BorderSide(
                                          color: Color.fromARGB(255, 160, 207,
                                              229), // cor da borda
                                          width: 1, // espessura da borda
                                        ),
                                        borderRadius: BorderRadius.circular(
                                            12), // opcional
                                      ),
                                      child: ExpansionTile(
                                        initiallyExpanded: false,
                                        title: Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "Matrícula: ${user.registration.toString()}",
                                                    style: const TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w800),
                                                  ),
                                                  Text(
                                                    "Nome: ${user.name}",
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                    style: const TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w800),
                                                  ),
                                                  Text(
                                                    "Email: ${user.email}",
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                    style: const TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w800),
                                                  ),
                                                  Text(
                                                    "CPF: ${user.cpf}",
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                    style: const TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w800),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: const Icon(
                                                  Icons.person_search),
                                              onPressed: () {
                                                Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        StudantCreatePage(
                                                      userStudent: user,
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16.0,
                                                vertical: 8.0),
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
                                                  var teacher = teachersMap[
                                                      subject.userId];
                                                  return SingleChildScrollView(
                                                    scrollDirection:
                                                        Axis.horizontal,
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        const SizedBox(
                                                            height: 5),
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
                                                                    listNotes
                                                                        .where(
                                                                  (n) =>
                                                                      n.uid ==
                                                                      userNote
                                                                          .noteId,
                                                                );
                                                                return matchingNotes
                                                                    .map(
                                                                  (note) =>
                                                                      Chip(
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
                                                                    fontSize:
                                                                        12),
                                                          ),
                                                        Text(
                                                          "Módulo ${subject.module}",
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 12),
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
                                                              .fromARGB(255,
                                                              133, 215, 226),
                                                        ),
                                                        const SizedBox(
                                                            height: 5),
                                                      ],
                                                    ),
                                                  );
                                                }),
                                              ],
                                            ),
                                          ),
                                        ],
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
