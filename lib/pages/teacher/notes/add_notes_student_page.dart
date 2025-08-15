import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:university/components/add_notes_card.dart';
import 'package:university/components/app_bar_user_component.dart';
import 'package:university/core/models/attendence_list.dart';
import 'package:university/core/models/class_firebase.dart';
import 'package:university/core/models/note.dart';
import 'package:university/core/models/subject_module.dart';
import 'package:university/core/models/user_firebase.dart';
import 'package:university/core/models/user_note.dart';
import 'package:university/core/services/attendence_list_service.dart';
import 'package:university/core/services/auth_user_service.dart';
import 'package:university/core/services/note_service.dart';
import 'package:university/core/services/user_note_service.dart';
import 'package:university/core/utilities/styles.constants.dart';
import 'package:university/pages/teacher/dashboard/dashboard_teacher_page.dart';
import 'package:university/pages/teacher/notes/create_notes_page.dart';

class AddNotesStudentPage extends StatefulWidget {
  final ClassFirebase classe;
  final SubjectModule subject;
  const AddNotesStudentPage({
    super.key,
    required this.classe,
    required this.subject,
  });

  @override
  State<AddNotesStudentPage> createState() => _AddNotesStudentPageState();
}

class _AddNotesStudentPageState extends State<AddNotesStudentPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  List<UserFirebase> listUser = [];
  List<Note> listNotes = [];
  List<UserNote> listUserNote = [];
  bool isLoading = true;
  Map<String, Map<DateTime, String>> presencaMap = {};
  late List<DateTime> datasAulas; // Inicializada uma única vez

  @override
  initState() {
    super.initState();
    _loadAllData(); // Chama uma única função para carregar todos os dados
  }

  Future<void> _loadAllData() async {
    setState(() {
      isLoading = true; // Inicia o carregamento
    });

    try {
      final String currentTeacherUid = AuthUserService().currentUser!.uid;

      // Usar Future.wait para carregar dados em paralelo
      final results = await Future.wait([
        AuthUserService().getUsersByUids(uids: widget.classe.students),
        NoteService().getListNotesByClass(
          userId: currentTeacherUid,
          classId: widget.classe.uid,
          subjectId: widget.subject.uid,
        ),
        UserNoteService().getListUserNote(
          classId: widget.classe.uid,
          teacherId: currentTeacherUid,
          subjectId: widget.subject.uid,
        ),
      ]);

      setState(() {
        listUser = (results[0] as List<UserFirebase>)
          ..sort((a, b) => a.name.compareTo(b.name));
        listNotes = results[1] as List<Note>;
        listUserNote = results[2] as List<UserNote>;
      });

      // Carregar presenças de forma otimizada
      await _loadPresenceOptimized();

      // Calcular datas das aulas uma única vez
      datasAulas = _getDatesByWeekdays();
    } catch (e) {
      log("Erro ao carregar dados iniciais: $e");
      // Opcional: mostrar um diálogo ou snackbar de erro
    } finally {
      setState(() {
        isLoading = false; // Finaliza o carregamento
      });
    }
  }

  Future<void> _loadPresenceOptimized() async {
    if (listUser.isEmpty) return;

    final service = AttendenceListService();
    final String currentTeacherUid = AuthUserService().currentUser!.uid;

    final List<Future<List<AttendenceList>>> attendanceFutures =
        listUser.map((aluno) {
      return service.getAttendenceList(
        studentId: aluno.uid,
        teacherId: currentTeacherUid,
        classId: widget.classe.uid,
        subjectId: widget.subject.uid,
      );
    }).toList();

    final List<List<AttendenceList>> allAttendences =
        await Future.wait(attendanceFutures);

    final Map<String, Map<DateTime, String>> newPresencaMap = {};
    final DateFormat inputFormat = DateFormat('dd/MM/yyyy');

    for (int i = 0; i < listUser.length; i++) {
      final alunoUid = listUser[i].uid;
      newPresencaMap.putIfAbsent(alunoUid, () => {});
      for (final presence in allAttendences[i]) {
        final parsedDate = inputFormat.parse(presence.dateClass);
        newPresencaMap[alunoUid]![parsedDate] = presence.status;
      }
    }
    // Atualiza o mapa de presença no estado
    setState(() {
      presencaMap = newPresencaMap;
    });
  }

  // Renomeado para seguir convenção de método privado e chamar uma vez
  List<DateTime> _getDatesByWeekdays() {
    final Map<String, int> diasSemanaMap = {
      "Segunda-feira": DateTime.monday,
      "Terça-feira": DateTime.tuesday,
      "Quarta-feira": DateTime.wednesday,
      "Quinta-feira": DateTime.thursday,
      "Sexta-feira": DateTime.friday,
      "Sábado": DateTime.saturday,
      "Domingo": DateTime.sunday,
    };

    final diasSelecionados = widget.subject.daysWeek
        .replaceAll('[', '')
        .replaceAll(']', '')
        .split(',')
        .map((dia) => diasSemanaMap[dia.trim()])
        .whereType<int>()
        .toList();

    final formatter = DateFormat('d/M/y');
    final dataInicial = formatter.parse(widget.classe.startDate);
    final dataFinal = formatter.parse(widget.classe.endDate);

    final datasFiltradas = <DateTime>[];

    for (DateTime data = dataInicial;
        !data.isAfter(dataFinal);
        data = data.add(const Duration(days: 1))) {
      if (diasSelecionados.contains(data.weekday)) {
        datasFiltradas.add(data);
      }
    }

    return datasFiltradas;
  }

  // Refatorado para ser chamado externamente apenas quando necessário
  Future<void> _loadUserNotes({String? studentId}) async {
    try {
      var userNotes = await UserNoteService().getListUserNote(
          classId: widget.classe.uid,
          userId: studentId, // Pode ser null para carregar todos, ou específico
          teacherId: AuthUserService().currentUser!.uid,
          subjectId: widget.subject.uid);

      setState(() {
        // Se studentId for fornecido, atualiza apenas as notas daquele aluno
        if (studentId != null) {
          // Remove as notas antigas do aluno e adiciona as novas
          listUserNote.removeWhere((note) => note.userId == studentId);
          listUserNote.addAll(userNotes);
        } else {
          // Caso contrário, substitui todas as notas (carregamento inicial)
          listUserNote = userNotes;
        }
      });
    } catch (e) {
      log("Erro ao carregar notas do usuário: $e");
    }
  }

  String _calculateAverage(Map<String, String> userNotesUidMap) {
    List<double> validNotes = userNotesUidMap.values
        .where((value) => value != "N/A")
        .map((value) => double.tryParse(value.replaceAll(',', '.')) ?? 0.0)
        .toList();

    if (validNotes.isEmpty) return "N/A";

    double sum = validNotes.reduce((a, b) => a + b);
    double average = sum / 2;

    return average.toStringAsFixed(2);
  }

  // Novo widget para gerenciar a lista de presenças em um modal
  Widget _buildAttendanceManagementList(
      UserFirebase user, List<DateTime> datas) {
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter modalSetState) {
        return ListView.builder(
          itemCount: datas.length,
          itemBuilder: (context, dateIndex) {
            final data = datas[dateIndex];
            final formattedDate = DateFormat('dd/MM/yyyy').format(data);

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      formattedDate,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: DropdownButtonFormField<String>(
                      value: presencaMap[user.uid]?[data],
                      items: const [
                        DropdownMenuItem(
                            value: "Presente", child: Text("Presente")),
                        DropdownMenuItem(value: "Falta", child: Text("Falta")),
                        DropdownMenuItem(
                            value: "Feriado", child: Text("Feriado")),
                        DropdownMenuItem(
                            value: "Atestado", child: Text("Atestado")),
                      ],
                      onChanged: (value) async {
                        // Atualiza o mapa de presenças localmente no modal
                        modalSetState(() {
                          presencaMap[user.uid] ??= {};
                          presencaMap[user.uid]![data] = value!;
                        });

                        // Persiste a mudança no Firebase
                        final service = AttendenceListService();
                        final String currentTeacherUid =
                            AuthUserService().currentUser!.uid;

                        try {
                          final attendenceList =
                              await service.getAttendenceList(
                            studentId: user.uid,
                            teacherId: currentTeacherUid,
                            classId: widget.classe.uid,
                            subjectId: widget.subject.uid,
                          );

                          bool found = false;
                          for (final presence in attendenceList) {
                            if (presence.dateClass == formattedDate) {
                              await service.updateAttendenceList(
                                uid: presence.uid,
                                studentId: user.uid,
                                teacherId: currentTeacherUid,
                                subjectId: widget.subject.uid,
                                classId: widget.classe.uid,
                                status: value!,
                              );
                              found = true;
                              break;
                            }
                          }

                          if (!found) {
                            await service.createAttendenceList(
                              studentId: user.uid,
                              teacherId: currentTeacherUid,
                              subjectId: widget.subject.uid,
                              classId: widget.classe.uid,
                              status: value!,
                              classDate: formattedDate,
                              roleUser: 'teacher',
                            );
                          }
                        } catch (e) {
                          log("Erro ao salvar presença: $e");
                          // ignore: use_build_context_synchronously
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'Erro ao salvar presença. Tente novamente.')),
                          );
                          // Opcional: reverter o estado local se a operação no Firebase falhar
                        }
                      },
                      decoration: const InputDecoration(
                        isDense: true,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: appBarUserComponent(
        userFirebase: AuthUserService()
            .currentUser, // Assume que o currentUser já está carregado ou é tratado pelo appBar
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                    builder: (context) => const DashboardTeacherPage()),
                (Route<dynamic> route) => false);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
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
                      : ListView.builder(
                          // Removido height fixo
                          shrinkWrap:
                              true, // Importante para ListView aninhados
                          physics:
                              const NeverScrollableScrollPhysics(), // Desabilita o scroll do ListView interno
                          itemCount: listUser.length,
                          itemBuilder: (context, index) {
                            final user = listUser[index];

                            // Mapeia as notas do usuário atual para acesso rápido
                            Map<String, String> userNotesUidMap = {
                              for (var userNote in listUserNote
                                  .where((note) => note.userId == user.uid))
                                userNote.noteId: userNote.value
                            };

                            return Card.outlined(
                              margin: const EdgeInsets.symmetric(vertical: 8.0),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),
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
                                      Text("Matrícula: ${user.registration}"),
                                      Text("Email: ${user.email}"),
                                      Text("Celular: ${user.phone}"),
                                      const SizedBox(height: 15),
                                      const Text(
                                        "Notas de Provas e Trabalhos:",
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      const SizedBox(height: 10),
                                      SingleChildScrollView(
                                        // Para notas que ultrapassam a largura
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          children: [
                                            Wrap(
                                              spacing: 12.0,
                                              children: listNotes.map((note) {
                                                String userNoteValue =
                                                    userNotesUidMap[note.uid]
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
                                                "Média das Notas: ${_calculateAverage(userNotesUidMap)}"),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 15),
                                      ElevatedButton.icon(
                                        onPressed: () async {
                                          await showDialog(
                                            context: context,
                                            builder: (dialogContext) {
                                              return AlertDialog(
                                                title: Text(
                                                    "Gerenciar Presença de ${user.name}"),
                                                content: SizedBox(
                                                  width: double.maxFinite,
                                                  height: MediaQuery.of(
                                                              dialogContext)
                                                          .size
                                                          .height *
                                                      0.7,
                                                  child:
                                                      _buildAttendanceManagementList(
                                                          user, datasAulas),
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.pop(
                                                          dialogContext);
                                                    },
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                            backgroundColor:
                                                                Colors
                                                                    .blueAccent),
                                                    child: const Text(
                                                      "Fechar",
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                    ),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                          // Após fechar o modal, se houver alteração que precise ser refletida na tela principal,
                                          // você pode disparar um recarregamento das presenças.
                                          // setState(() { }); // Um setState vazio aqui forçaria a rebuild da página principal se necessário
                                        },
                                        icon: const Icon(
                                          Icons.calendar_today,
                                          color: Colors.white,
                                        ),
                                        label: const Text(
                                          "Gerenciar Presença",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.pinkAccent),
                                      ),
                                    ],
                                  ),
                                ),
                                leading: Container(
                                  height: 50,
                                  width: 50,
                                  decoration: BoxDecoration(
                                    color: colorPrimaty,
                                    borderRadius: BorderRadius.circular(10),
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
                                                const Text("Não permitido"),
                                                IconButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  icon: const Icon(Icons.close),
                                                )
                                              ],
                                            ),
                                            content: const Text(
                                                "Para adicionar nota ao Aluno é necessário criar as notas"),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          CreateNotesPage(
                                                        classFirebase:
                                                            widget.classe,
                                                        subject: widget.subject,
                                                      ),
                                                    ),
                                                  );
                                                },
                                                style: ElevatedButton.styleFrom(
                                                    elevation: 5,
                                                    backgroundColor:
                                                        Colors.blueAccent,
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 30)),
                                                child: const Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      'Ir Criar Notas',
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    SizedBox(width: 5),
                                                    Icon(
                                                      Icons
                                                          .arrow_forward_rounded,
                                                      color: Colors.white,
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                      return;
                                    }
                                    await addNotesCard(
                                      context: context,
                                      user: user,
                                      classe: widget.classe,
                                      subject: widget.subject,
                                      listNotes: listNotes,
                                      listUserNotes: listUserNote
                                          .where((element) =>
                                              element.userId == user.uid)
                                          .toList(),
                                      onSave: () async {
                                        // Recarrega as notas do usuário específico após o salvamento
                                        await _loadUserNotes(
                                            studentId: user.uid);
                                        // Se a UI principal precisar ser reconstruída para refletir a media das notas, etc.
                                        if (mounted) setState(() {});
                                      },
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.white,
                                  ),
                                  label: MediaQuery.of(context).size.width < 600
                                      ? const Text("")
                                      : const Text(
                                          "Adicionar Nota",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
            ],
          ),
        ),
      ),
      // bottomNavigationBar: const Footer(),
    );
  }
}
