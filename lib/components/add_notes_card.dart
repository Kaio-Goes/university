import 'dart:developer';

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

typedef OnSaveCallback = Future<void> Function();

Future<void> addNotesCard({
  required BuildContext context,
  required UserFirebase user,
  required ClassFirebase classe,
  required SubjectModule subject,
  required List<Note> listNotes,
  required List<UserNote> listUserNotes,
  required OnSaveCallback onSave,
}) async {
  Map<String, String> userNotesMap = {
    for (var userNote in listUserNotes)
      userNote.noteId: userNote.value.replaceAll(".", ",")
  };

  List<TextEditingController> controllers = List.generate(
    listNotes.length,
    (index) => TextEditingController(
      text: userNotesMap[listNotes[index].uid] ?? '',
    ),
  );

  final formKey = GlobalKey<FormState>();

  // Armazenar os valores iniciais para comparação de mudanças
  final Map<String, String> initialValues = {};
  for (int i = 0; i < listNotes.length; i++) {
    initialValues[listNotes[i].uid] = controllers[i].text;
  }

  return showDialog(
    context: context,
    // Use barrierDismissible: false para evitar que o diálogo seja fechado por um toque fora dele,
    // garantindo que você tenha controle total sobre o fechamento.
    barrierDismissible: false,
    builder: (dialogContext) {
      return SingleChildScrollView(
        child: StatefulBuilder(
          builder: (stfContext, setState) {
            final ValueNotifier<bool> isSaveButtonEnabled =
                ValueNotifier(false);

            // Função para verificar se houve alguma alteração nos inputs
            void checkChanges() {
              bool hasChanged = false;
              for (int i = 0; i < listNotes.length; i++) {
                if (initialValues[listNotes[i].uid] != controllers[i].text) {
                  hasChanged = true;
                  break;
                }
              }
              isSaveButtonEnabled.value = hasChanged;
            }

            // Adicionar listeners aos controladores para detectar mudanças
            // Certifique-se de que os listeners sejam adicionados apenas uma vez
            // e removidos quando os controllers não forem mais necessários.
            // Isso é feito no dispose do State, mas como estamos em um showDialog
            // e o controller é criado aqui, a remoção precisa ser manual
            // ao fechar o diálogo.
            for (var controller in controllers) {
              // Only add listener if it hasn't been added yet (to prevent multiple listeners)
              // This check is a bit complex for TextEditingController directly.
              // A simpler approach for a dialog is to ensure cleanup on dialog close.
              controller.addListener(checkChanges);
            }

            // Inicializar o estado do botão (pode ser desabilitado inicialmente)
            // Use addPostFrameCallback para garantir que os widgets foram renderizados
            WidgetsBinding.instance.addPostFrameCallback((_) {
              checkChanges();
            });

            // Adicione um DisposableListener para garantir a limpeza quando o diálogo for fechado
            // Esta é uma prática recomendada para recursos criados em um StatefulBuilder
            // dentro de um showDialog.
            void disposeResources() {
              for (var controller in controllers) {
                controller.removeListener(checkChanges);
                controller.dispose();
              }
              isSaveButtonEnabled.dispose();
            }

            return AlertDialog(
              titlePadding: const EdgeInsets.all(20),
              actionsPadding: const EdgeInsets.all(10),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Adicionar Notas"),
                  IconButton(
                    onPressed: () {
                      disposeResources(); // Limpa recursos antes de fechar
                      Navigator.of(stfContext).pop();
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
                    disposeResources(); // Limpa recursos antes de fechar
                    Navigator.pop(stfContext);
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
                ValueListenableBuilder<bool>(
                  valueListenable: isSaveButtonEnabled,
                  builder: (context, isEnabled, child) {
                    return TextButton(
                      onPressed: isEnabled
                          ? () async {
                              bool formOk = formKey.currentState!.validate();

                              if (!formOk) {
                                return;
                              }

                              // Desabilitar o botão imediatamente após o clique
                              isSaveButtonEnabled.value = false;

                              Map<String, String> userNotesUidMap = {
                                for (var userNote in listUserNotes)
                                  userNote.noteId: userNote.uid
                              };

                              bool allSavedSuccessfully = true;

                              for (int i = 0; i < listNotes.length; i++) {
                                String noteId = listNotes[i].uid;
                                String? userNoteUid = userNotesUidMap[noteId];

                                try {
                                  if (userNoteUid == null) {
                                    await UserNoteService().createUserNote(
                                      note: controllers[i].text,
                                      classId: classe.uid,
                                      studentId: user.uid,
                                      teacherId:
                                          AuthUserService().currentUser!.uid,
                                      noteId: noteId,
                                      subjectId: subject.uid,
                                    );
                                  } else {
                                    await UserNoteService().updateUserNote(
                                      uid: userNoteUid,
                                      newNote: controllers[i].text,
                                      teacherId:
                                          AuthUserService().currentUser!.uid,
                                    );
                                  }
                                } catch (e) {
                                  allSavedSuccessfully = false;
                                  log("Erro ao criar/atualizar UserNoteService: $e");
                                  // ignore: use_build_context_synchronously
                                  ScaffoldMessenger.of(stfContext).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            'Erro ao salvar nota para ${listNotes[i].title}.')),
                                  );
                                  // Em caso de erro, reabilitar o botão se quiser que o usuário tente novamente
                                  isSaveButtonEnabled.value = true;
                                  break; // Interrompe o loop em caso de erro
                                }
                              }

                              if (allSavedSuccessfully) {
                                await onSave();
                                // Atualizar os valores iniciais após salvar com sucesso
                                for (int i = 0; i < listNotes.length; i++) {
                                  initialValues[listNotes[i].uid] =
                                      controllers[i].text;
                                }
                                // O botão permanece desabilitado se não houver mais alterações
                                checkChanges();

                                // Fechar o diálogo SOMENTE após todas as operações e feedback
                                // e apenas UMA VEZ.
                                disposeResources(); // Limpa recursos antes de fechar
                                // ignore: use_build_context_synchronously
                                Navigator.of(stfContext).pop();

                                // ignore: use_build_context_synchronously
                                sucessUserNoteCreate(
                                    // ignore: use_build_context_synchronously
                                    context: stfContext,
                                    classe: classe,
                                    subject: subject);
                              }
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                          elevation: 5,
                          backgroundColor:
                              isEnabled ? colorPrimaty : Colors.grey,
                          padding: const EdgeInsets.symmetric(horizontal: 45)),
                      child: const Text(
                        'Salvar',
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  },
                ),
              ],
            );
          },
        ),
      );
    },
  );
}
