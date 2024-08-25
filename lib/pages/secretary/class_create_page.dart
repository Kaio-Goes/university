import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:university/components/app_bar_secretary_component.dart';
import 'package:university/components/drawer_secretary_component.dart';
import 'package:university/components/footer.dart';
import 'package:university/components/text_fields.dart';
import 'package:university/components/validation/validation.dart';
import 'package:university/core/models/user_firebase.dart';
import 'package:university/services/auth_secretary_service.dart';
import 'package:university/services/users_service.dart';

class ClassCreatePage extends StatefulWidget {
  const ClassCreatePage({super.key});

  @override
  State<ClassCreatePage> createState() => _ClassCreatePageState();
}

class _ClassCreatePageState extends State<ClassCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final descriptionController = TextEditingController();
  String? selectedTypeClass;
  String? selectedSubject;
  List<UserFirebase> activeStudent = [];
  List<int>? confirmResults;
  final TextEditingController dateController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();

  Future<List<UserFirebase>> futureTag = fetchStudants();

  List<MultiSelectItem<UserFirebase>> buildStudents(
      List<UserFirebase> students) {
    return students
        .map(((e) => MultiSelectItem<UserFirebase>(e, e.name.toString())))
        .toList();
  }

  _clickButton() {
    bool formOk = _formKey.currentState!.validate();

    if (!formOk) {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarSecretaryComponent(name: AuthSecretaryService().currentUser?.name),
      drawer: const DrawerSecretaryComponent(),
      body: SingleChildScrollView(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            bool isSmallScreen = constraints.maxWidth < 800;
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
                                              selectedSubject: selectedSubject,
                                              onChangedSubject: (value) {
                                                selectedSubject = value;
                                              },
                                              dateController: dateController,
                                              endDateController:
                                                  endDateController,
                                              onTapDate: () async {
                                                FocusScope.of(context)
                                                    .requestFocus(FocusNode());
                                                final DateTime? pickedDate =
                                                    await showDatePicker(
                                                  context: context,
                                                  initialDate: DateTime.now(),
                                                  firstDate: DateTime(2000),
                                                  lastDate: DateTime(2101),
                                                );
                                                if (pickedDate != null) {
                                                  setState(() {
                                                    dateController.text =
                                                        "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                                                  });
                                                }
                                              },
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
                                              dateController: dateController,
                                              endDateController:
                                                  endDateController,
                                              onTapDate: () async {
                                                FocusScope.of(context)
                                                    .requestFocus(FocusNode());
                                                final DateTime? pickedDate =
                                                    await showDatePicker(
                                                  context: context,
                                                  initialDate: DateTime.now(),
                                                  firstDate: DateTime(2000),
                                                  lastDate: DateTime(2101),
                                                );
                                                if (pickedDate != null) {
                                                  setState(() {
                                                    endDateController.text =
                                                        "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                                                  });
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
                                              children: [
                                                buildFormCreateClassPartOne(
                                                  context: context,
                                                  isSmallScreen: isSmallScreen,
                                                  descriptionController:
                                                      descriptionController,
                                                  selectedSubject:
                                                      selectedSubject,
                                                  onChangedSubject: (value) {
                                                    selectedSubject = value;
                                                  },
                                                  dateController:
                                                      dateController,
                                                  endDateController:
                                                      endDateController,
                                                  onTapDate: () async {
                                                    FocusScope.of(context)
                                                        .requestFocus(
                                                            FocusNode());
                                                    final DateTime? pickedDate =
                                                        await showDatePicker(
                                                      context: context,
                                                      initialDate:
                                                          DateTime.now(),
                                                      firstDate: DateTime(2000),
                                                      lastDate: DateTime(2101),
                                                    );
                                                    if (pickedDate != null) {
                                                      setState(() {
                                                        dateController.text =
                                                            "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                                                      });
                                                    }
                                                  },
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
                                                  dateController:
                                                      dateController,
                                                  endDateController:
                                                      endDateController,
                                                  onTapDate: () async {
                                                    FocusScope.of(context)
                                                        .requestFocus(
                                                            FocusNode());
                                                    final DateTime? pickedDate =
                                                        await showDatePicker(
                                                      context: context,
                                                      initialDate:
                                                          DateTime.now(),
                                                      firstDate: DateTime(2000),
                                                      lastDate: DateTime(2101),
                                                    );
                                                    if (pickedDate != null) {
                                                      setState(() {
                                                        endDateController.text =
                                                            "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                                                      });
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
                                      future: fetchStudants(),
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
                                                confirmResults = List<int>.from(
                                                    results.map((e) => e.uid));
                                              });
                                            },
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
                                    child: const Text(
                                      'Adicionar',
                                      style: TextStyle(
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
  required String? selectedSubject,
  required void Function(String?)? onChangedSubject,
  required TextEditingController dateController,
  required TextEditingController endDateController,
  required void Function()? onTapDate,
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
      textFormField(
        controller: descriptionController,
        validator: (value) => validInputNome(value),
        hint: 'Digite o nome da turma',
        label: 'Nome da Turma',
        size: widthInput,
      ),
      const SizedBox(height: 25),
      textFormField(
          controller: dateController,
          validator: (value) => validDate(
              value,
              DateTime.parse(endDateController.text),
              DateTime.parse(dateController.text)),
          hint: 'Selecione o período da turma',
          label: 'Data de Início',
          size: widthInput,
          onTap: onTapDate),
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
    ],
  );
}

Widget buildFormCreateClassPartTwo({
  required BuildContext context,
  required bool isSmallScreen,
  required String? selectedTypeClass,
  required TextEditingController dateController,
  required TextEditingController endDateController,
  required void Function()? onTapDate,
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
      textFormField(
          controller: endDateController,
          validator: (value) => validDateBack(
              value,
              DateTime.parse(dateController.text),
              DateTime.parse(endDateController.text)),
          hint: 'Selecione o período final da turma',
          label: 'Data de Encerramento',
          size: widthInput,
          onTap: onTapDate),
      SizedBox(height: isSmallScreen ? 15 : 100),
    ],
  );
}
