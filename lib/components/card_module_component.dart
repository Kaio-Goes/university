import 'package:flutter/material.dart';
import 'package:university/components/create_subject_form_component.dart';
import 'package:university/core/models/subject_module.dart';
import 'package:university/core/models/user_firebase.dart';
import 'package:university/core/utilities/alerts.dart';
import 'package:university/pages/secretary/dashboard/dashboard_secretary_page.dart';
import 'package:university/core/services/subject_service.dart';

class CardModuleComponent extends StatefulWidget {
  final bool isSmallScreen;
  final String title;
  final List<UserFirebase> userTeacher;
  final List<SubjectModule>? subjectModule;
  const CardModuleComponent({
    super.key,
    required this.isSmallScreen,
    required this.title,
    required this.userTeacher,
    this.subjectModule,
  });

  @override
  State<CardModuleComponent> createState() => _CardModuleComponentState();
}

class _CardModuleComponentState extends State<CardModuleComponent> {
  final _formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final hourController = TextEditingController();
  final startHourController = TextEditingController();
  final endHourController = TextEditingController();

  String? _selectedModule;
  String? _selectedTeacher;
  List<String> _selectedDays = [];

  final List<String> _daysOfWeek = [
    'Segunda-feira',
    'Terça-feira',
    'Quarta-feira',
    'Quinta-feira',
    'Sexta-feira',
    'Sábado',
    'Domingo',
  ];

  final List<DropdownMenuItem<String>> dropdownItemsModule = [
    const DropdownMenuItem(value: '1', child: Text('Módulo 1')),
    const DropdownMenuItem(value: '2', child: Text('Módulo 2')),
    const DropdownMenuItem(value: '3', child: Text('Módulo 3')),
  ];

  List<DropdownMenuItem<String>>? enumTeachers = [];

  _clickButton(
      {required String title,
      required String hour,
      required String module,
      required String daysWeeks,
      required String startHour,
      required String endHour,
      required String idUser}) {
    bool formOk = _formKey.currentState!.validate();

    if (!formOk) {
      return;
    }
    try {
      SubjectService()
          .createSubject(
        title: title,
        hour: hour,
        daysWeek: daysWeeks,
        startHour: startHour,
        endHour: endHour,
        module: module,
        idUser: idUser,
      )
          .then((_) async {
        showDialog(
          // ignore: use_build_context_synchronously
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Sucesso"),
              content: const Text("Matéria criada com sucesso!"),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                            builder: (context) =>
                                const DashboardSecretaryPage()),
                        (Route<dynamic> route) => false);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  child: const Text(
                    "Ir para o início",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      });
    } catch (e) {
      throw Exception("$e");
    }
  }

  void _populateForm(SubjectModule subject) {
    titleController.text = subject.title;
    hourController.text = subject.hour;
    _selectedModule = subject.module;
    _selectedTeacher = subject.userId;
    _selectedDays = subject.daysWeek
        .replaceAll("[", "")
        .replaceAll("]", "")
        .split(", ")
        .map((day) => day.trim())
        .toList();
    startHourController.text = subject.startHour;
    endHourController.text = subject.endHour;
  }

