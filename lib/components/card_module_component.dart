import 'package:flutter/material.dart';
import 'package:university/components/text_fields.dart';
import 'package:university/components/validation/validation.dart';
import 'package:university/core/models/subject_module.dart';
import 'package:university/core/models/user_firebase.dart';
import 'package:university/core/utilities/styles.constants.dart';
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
    } catch (e) {}
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
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("Criar uma Matéria"),
                                const SizedBox(width: 60),
                                IconButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    icon: const Icon(Icons.close))
                              ],
                            ),
                            content: const Text(
                                "Crie uma matéria para o módulo selecionado e adiocione o Professor responsável."),
                            actions: [
                              Form(
                                key: _formKey,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    textFormField(
                                      controller: titleController,
                                      validator: validInputNome,
                                      label: 'Título',
                                      hint: 'Digite o título da matéria',
                                      size: 600,
                                    ),
                                    const SizedBox(height: 25),
                                    Row(
                                      children: [
                                        textFormField(
                                          controller: hourController,
                                          validator: validInputNome,
                                          label: 'Hora',
                                          hint: 'Ex: 20hr',
                                          inputFormatters: [formatterHour],
                                          textInputType: TextInputType.phone,
                                          size: widget.isSmallScreen
                                              ? MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.32
                                              : 286,
                                        ),
                                        const SizedBox(width: 25),
                                        SizedBox(
                                          width: widget.isSmallScreen
                                              ? MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.32
                                              : 286,
                                          child: dropDownField(
                                            label: 'Módulo',
                                            select: _selectedModule,
                                            onChanged: (value) {
                                              setState(() {
                                                _selectedModule = value;
                                              });
                                            },
                                            hintText: widget.isSmallScreen
                                                ? 'Selecione o Mó...'
                                                : 'Selecione o Módulo',
                                            items: dropdownItemsModule,
                                            validator: (value) =>
                                                validatorDropdown(value),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 25),
                                    SizedBox(
                                      width: 600,
                                      child: dropDownField(
                                        label: 'Professor',
                                        select: _selectedTeacher,
                                        onChanged: (value) {
                                          setState(() {
                                            _selectedTeacher = value;
                                          });
                                        },
                                        hintText:
                                            'Selecione o professor responsável',
                                        items: enumTeachers,
                                        validator: (value) =>
                                            validatorDropdown(value),
                                      ),
                                    ),
                                    const SizedBox(height: 25),
                                    SizedBox(
                                      height: 40,
                                      width: 200,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          _clickButton(
                                            title: titleController.text,
                                            hour: hourController.text,
                                            module: _selectedModule ?? '',
                                            idUser: _selectedTeacher ?? '',
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.blue),
                                        child: const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Adicionar',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          );
                        },
                      );
                    },
                    icon: const Icon(Icons.add))
              ],
            ),
            const SizedBox(height: 5),
            Container(
              height: 1,
              width: 300,
              color: Colors.grey,
            ),
            const SizedBox(height: 25),
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
                            // Lógica para a seleção do item do menu
                            if (value == 'edit') {
                              // Adicione aqui a lógica para a opção 'Editar'
                              print('Editar clicado');
                            } else if (value == 'delete') {
                              // Adicione aqui a lógica para a opção 'Excluir'
                              print('Excluir clicado');
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
