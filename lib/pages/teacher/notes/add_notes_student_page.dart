import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:university/components/add_notes_card.dart';
import 'package:university/components/app_bar_user_component.dart';
import 'package:university/components/footer.dart';
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

class _AddNotesStudentPageState extends State<AddNotesStudentPage> {
  List<UserFirebase> listUser = [];
  List<Note> listNotes = [];
  List<UserNote> listUserNote = [];
  bool isLoading = true;
  Map<String, Map<DateTime, String>> presencaMap = {};

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

      await _loadPresence();
    } catch (e) {
      setState(() => isLoading = false);
      Exception("Erro loading student in class $e");
    }
  }

  Future<void> _loadPresence() async {
    final service = AttendenceListService();

    for (final aluno in listUser) {
      final attendenceList = await service.getAttendenceList(
          studentId: aluno.uid,
          teacherId: AuthUserService().currentUser!.uid,
          classId: widget.classe.uid,
          subjectId: widget.subject.uid);

      for (final presence in attendenceList) {
        final date = presence.dateClass;
        final inputFormat = DateFormat('dd/MM/yyyy');
        final parsedDate = inputFormat.parse(date);

        if (date != null) {
          presencaMap[aluno.uid] ??= {};
          presencaMap[aluno.uid]![parsedDate] = presence.status;
        }
      }
    }

    setState(() {});
  }

  _loadNotes() async {
    try {
      var notes = await NoteService().getListNotesByClass(
        userId: AuthUserService().currentUser!.uid,
        classId: widget.classe.uid,
        subjectId: widget.subject.uid,
      );

      setState(() {
        listNotes = notes;
      });
    } catch (e) {
      Exception('Erro ao carregar notas do usuário $e');
    }
  }

  List<DateTime> getDatesByWeekdays() {
    // Mapeia o nome dos dias para números: segunda=1, ..., domingo=7
    Map<String, int> diasSemanaMap = {
      "Segunda-feira": DateTime.monday,
      "Terça-feira": DateTime.tuesday,
      "Quarta-feira": DateTime.wednesday,
      "Quinta-feira": DateTime.thursday,
      "Sexta-feira": DateTime.friday,
      "Sábado": DateTime.saturday,
      "Domingo": DateTime.sunday,
    };

    List<int> diasSelecionados = widget.subject.daysWeek
        .replaceAll('[', '')
        .replaceAll(']', '')
        .split(',') // <- aqui está o segredo
        .map((dia) => diasSemanaMap[dia.trim()])
        .whereType<int>()
        .toList();

    final DateFormat formatter = DateFormat('d/M/y');

    DateTime dataInicial = formatter.parse(widget.classe.startDate);
    DateTime dataFinal = formatter.parse(widget.classe.endDate);

    List<DateTime> datasFiltradas = [];

    for (DateTime data = dataInicial;
        !data.isAfter(dataFinal);
        data = data.add(const Duration(days: 1))) {
      if (diasSelecionados.contains(data.weekday)) {
        datasFiltradas.add(data);
      }
    }

    return datasFiltradas;
  }

  _loadUserNotes({String? studentId}) async {
    try {
      // uid do logado vai no teacherId :)
      var userNotes = await UserNoteService().getListUserNote(
          classId: widget.classe.uid,
          userId: studentId,
          teacherId: AuthUserService().currentUser!.uid,
          subjectId: widget.subject.uid);

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
      appBar: appBarUserComponent(
        userFirebase: AuthUserService().currentUser,
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
                                  height: listUser.length * 240,
                                  child: ListView.builder(
                                    itemCount: listUser.length,
                                    itemBuilder: (context, index) {
                                      final user = listUser[index];

                                      final datas = getDatesByWeekdays();

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
                                          subtitle: Scrollbar(
                                            child: SingleChildScrollView(
                                              scrollDirection: Axis.horizontal,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        "Matrícula: ${user.registration}",
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        maxLines: 1,
                                                        style: const TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600),
                                                      ),
                                                      Text(
                                                        "Email: ${user.email}",
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        maxLines: 1,
                                                        style: const TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600),
                                                      ),
                                                      Text(
                                                          "Celular: ${user.phone}"),
                                                      const SizedBox(
                                                          height: 30),
                                                      const Text(
                                                        "Notas de Provas e Trabalhos:",
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        maxLines: 1,
                                                        style: TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600),
                                                      ),
                                                      const SizedBox(
                                                          height: 10),
                                                      Row(
                                                        children: [
                                                          Wrap(
                                                            spacing: 12.0,
                                                            children: listNotes
                                                                .map((note) {
                                                              String
                                                                  userNoteValue =
                                                                  userNotesUidMap[note
                                                                              .uid]
                                                                          ?.replaceAll(
                                                                              '.',
                                                                              ',') ??
                                                                      "N/A";

                                                              return Chip(
                                                                label: Text(
                                                                    '${note.title}: $userNoteValue'),
                                                              );
                                                            }).toList(),
                                                          ),
                                                          const SizedBox(
                                                              width: 20),
                                                          Text(
                                                              "Soma das Notas: ${_calculateAverage(userNotesUidMap)}"),
                                                        ],
                                                      )
                                                    ],
                                                  ),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      const Text(
                                                        "Data das Aulas",
                                                        style: TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600),
                                                      ),
                                                      const Text(
                                                          "Adicionar presença ao Aluno"),
                                                      Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children:
                                                            datas.map((data) {
                                                          final formattedDate =
                                                              "${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}";

                                                          return Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        8.0),
                                                            child: Column(
                                                              children: [
                                                                Text(
                                                                  formattedDate,
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          14),
                                                                ),
                                                                SizedBox(
                                                                  width: 120,
                                                                  child:
                                                                      DropdownButtonFormField<
                                                                          String>(
                                                                    value: presencaMap[
                                                                            user.uid]
                                                                        ?[data],
                                                                    items: const [
                                                                      DropdownMenuItem(
                                                                        value:
                                                                            "Presente",
                                                                        child: Text(
                                                                            "Presente"),
                                                                      ),
                                                                      DropdownMenuItem(
                                                                        value:
                                                                            "Falta",
                                                                        child: Text(
                                                                            "Falta"),
                                                                      ),
                                                                      DropdownMenuItem(
                                                                        value:
                                                                            "Feriado",
                                                                        child: Text(
                                                                            "Feriado"),
                                                                      ),
                                                                    ],
                                                                    onChanged:
                                                                        (value) async {
                                                                      print(
                                                                          data);
                                                                      setState(
                                                                          () {
                                                                        presencaMap[user.uid] ??=
                                                                            {};
                                                                        presencaMap[user.uid]![data] =
                                                                            value!;
                                                                      });

                                                                      final service =
                                                                          AttendenceListService();
                                                                      final attendenceList =
                                                                          await service
                                                                              .getAttendenceList(
                                                                        studentId:
                                                                            user.uid,
                                                                        teacherId: AuthUserService()
                                                                            .currentUser!
                                                                            .uid,
                                                                        classId: widget
                                                                            .classe
                                                                            .uid,
                                                                        subjectId: widget
                                                                            .subject
                                                                            .uid,
                                                                      );

                                                                      // Verifica se já existe presença para essa data específica
                                                                      bool
                                                                          found =
                                                                          false;
                                                                      for (final presence
                                                                          in attendenceList) {
                                                                        if (presence.dateClass ==
                                                                            formattedDate) {
                                                                          // Já existe: atualiza
                                                                          await service
                                                                              .updateAttendenceList(
                                                                            uid:
                                                                                presence.uid,
                                                                            studentId:
                                                                                user.uid,
                                                                            teacherId:
                                                                                AuthUserService().currentUser!.uid,
                                                                            subjectId:
                                                                                widget.subject.uid,
                                                                            classId:
                                                                                widget.classe.uid,
                                                                            status:
                                                                                value!,
                                                                          );
                                                                          found =
                                                                              true;
                                                                          break;
                                                                        }
                                                                      }

                                                                      // Se não encontrou, cria nova presença
                                                                      if (!found) {
                                                                        await service
                                                                            .createAttendenceList(
                                                                          studentId:
                                                                              user.uid,
                                                                          teacherId: AuthUserService()
                                                                              .currentUser!
                                                                              .uid,
                                                                          subjectId: widget
                                                                              .subject
                                                                              .uid,
                                                                          classId: widget
                                                                              .classe
                                                                              .uid,
                                                                          status:
                                                                              value!,
                                                                          classDate:
                                                                              formattedDate,
                                                                          roleUser:
                                                                              'teacher',
                                                                        );
                                                                      }
                                                                    },
                                                                    decoration:
                                                                        const InputDecoration(
                                                                      isDense:
                                                                          true,
                                                                      contentPadding: EdgeInsets.symmetric(
                                                                          horizontal:
                                                                              8,
                                                                          vertical:
                                                                              10),
                                                                      border:
                                                                          OutlineInputBorder(),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          );
                                                        }).toList(),
                                                      )
                                                    ],
                                                  ),
                                                ],
                                              ),
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
                                                var userNotes =
                                                    await UserNoteService()
                                                        .getListUserNote(
                                                  classId: widget.classe.uid,
                                                  userId: user.uid,
                                                  teacherId: AuthUserService()
                                                      .currentUser!
                                                      .uid,
                                                  subjectId: widget.subject.uid,
                                                );

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
                                                  subject: widget.subject,
                                                  listNotes: listNotes,
                                                  listUserNotes: userNotes,
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
