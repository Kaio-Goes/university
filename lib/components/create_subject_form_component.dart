import 'package:flutter/material.dart';
import 'package:university/components/text_fields.dart';
import 'package:university/components/validation/validation.dart';
import 'package:university/core/utilities/styles.constants.dart';

createSubjectFormComponent({
  required BuildContext context,
  required GlobalKey<FormState> formKey,
  required bool isSmallScreen,
  required TextEditingController titleController,
  required TextEditingController hourController,
  required String? selectedModule,
  required void Function(String?)? onChangedSelectedModule,
  required List<DropdownMenuItem<String>>? dropdownItemsModule,
  required String? selectedTeacher,
  required void Function(String?)? onChangedSelectedTeacher,
  required List<DropdownMenuItem<String>>? enumTeachers,
  required void Function()? onPressedClickButton,
}) {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        titlePadding: const EdgeInsets.all(10), // Ajusta o padding do título
        contentPadding: const EdgeInsets.all(10),
        actionsPadding: const EdgeInsets.all(10), // Ajusta o padding das ações
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Criar uma Matéria"),
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
                      label: 'Hora',
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
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
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
}
