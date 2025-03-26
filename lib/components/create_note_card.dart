import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:university/components/text_fields.dart';
import 'package:university/components/validation/validation.dart';
import 'package:university/core/models/class_firebase.dart';
import 'package:university/core/models/subject_module.dart';
import 'package:university/core/utilities/styles.constants.dart';
import 'package:university/pages/teacher/dashboard/dashboard_teacher_page.dart';
import 'package:university/pages/teacher/notes/add_notes_student_page.dart';
import 'package:university/pages/teacher/notes/create_notes_page.dart';

createNoteCard(
    {required BuildContext context,
    required var formKey,
    String? title,
    required TextEditingController titleController,
    required TextEditingController noteController,
    required void Function()? onPressed}) {
  return showDialog(
    context: context,
    builder: (context) {
      return SingleChildScrollView(
        child: StatefulBuilder(builder: (context, snapshot) {
          return AlertDialog(
            titlePadding: const EdgeInsets.all(20),
            contentPadding: const EdgeInsets.all(10),
            actionsPadding: const EdgeInsets.all(20),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title ?? "Criar um Trabalho/Prova"),
                IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.close),
                )
              ],
            ),
            content: SizedBox(
              height: 250,
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                      "Após ser criado, estará disponível para lançar a nota para o aluno."),
                  const SizedBox(height: 15),
                  Form(
                    key: formKey,
                    child: Column(
                      children: [
                        textFormField(
                          controller: titleController,
                          validator: (value) => validInputNome(value),
                          label: "Título",
                          hint: 'Ex: Teste 01',
                          size: 600,
                        ),
                        const SizedBox(height: 20),
                        textFormField(
                            controller: noteController,
                            validator: (value) => validNote(value, 10.0),
                            inputFormatters: [
                              MaskTextInputFormatter(
                                mask: '##,##',
                                filter: {"#": RegExp(r'^[0-9]*$')},
                                type: MaskAutoCompletionType.lazy,
                              )
                            ],
                            textInputType:
                                const TextInputType.numberWithOptions(),
                            label: "Nota",
                            hint: "Valor da Nota Ex: 10,00",
                            size: 600),
                        const SizedBox(height: 15),
                      ],
                    ),
                  )
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                    elevation: 5,
                    backgroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 30)),
                child: const Text(
                  'Cancelar',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              TextButton(
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(
                    elevation: 5,
                    backgroundColor: colorPrimaty,
                    padding: const EdgeInsets.symmetric(horizontal: 45)),
                child: const Text(
                  'Enviar',
                  style: TextStyle(color: Colors.white),
                ),
              )
            ],
          );
        }),
      );
    },
  );
}

sucessNoteCreate(
    {required BuildContext context,
    required ClassFirebase classFirebase,
    required SubjectModule subject}) {
  return showDialog(
    // ignore: use_build_context_synchronously
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Sucesso"),
        content: const Text("Nota para turma criada com sucesso!"),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                      builder: (context) => const DashboardTeacherPage()),
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
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => CreateNotesPage(
                    classFirebase: classFirebase,
                    subject: subject,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 50, 102, 214)),
            child: const Text(
              "Ir para Adicionar Notas",
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
}

sucessUserNoteCreate({
  required BuildContext context,
  required ClassFirebase classe,
  required SubjectModule subject,
}) {
  return showDialog(
    // ignore: use_build_context_synchronously
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Sucesso"),
        content: const Text("Nota para aluno criada com sucesso!"),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                      builder: (context) => const DashboardTeacherPage()),
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
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => AddNotesStudentPage(
                    classe: classe,
                    subject: subject,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 50, 102, 214)),
            child: const Text(
              "Ir para Alunos",
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
}