  void clearInput() {
    titleController.clear();
    hourController.clear();
    _selectedModule = null;
    _selectedTeacher = null;
    _selectedDays = [];
    startHourController.clear();
    endHourController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color.fromARGB(255, 208, 223, 224),
      elevation: 8,
      child: SizedBox(
        height: 300,
        width: 380,
        child: Column(
          children: [
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(width: 160),
                Text(
                  widget.title,
                  style: const TextStyle(
                      fontSize: 17, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 100),
                IconButton(
                  onPressed: () {
                    clearInput();
                    enumTeachers = widget.userTeacher
                        .map((e) => DropdownMenuItem<String>(
                            value: e.uid.toString(),
                            child: Text(
                                'Professor(a) ${e.name.toString()} ${e.surname.toString()}')))
                        .toList();
                    createSubjectFormComponent(
                        context: context,
                        formKey: _formKey,
                        title: "Criar uma Matéria",
                        subTitle:
                            "Crie uma matéria para o módulo selecionado e adicione o Professor responsável.",
                        isSmallScreen: widget.isSmallScreen,
                        titleController: titleController,
                        hourController: hourController,
                        selectedModule: _selectedModule,
                        onChangedSelectedModule: (value) {
                          setState(() {
                            _selectedModule = value;
                          });
                        },
                        dropdownItemsModule: dropdownItemsModule,
                        selectedTeacher: _selectedTeacher,
                        onChangedSelectedTeacher: (value) {
                          setState(() {
                            _selectedTeacher = value;
                          });
                        },
                        enumTeachers: enumTeachers,
                        titleButton: 'Adicionar',
                        onPressedClickButton: () {
                          _clickButton(
                            title: titleController.text,
                            hour: hourController.text,
                            daysWeeks: _selectedDays.toString(),
                            startHour: startHourController.text,
                            endHour: endHourController.text,
                            module: _selectedModule ?? '',
                            idUser: _selectedTeacher ?? '',
                          );
                        },
                        selectedDays: _selectedDays,
                        onChangedSelectedDays: (days) {
                          setState(() {
                            _selectedDays = days!;
                          });
                        },
                        daysOfWeek: _daysOfWeek,
                        startTimeHour: startHourController,
                        endTimeHour: endHourController);
                  },
                  icon: const Icon(Icons.add),
                )
              ],
            ),
            const SizedBox(height: 5),
            Container(
              height: 1,
              width: 300,
              color: Colors.grey,
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 210,
              child: ListView.builder(
                itemCount: widget.subjectModule?.length ?? 0,
                itemBuilder: (context, index) {
                  var nameTeacher = widget.userTeacher
                      .where((teacher) =>
                          teacher.uid == widget.subjectModule?[index].userId)
                      .map((teacher) => teacher.name)
                      .join(", ");

                  var surnameTeacher = widget.userTeacher
                      .where((teacher) =>
                          teacher.uid == widget.subjectModule?[index].userId)
                      .map((teacher) => teacher.surname)
                      .join(", ");
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Card(
                      child: ListTile(
                        leading: Container(
                          width: 60,
                          decoration: BoxDecoration(
                            color: widget.subjectModule?[index].module == "1"
                                ? Colors.pink.shade300
                                : widget.subjectModule?[index].module == "2"
                                    ? Colors.blue.shade300
                                    : Colors.red.shade300,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              "${widget.subjectModule?[index].hour ?? ''} hr",
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        title: Text(widget.subjectModule?[index].title ?? ''),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Professor: $nameTeacher $surnameTeacher"),
                            Text(
                                "Dias de aula: ${widget.subjectModule![index].daysWeek.toString().replaceAll('[', '').replaceAll(']', '')}"),
                            Text(
                                "Horário: ${widget.subjectModule![index].startHour} a ${widget.subjectModule![index].endHour}"),
                          ],
                        ),
                        trailing: PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert),
                          onSelected: (String value) {
                            if (value == 'edit') {
                              SubjectModule? subject =
                                  widget.subjectModule?[index];
                              if (subject != null) {
                                _populateForm(subject);

                                enumTeachers = widget.userTeacher
                                    .map((e) => DropdownMenuItem<String>(
                                        value: e.uid.toString(),
                                        child: Text(
                                            'Professor(a) ${e.name.toString()} ${e.surname.toString()}')))
                                    .toList();

                                createSubjectFormComponent(
                                    context: context,
                                    formKey: _formKey,
                                    title: "Editar Matéria",
                                    subTitle:
                                        "Edite matéria para o módulo selecionado e adicione o Professor responsável.",
                                    isSmallScreen: widget.isSmallScreen,
                                    titleController: titleController,
                                    hourController: hourController,
                                    selectedModule: _selectedModule,
                                    onChangedSelectedModule: (value) {
                                      setState(() {
                                        _selectedModule = value;
                                      });
                                    },
                                    dropdownItemsModule: dropdownItemsModule,
                                    selectedTeacher: _selectedTeacher,
                                    onChangedSelectedTeacher: (value) {
                                      setState(() {
                                        _selectedTeacher = value;
                                      });
                                    },
                                    enumTeachers: enumTeachers,
                                    titleButton: 'Editar',
                                    onPressedClickButton: () {
                                      try {
                                        SubjectService()
                                            .updateSubject(
                                          uid: subject.uid,
                                          title: titleController.text,
                                          hour: hourController.text,
                                          module: _selectedModule!,
                                          idUser: _selectedTeacher!,
                                          daysWeek: _selectedDays.toString(),
                                          startHour: startHourController.text,
                                          endHour: endHourController.text,
                                        )
                                            .then((_) {
                                          // ignore: use_build_context_synchronously
                                          showSuccessDialog(context);
                                        });
                                      } catch (e) {
                                        Exception(
                                            "Erro ao tentar atualizar o modulo == $e");
                                      }
                                    },
                                    selectedDays: _selectedDays,
                                    onChangedSelectedDays: (days) {
                                      setState(() {
                                        _selectedDays = days!;
                                      });
                                    },
                                    daysOfWeek: _daysOfWeek,
                                    startTimeHour: startHourController,
                                    endTimeHour: endHourController);
                              }
                            } else if (value == 'delete') {
                              showDeleteDialog(
                                context: context,
                                onPressed: () {
                                  SubjectService().deleteSubject(
                                      uid: widget.subjectModule![index].uid);
                                  Navigator.of(context).pushAndRemoveUntil(
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const DashboardSecretaryPage()),
                                      (Route<dynamic> route) => false);
                                },
                              );
                            }
                          },
                          itemBuilder: (BuildContext context) {
                            return [
                              const PopupMenuItem<String>(
                                value: 'edit',
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Editar'),
                                    Icon(Icons.edit, size: 16)
                                  ],
                                ),
                              ),
                              const PopupMenuItem<String>(
                                value: 'delete',
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Excluir'),
                                    Icon(Icons.delete, size: 16)
                                  ],
                                ),
                              ),
                            ];
                          },
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
    );
  }
}
