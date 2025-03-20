import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:university/components/app_bar_secretary_component.dart';
import 'package:university/components/drawer_secretary_component.dart';
import 'package:university/components/footer.dart';
import 'package:university/components/text_fields.dart';
import 'package:university/components/validation/validation.dart';
import 'package:university/core/models/class_firebase.dart';
import 'package:university/core/models/user_firebase.dart';
import 'package:university/pages/secretary/dashboard/dashboard_secretary_page.dart';
import 'package:university/services/auth_secretary_service.dart';
import 'package:university/services/class_service.dart';
import 'package:university/services/users_service.dart';

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
  String? selectedTypeClass;
  String? selectedSubject;
  List<String> confirmResults = [];
  List<UserFirebase> selectedStudents = [];
  final TextEditingController dateController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();

  Future<List<UserFirebase>> futureTag = fetchStudants();

  List<MultiSelectItem<UserFirebase>> buildStudents(
      List<UserFirebase> students) {
    return students
        .map(((e) => MultiSelectItem<UserFirebase>(e, e.name.toString())))
        .toList();
  }

  @override
  void initState() {
    super.initState();
    futureStudants = fetchStudants();

    if (widget.classFirebase != null) {
      editRequest();
    }
  }

  editRequest() {
    descriptionController.text = widget.classFirebase!.name;
    dateController.text = widget.classFirebase!.startDate;
    endDateController.text = widget.classFirebase!.endDate;
    selectedTypeClass = widget.classFirebase!.typeClass;
    selectedSubject = widget.classFirebase!.subject;
    futureStudants!.then((students) {
      setState(() {
        selectedStudents = students
            .where((student) =>
                widget.classFirebase!.students.contains(student.uid))
            .toList();
        confirmResults = selectedStudents.map((s) => s.uid).toList();
      });
    });
  }

  _clickButton() {
    bool formOk = _formKey.currentState!.validate();

    if (!formOk) {
      return;
    }

    try {
      ClassService()
          .createClass(
              name: descriptionController.text,
              subject: selectedSubject,
              typeClass: selectedTypeClass,
              startDate: dateController.text,
              endDate: endDateController.text,
              students: confirmResults)
          .then((_) {
        showDialog(
          // ignore: use_build_context_synchronously
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Sucesso"),
              content: const Text("Turma criada com sucesso!"),
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
      throw Exception("Erro in create class $e");
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
      appBar: appBarSecretaryComponent(
          name: AuthSecretaryService().currentUser?.name),
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
                          const Text(
                            'Criar uma nova Turma',
                            textAlign: TextAlign.center,
                            style: TextStyle(
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
                                              selectedSubject: selectedSubject,
                                              onChangedSubject: (value) {
                                                selectedSubject = value;
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
                                                  selectedSubject:
                                                      selectedSubject,
                                                  onChangedSubject: (value) {
                                                    selectedSubject = value;
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
  required String? selectedSubject,
  required void Function(String?)? onChangedSubject,
  required void Function(String?)? onChangedTypeClass,
}) {
  var widthInput = isSmallScreen
      ? MediaQuery.of(context).size.width * 1
      : MediaQuery.of(context).size.width * 0.35;

  final List<DropdownMenuItem<String>> dropdownItemsModule = [
    const DropdownMenuItem(value: '1', child: Text('Módulo 1')),
    const DropdownMenuItem(value: '2', child: Text('Módulo 2')),
    const DropdownMenuItem(value: '3', child: Text('Módulo 3')),
  ];
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
        child: dropDownField(
          label: 'Módulo',
          select: selectedSubject,
          onChanged: onChangedSubject,
          hintText: 'Selecione o módulo para turma',
          items: dropdownItemsModule,
          validator: (value) => validatorDropdown(value),
        ),
      ),
      SizedBox(height: isSmallScreen ? 15 : 0),
    ],
  );
}
