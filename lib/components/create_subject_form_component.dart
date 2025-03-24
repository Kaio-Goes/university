import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:university/components/text_fields.dart';
import 'package:university/components/validation/validation.dart';
import 'package:university/core/utilities/styles.constants.dart';

createSubjectFormComponent({
  required BuildContext context,
  required GlobalKey<FormState> formKey,
  required String title,
  required String subTitle,
  required String titleButton,
  required bool isSmallScreen,
  required TextEditingController titleController,
  required TextEditingController hourController,
  required String? selectedModule,
  required void Function(String?)? onChangedSelectedModule,
  required List<DropdownMenuItem<String>>? dropdownItemsModule,
  required List<String> selectedDays,
  required void Function(List<String>?) onChangedSelectedDays,
  required List<String> daysOfWeek,
  required TextEditingController startTimeHour,
  required TextEditingController endTimeHour,
  required String? selectedTeacher,
  required void Function(String?)? onChangedSelectedTeacher,
  required List<DropdownMenuItem<String>>? enumTeachers,
  required void Function()? onPressedClickButton,
}) {
  return showDialog(
    context: context,
    builder: (context) {
      return SingleChildScrollView(
        child: AlertDialog(
          titlePadding: const EdgeInsets.all(20),
          contentPadding: EdgeInsets.all(isSmallScreen ? 10 : 20),
          actionsPadding: EdgeInsets.all(isSmallScreen ? 10 : 20),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title),
              IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.close),
              )
            ],
          ),
          content: Text(subTitle),
          actions: [
            Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  textFormField(
                    controller: titleController,
                    validator: (value) => validInputNome(value),
                    label: 'Título',
                    hint: 'Digite o título da matéria',
                    size: 600,
                  ),
                  const SizedBox(height: 25),
                  Row(
                    children: [
                      textFormField(
                        controller: hourController,
                        validator: (value) => validInputNome(value),
                        label: 'Hora Totais',
                        hint: 'Ex: 20hr',
                        inputFormatters: [formatterHour],
                        textInputType: TextInputType.phone,
                        size: isSmallScreen
                            ? MediaQuery.of(context).size.width * 0.32
                            : 286,
                      ),
                      const SizedBox(width: 25),
                      SizedBox(
                        width: isSmallScreen
                            ? MediaQuery.of(context).size.width * 0.32
                            : 286,
                        child: dropDownField(
                          label: 'Módulo',
                          select: selectedModule,
                          onChanged: onChangedSelectedModule,
                          hintText: isSmallScreen
                              ? 'Selecione...'
                              : 'Selecione o Módulo',
                          items: dropdownItemsModule,
                          validator: (value) => validatorDropdown(value),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  SizedBox(
                    width: 600,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Dias da Semana',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 5),
                        MultiSelectDialogField(
                          items: daysOfWeek
                              .map((day) => MultiSelectItem<String>(day, day))
                              .toList(),
                          title: const Text("Dias da semana com aula"),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(28, 230, 81, 0),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10)),
                            border: Border.all(
                              color: Colors.grey,
                              width: 1,
                            ),
                          ),
                          cancelText: const Text('Cancelar'),
                          buttonText: const Text(
                            'Selecione os dias da semana',
                            style: TextStyle(color: Colors.black54),
                          ),
                          selectedItemsTextStyle:
                              const TextStyle(color: Colors.blue),
                          onConfirm: onChangedSelectedDays,
                          initialValue: selectedDays,
                          validator: (values) {
                            if (values == null || values.isEmpty) {
                              return "Selecione ao menos um dia da semana";
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),
                  Row(
                    children: [
                      textFormField(
                        controller: startTimeHour,
                        validator: (value) {
                          return validateTime(
                            startTime: startTimeHour.text,
                            endTime: endTimeHour.text,
                          );
                        },
                        inputFormatters: [formattehourMask],
                        hint: 'Digite inicial da aula',
                        label: 'Hora de Entrada',
                        size: isSmallScreen
                            ? MediaQuery.of(context).size.width * 0.32
                            : 286,
                      ),
                      const SizedBox(width: 25),
                      textFormField(
                        controller: endTimeHour,
                        validator: (value) {
                          return validateTime(
                            startTime: startTimeHour.text,
                            endTime: endTimeHour.text,
                          );
                        },
                        inputFormatters: [formattehourMask],
                        hint: 'Digite final da aula',
                        label: 'Hora de Saída',
                        size: isSmallScreen
                            ? MediaQuery.of(context).size.width * 0.32
                            : 286,
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  SizedBox(
                    width: 600,
                    child: dropDownField(
                      label: 'Professor',
                      select: selectedTeacher,
                      onChanged: onChangedSelectedTeacher,
                      hintText: 'Selecione o professor responsável',
                      items: enumTeachers,
                      validator: (value) => validatorDropdown(value),
                    ),
                  ),
                  const SizedBox(height: 25),
                  SizedBox(
                    height: 40,
                    width: 200,
                    child: ElevatedButton(
                      onPressed: onPressedClickButton,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            titleButton,
                            style: const TextStyle(
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
        ),
      );
    },
  );
}
