import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:university/components/app_bar_user_component.dart';
import 'package:university/components/drawer_secretary_component.dart';
import 'package:university/components/footer.dart';
import 'package:university/components/text_fields.dart';
import 'package:university/components/validation/validation.dart';
import 'package:university/core/models/class_firebase.dart';
import 'package:university/core/models/subject_module.dart';
import 'package:university/core/models/user_firebase.dart';
import 'package:university/core/utilities/alerts.dart';
import 'package:university/core/services/class_service.dart';
import 'package:university/core/services/auth_user_service.dart';
import 'package:university/core/services/subject_service.dart';

class ClassCreatePage extends StatefulWidget {
  final ClassFirebase? classFirebase;
  const ClassCreatePage({super.key, this.classFirebase});

  @override
  State<ClassCreatePage> createState() => _ClassCreatePageState();
}

class _ClassCreatePageState extends State<ClassCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final descriptionController = TextEditingController();
  Future<List<UserFirebase>>? futureStudants;
  List<UserFirebase> teachers = [];
  Future<List<SubjectModule>>? futureSubject;
  String? selectedTypeClass;
  List<String> confirmResults = [];
  List<String> confirmResultsSubject = [];
  List<UserFirebase> selectedStudents = [];
  List<SubjectModule> selectedSubjects = [];
  final TextEditingController dateController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();

  List<MultiSelectItem<UserFirebase>> buildStudents(
      List<UserFirebase> students) {
    return students
        .map(((e) => MultiSelectItem<UserFirebase>(e, e.name.toString())))
        .toList();
  }

  List<MultiSelectItem<SubjectModule>> buildSubject(
      List<SubjectModule> subject) {
    subject.sort((a, b) => a.module.compareTo(b.module));

    return subject.map((e) {
      // Encontrar o professor correspondente
      var nameTeacher = teachers
          .where((teacher) => teacher.uid == e.userId) // Aqui usa o `e.userId`
          .map((teacher) => teacher.name)
          .join(", ");
      var surnameTeacher = teachers
          .where((teacher) =>
              teacher.uid == e.userId) // Aqui também usa o `e.userId`
          .map((teacher) => teacher.surname)
          .join(", ");

      // Concatenar o nome e sobrenome
      var fullTeacherName = '$nameTeacher $surnameTeacher';

      return MultiSelectItem<SubjectModule>(
        e,
        '${e.title.toUpperCase()}\n'
        'Módulo: ${e.module}\n'
        'Professor(a): $fullTeacherName\n'
        'Dias de aula: ${e.daysWeek.replaceAll('[', '').replaceAll(']', '')}\n'
        'Horário: ${e.startHour} a ${e.endHour}',
      );
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    futureStudants = AuthUserService().fetchStudants();
    futureSubject = SubjectService().getAllSubjectModule();
    _loadTeachers();

    if (widget.classFirebase != null) {
      editRequest();
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
        teachers = activeTeachers;
      });
    } catch (e) {
      Exception('Erro loading users$e');
    }
  }

  editRequest() {
    descriptionController.text = widget.classFirebase!.name;
    dateController.text = widget.classFirebase!.startDate;
    endDateController.text = widget.classFirebase!.endDate;
    selectedTypeClass = widget.classFirebase!.typeClass;
    futureStudants!.then((students) {
      setState(() {
        selectedStudents = students
            .where((student) =>
                widget.classFirebase!.students.contains(student.uid))
            .toList();
        confirmResults = selectedStudents.map((s) => s.uid).toList();
      });
    });
    futureSubject!.then((subjects) {
      setState(() {
        selectedSubjects = subjects
            .where((subject) =>
                widget.classFirebase!.subject.contains(subject.uid))
            .toList();
        confirmResultsSubject = selectedSubjects.map((s) => s.uid).toList();
      });
    });
  }

  _clickButton() {
    bool formOk = _formKey.currentState!.validate();

    if (!formOk) {
      return;
    }

    if (widget.classFirebase != null) {
      ClassService()
          .updateClassFirebase(
        uid: widget.classFirebase!.uid,
        name: descriptionController.text,
        subject: confirmResultsSubject,
        typeClass: selectedTypeClass!,
        startDate: dateController.text,
        endDate: endDateController.text,
        students: confirmResults,
      )
          .then((_) {
        // ignore: use_build_context_synchronously
        showSuccessDialog(context);
      });
    } else {
      try {
        ClassService()
            .createClass(
                name: descriptionController.text,
                subject: confirmResultsSubject,
                typeClass: selectedTypeClass,
                startDate: dateController.text,
                endDate: endDateController.text,
                students: confirmResults)
            .then((_) {
          // ignore: use_build_context_synchronously
          showSuccessDialog(context);
        });
      } catch (e) {
        throw Exception("Erro in create class $e");
      }
    }
  }

  _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      setState(() {
        controller.text =
            "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarUserComponent(userFirebase: AuthUserService().currentUser),
      drawer: const DrawerSecretaryComponent(),
      body: SingleChildScrollView(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            bool isSmallScreen = constraints.maxWidth < 800;
            var widthInput = isSmallScreen
                ? MediaQuery.of(context).size.width * 1
                : MediaQuery.of(context).size.width * 0.35;
            return Column(
              children: [
                const SizedBox(height: 25),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.90,
                  child: Card(
                    elevation: 3,
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.classFirebase != null
                                ? "Editar a Turma"
                                : 'Criar uma nova Turma',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Assim que criado é necessário adicionar os alunos na Turma.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 13),
                          ),
                          const SizedBox(height: 20),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: isSmallScreen ? 15 : 40),
                            child: Column(
                              children: [
                                isSmallScreen
                                    ? Form(
                                        key: _formKey,
                                        child: Wrap(
                                          spacing: 20,
                                          runSpacing: 20,
                                          children: [
                                            buildFormCreateClassPartOne(
                                              context: context,
                                              isSmallScreen: isSmallScreen,
                                              descriptionController:
                                                  descriptionController,
                                              dateInput: textFormField(
                                                controller: dateController,
                                                validator: (value) => validDate(
                                                    value,
                                                    dateController.text,
                                                    endDateController.text),
                                                inputFormatters: [
                                                  MaskTextInputFormatter(
                                                    mask: '##/##/####',
                                                    filter: {
                                                      "#": RegExp(r'^[0-9]*$')
                                                    },
                                                    type: MaskAutoCompletionType
                                                        .lazy,
                                                  )
                                                ],
                                                hint:
                                                    'Selecione o período da turma',
                                                label: 'Data de Início',
                                                size: widthInput,
                                                onTap: () async {
                                                  FocusScope.of(context)
                                                      .unfocus();
                                                  await _selectDate(
                                                      context, dateController);
                                                },
                                              ),
                                              endDateInput: textFormField(
                                                controller: endDateController,
                                                validator: (value) =>
                                                    validDateBack(
                                                        value,
                                                        dateController.text,
                                                        endDateController.text),
                                                inputFormatters: [
                                                  MaskTextInputFormatter(
                                                    mask: '##/##/####',
                                                    filter: {
                                                      "#": RegExp(r'^[0-9]*$')
                                                    },
                                                    type: MaskAutoCompletionType
                                                        .lazy,
                                                  )
                                                ],
                                                hint:
                                                    'Selecione o período final da turma',
                                                label: 'Data de Encerramento',
                                                size: widthInput,
                                                onTap: () async {
                                                  FocusScope.of(context)
                                                      .unfocus();
                                                  await _selectDate(context,
                                                      endDateController);
                                                },
                                              ),
                                            ),
                                            buildFormCreateClassPartTwo(
                                              context: context,
                                              isSmallScreen: isSmallScreen,
                                              selectedTypeClass:
                                                  selectedTypeClass,
                                              onChangedTypeClass: (value) {
                                                setState(() {
                                                  selectedTypeClass = value;
                                                });
                                              },
                                              future: futureSubject,
                                              builder: (context, snapshot) {
                                                if (snapshot.hasData) {
                                                  final subject =
                                                      snapshot.data!;
                                                  return MultiSelectDialogField<
                                                      SubjectModule>(
                                                    items:
                                                        buildSubject(subject),
                                                    title: const Text(
                                                        "Matérias cadastradas"),
                                                    selectedColor:
                                                        const Color.fromARGB(
                                                            204, 88, 192, 206),
                                                    decoration: BoxDecoration(
                                                      color:
                                                          const Color.fromARGB(
                                                              28, 230, 81, 0),
                                                      borderRadius:
                                                          const BorderRadius
                                                              .all(
                                                              Radius.circular(
                                                                  10)),
                                                      border: Border.all(
                                                        color: const Color
                                                            .fromARGB(
                                                            204, 42, 97, 107),
                                                        width: 2,
                                                      ),
                                                    ),
                                                    buttonIcon: const Icon(
                                                      Icons.airplane_ticket,
                                                      color: Color.fromRGBO(
                                                          124, 203, 223, 0.8),
                                                    ),
                                                    buttonText: const Text(
                                                      "Matérias selecionados",
                                                      style: TextStyle(
                                                        color: Color.fromARGB(
                                                            204, 42, 97, 107),
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                    onConfirm: (results) {
                                                      setState(() {
                                                        confirmResultsSubject =
                                                            results
                                                                .map((subject) =>
                                                                    subject.uid)
                                                                .toList();
                                                        selectedSubjects =
                                                            results;
                                                      });
                                                    },
                                                    initialValue:
                                                        selectedSubjects,
                                                    searchable: true,
                                                    searchHint:
                                                        'Pesquise Matérias',
                                                  );
                                                } else {
                                                  return const Text(
                                                      'Não possui Matérias.');
                                                }
                                              },
                                            )
                                          ],
                                        ),
                                      )
                                    : Form(
                                        key: _formKey,
                                        child: Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                buildFormCreateClassPartOne(
                                                  context: context,
                                                  isSmallScreen: isSmallScreen,
                                                  descriptionController:
                                                      descriptionController,
                                                  dateInput: textFormField(
                                                    controller: dateController,
                                                    validator: (value) =>
                                                        validDate(
                                                            value,
                                                            dateController.text,
                                                            endDateController
                                                                .text),
                                                    inputFormatters: [
                                                      MaskTextInputFormatter(
                                                        mask: '##/##/####',
                                                        filter: {
                                                          "#": RegExp(
                                                              r'^[0-9]*$')
                                                        },
                                                        type:
                                                            MaskAutoCompletionType
                                                                .lazy,
                                                      )
                                                    ],
                                                    hint:
                                                        'Selecione o período da turma',
                                                    label: 'Data de Início',
                                                    size: widthInput,
                                                    onTap: () async {
                                                      FocusScope.of(context)
                                                          .unfocus();
                                                      await _selectDate(context,
                                                          dateController);
                                                    },
                                                  ),
                                                  endDateInput: textFormField(
                                                    controller:
                                                        endDateController,
                                                    validator: (value) =>
                                                        validDateBack(
                                                            value,
                                                            dateController.text,
                                                            endDateController
                                                                .text),
                                                    inputFormatters: [
                                                      MaskTextInputFormatter(
                                                        mask: '##/##/####',
                                                        filter: {
                                                          "#": RegExp(
                                                              r'^[0-9]*$')
                                                        },
                                                        type:
                                                            MaskAutoCompletionType
                                                                .lazy,
                                                      )
                                                    ],
                                                    hint:
                                                        'Selecione o período final da turma',
                                                    label:
                                                        'Data de Encerramento',
                                                    size: widthInput,
                                                    onTap: () async {
                                                      FocusScope.of(context)
                                                          .unfocus();
                                                      await _selectDate(context,
                                                          endDateController);
                                                    },
                                                  ),
                                                ),
                                                buildFormCreateClassPartTwo(
                                                  context: context,
                                                  isSmallScreen: isSmallScreen,
                                                  selectedTypeClass:
                                                      selectedTypeClass,
                                                  onChangedTypeClass: (value) {
                                                    setState(() {
                                                      selectedTypeClass = value;
                                                    });
                                                  },
                                                  future: futureSubject,
                                                  builder: (context, snapshot) {
                                                    if (snapshot.hasData) {
                                                      final subject =
                                                          snapshot.data!;
                                                      return MultiSelectDialogField<
                                                          SubjectModule>(
                                                        items: buildSubject(
                                                            subject),
                                                        title: const Text(
                                                            "Matérias cadastradas"),
                                                        selectedColor:
                                                            const Color
                                                                .fromARGB(204,
                                                                88, 192, 206),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: const Color
                                                              .fromARGB(
                                                              28, 230, 81, 0),
                                                          borderRadius:
                                                              const BorderRadius
                                                                  .all(Radius
                                                                      .circular(
                                                                          10)),
                                                          border: Border.all(
                                                            color: const Color
                                                                .fromARGB(204,
                                                                42, 97, 107),
                                                            width: 2,
                                                          ),
                                                        ),
                                                        buttonIcon: const Icon(
                                                          Icons.airplane_ticket,
                                                          color: Color.fromRGBO(
                                                              124,
                                                              203,
                                                              223,
                                                              0.8),
                                                        ),
                                                        buttonText: const Text(
                                                          "Matérias selecionados",
                                                          style: TextStyle(
                                                            color:
                                                                Color.fromARGB(
                                                                    204,
                                                                    42,
                                                                    97,
                                                                    107),
                                                            fontSize: 16,
                                                          ),
                                                        ),
                                                        onConfirm: (results) {
                                                          setState(() {
                                                            confirmResultsSubject =
                                                                results
                                                                    .map((subject) =>
                                                                        subject
                                                                            .uid)
                                                                    .toList();
                                                            selectedSubjects =
                                                                results;
                                                          });
                                                        },
                                                        initialValue:
                                                            selectedSubjects,
                                                        searchable: true,
                                                        searchHint:
                                                            'Pesquise Matérias',
                                                      );
                                                    } else {
                                                      return const Text(
                                                          'Não possui Matérias.');
                                                    }
                                                  },
                                                )
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                const SizedBox(height: 25),
                                SizedBox(
                                  width: 600,
                                  child: Center(
                                    child: FutureBuilder<List<UserFirebase>>(
                                      future: futureStudants,
                                      builder: (context, snapshot) {
                                        if (snapshot.hasData) {
                                          final student = snapshot.data!;
                                          return MultiSelectDialogField<
                                              UserFirebase>(
                                            items: buildStudents(student),
                                            title: const Text('Alunos Ativos'),
                                            selectedColor: const Color.fromARGB(
                                                204, 88, 192, 206),
                                            decoration: BoxDecoration(
                                              color: const Color.fromARGB(
                                                  28, 230, 81, 0),
                                              borderRadius:
                                                  const BorderRadius.all(
                                                      Radius.circular(10)),
                                              border: Border.all(
                                                color: const Color.fromARGB(
                                                    204, 42, 97, 107),
                                                width: 2,
                                              ),
                                            ),
                                            buttonIcon: const Icon(
                                              Icons.airplane_ticket,
                                              color: Color.fromRGBO(
                                                  124, 203, 223, 0.8),
                                            ),
                                            buttonText: const Text(
                                              "Alunos selecionados",
                                              style: TextStyle(
                                                color: Color.fromARGB(
                                                    204, 42, 97, 107),
                                                fontSize: 16,
                                              ),
                                            ),
                                            onConfirm: (results) {
                                              setState(() {
                                                confirmResults = results
                                                    .map((student) =>
                                                        student.uid)
                                                    .toList();
                                                selectedStudents = results;
                                              });
                                            },
                                            initialValue:
                                                selectedStudents, // Certifique-se de que os alunos selecionados são mantidos
                                            searchable: true,
                                            searchHint: 'Pesquise alunos',
                                          );
                                        } else {
                                          return const Text(
                                              'Não possui Alunos.');
                                        }
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                SizedBox(
                                  height: 40,
                                  width: 200,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      _clickButton();
                                    },
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue),
                                    child: Text(
                                      widget.classFirebase != null
                                          ? 'Salvar'
                                          : 'Adicionar',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
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

Widget buildFormCreateClassPartOne({
  required BuildContext context,
  required bool isSmallScreen,
  required TextEditingController descriptionController,
  required Widget dateInput,
  required Widget endDateInput,
}) {
  var widthInput = isSmallScreen
      ? MediaQuery.of(context).size.width * 1
      : MediaQuery.of(context).size.width * 0.35;

  return Column(
    children: [
      textFormField(
        controller: descriptionController,
        validator: (value) => validInputNome(value),
        hint: 'Digite o nome da turma',
        label: 'Nome da Turma',
        size: widthInput,
      ),
      const SizedBox(height: 25),
      dateInput,
      const SizedBox(height: 25),
      endDateInput,
    ],
  );
}

Widget buildFormCreateClassPartTwo({
  required BuildContext context,
  required bool isSmallScreen,
  required String? selectedTypeClass,
  required Future<List<SubjectModule>>? future,
  required Widget Function(BuildContext, AsyncSnapshot) builder,
  required void Function(String?)? onChangedTypeClass,
}) {
  var widthInput = isSmallScreen
      ? MediaQuery.of(context).size.width * 1
      : MediaQuery.of(context).size.width * 0.35;

  return Column(
    children: [
      SizedBox(
        width: widthInput,
        child: dropDownField(
          label: 'Tipo de Turma',
          select: selectedTypeClass,
          onChanged: onChangedTypeClass,
          hintText: 'Selecione o tipo da turma',
          items: <String>['Presencial', 'Online'].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          validator: (value) => validatorDropdown(value),
        ),
      ),
      const SizedBox(height: 25),
      SizedBox(
        width: widthInput,
        child: FutureBuilder<List<SubjectModule>>(
            future: future, builder: builder),
      ),
      SizedBox(height: isSmallScreen ? 15 : 0),
    ],
  );
}
