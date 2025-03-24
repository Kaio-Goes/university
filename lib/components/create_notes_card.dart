import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:university/components/text_fields.dart';
import 'package:university/components/validation/validation.dart';
import 'package:university/core/utilities/styles.constants.dart';

class CreateNotesCard extends StatefulWidget {
  const CreateNotesCard({super.key});

  @override
  State<CreateNotesCard> createState() => _CreateNotesCardState();
}

class _CreateNotesCardState extends State<CreateNotesCard> {
  final _form = GlobalKey<FormState>();
  TextEditingController titleController = TextEditingController();
  TextEditingController noteController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
        onPressed: () {
          showDialog(
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
                        const Text("Criar um Trabalho/Prova"),
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
                            key: _form,
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
                                    validator: (value) => validNote(value),
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
                            padding:
                                const EdgeInsets.symmetric(horizontal: 30)),
                        child: const Text(
                          'Cancelar',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                            elevation: 5,
                            backgroundColor: colorPrimaty,
                            padding:
                                const EdgeInsets.symmetric(horizontal: 45)),
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
        },
        icon: const Icon(Icons.add),
        label: const Text("Adicionar"));
  }
}
