import 'package:flutter/material.dart';
import 'package:university/components/create_subject_form_component.dart';
import 'package:university/core/models/subject_module.dart';
import 'package:university/core/models/user_firebase.dart';
import 'package:university/pages/secretary/dashboard/dashboard_secretary_page.dart';
import 'package:university/services/subject_service.dart';

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
  String? _selectedModule;
  String? _selectedTeacher;

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
      required String idUser}) {
    bool formOk = _formKey.currentState!.validate();

    if (!formOk) {
      return;
    }

    try {
      SubjectService()
          .createSubject(
              title: title, hour: hour, module: module, idUser: idUser)
          .then((_) async {
        showDialog(
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
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color.fromARGB(255, 208, 223, 224),
      elevation: 8,
      child: SizedBox(
        height: 300,
        width: 400,
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
                    enumTeachers = widget.userTeacher
                        .map((e) => DropdownMenuItem<String>(
                            value: e.uid.toString(),
                            child: Text(
                                'Professor(a) ${e.name.toString()} ${e.surname.toString()}')))
                        .toList();
                    createSubjectFormComponent(
                      context: context,
                      formKey: _formKey,
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
                      onPressedClickButton: () {
                        _clickButton(
                          title: titleController.text,
                          hour: hourController.text,
                          module: _selectedModule ?? '',
                          idUser: _selectedTeacher ?? '',
                        );
                      },
                    );
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
                          height: 60,
                          width: 50,
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
                        subtitle:
                            Text("Professor: $nameTeacher $surnameTeacher"),
                        trailing: PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert),
                          onSelected: (String value) {
                            if (value == 'edit') {
                              var subject = widget.subjectModule?[index];
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
                                  onPressedClickButton: () {
                                    _clickButton(
                                      title: titleController.text,
                                      hour: hourController.text,
                                      module: _selectedModule ?? '',
                                      idUser: _selectedTeacher ?? '',
                                    );
                                  },
                                );
                              }
                            } else if (value == 'delete') {
                              // Adicione aqui a lógica para a opção 'Excluir'7
                              showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text("Tem certeza?"),
                                  content:
                                      const Text("Deseja excluir a matéria"),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(ctx).pop(false);
                                      },
                                      child: const Text("Não"),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        SubjectService().deleteSubject(
                                            uid: widget
                                                .subjectModule![index].uid);
                                        Navigator.of(context).pushAndRemoveUntil(
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const DashboardSecretaryPage()),
                                            (Route<dynamic> route) => false);
                                      },
                                      child: const Text("Sim"),
                                    ),
                                  ],
                                ),
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
                                    Icon(
                                      Icons.delete,
                                      size: 16,
                                      color: Colors.red,
                                    )
                                  ],
                                ),
                              ),
                            ];
                          },
                        ),
                        contentPadding: EdgeInsets.zero,
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
