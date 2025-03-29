import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:university/components/create_note_card.dart';
import 'package:university/components/text_fields.dart';
import 'package:university/components/validation/validation.dart';
import 'package:university/core/models/class_firebase.dart';
import 'package:university/core/models/note.dart';
import 'package:university/core/models/subject_module.dart';
import 'package:university/core/models/user_firebase.dart';
import 'package:university/core/models/user_note.dart';
import 'package:university/core/services/auth_user_service.dart';
import 'package:university/core/services/user_note_service.dart';
import 'package:university/core/utilities/styles.constants.dart';

addNotesCard({
  required BuildContext context,
  required UserFirebase user,
  required ClassFirebase classe,
  required SubjectModule subject,
  required List<Note> listNotes,
  required List<UserNote> listUserNotes,
}) async {
  Map<String, String> userNotesMap = {
    for (var userNote in listUserNotes)
      userNote.noteId: userNote.value.replaceAll(".", ",")
  };

  // Criando controladores e preenchendo caso haja notas salvas
  List<TextEditingController> controllers = List.generate(
    listNotes.length,
    (index) => TextEditingController(
      text:
          userNotesMap[listNotes[index].uid] ?? '', // Define o valor se existir
    ),
  );

  final formKey = GlobalKey<FormState>();

  return showDialog(
    context: context,
    builder: (context) {
      return SingleChildScrollView(
        child: StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              titlePadding: const EdgeInsets.all(20),
              actionsPadding: const EdgeInsets.all(10),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Adicionar Notas"),
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.close),
                  )
                ],
              ),
              content: SizedBox(
                height: listNotes.length == 1
                    ? listNotes.length * 160
                    : listNotes.length * 140,
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Aluno ${user.name}",
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w400),
                    ),
                    const SizedBox(height: 15),
                    Form(
                      key: formKey,
                      child: Column(
                        children: [
                          for (int i = 0; i < listNotes.length; i++) ...[
                            textFormField(
                                controller: controllers[i],
                                validator: (value) => validNote(
                                    value, double.parse(listNotes[i].value)),
                                inputFormatters: [
                                  MaskTextInputFormatter(
                                    mask: '##,##',
                                    filter: {"#": RegExp(r'^[0-9]*$')},
                                    type: MaskAutoCompletionType.lazy,
                                  )
                                ],
                                textInputType:
                                    const TextInputType.numberWithOptions(),
                                label:
                                    "${listNotes[i].title}      Pontuação até ${listNotes[i].value.replaceAll('.', ',')}",
                                hint: 'Digite a nota Ex: 01,00',
                                size: 400),
                            const SizedBox(height: 15)
                          ]
                        ],
                      ),
                    ),
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
                  onPressed: () async {
                    bool formOk = formKey.currentState!.validate();

                    if (!formOk) {
                      return;
                    }
                    Map<String, String> userNotesUidMap = {
                      for (var userNote in listUserNotes)
                        userNote.noteId: userNote.uid
                    };

                    for (int i = 0; i < listNotes.length; i++) {
                      String noteId = listNotes[i].uid;
                      String? userNoteUid = userNotesUidMap[
                          noteId]; // Pegando o uid da UserNote se existir

                      try {
                        if (userNoteUid == null) {
                          await UserNoteService()
                              .createUserNote(
                            note: controllers[i].text,
                            classId: classe.uid,
                            studentId: user.uid,
                            teacherId: AuthUserService().currentUser!.uid,
                            noteId: noteId,
                            subjectId: subject.uid,
                          )
                              .then(
                            (_) {
                              sucessUserNoteCreate(
                                // ignore: use_build_context_synchronously
                                context: context,
                                classe: classe,
                                subject: subject,
                              );
                            },
                          );
                        } else {
                          await UserNoteService()
                              .updateUserNote(
                            uid: userNoteUid,
                            newNote: controllers[i].text,
                            teacherId: AuthUserService().currentUser!.uid,
                          )
                              .then(
                            (_) {
                              sucessUserNoteCreate(
                                // ignore: use_build_context_synchronously
                                context: context,
                                classe: classe,
                                subject: subject,
                              );
                            },
                          );
                        }
                      } catch (e) {
                        Exception("Erro create UserNoteService $e");
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      elevation: 5,
                      backgroundColor: colorPrimaty,
                      padding: const EdgeInsets.symmetric(horizontal: 45)),
                  child: const Text(
                    'Salvar',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        ),
      );
    },
  );
}
