import 'package:flutter/material.dart';
import 'package:university/components/app_bar_user_component.dart';
import 'package:university/components/create_notes_card.dart';
import 'package:university/components/footer.dart';
import 'package:university/core/models/class_firebase.dart';
import 'package:university/core/models/subject_module.dart';
import 'package:university/core/services/auth_user_service.dart';

class CreateNotesPage extends StatefulWidget {
  final ClassFirebase classFirebase;
  final List<SubjectModule> listSubject;
  const CreateNotesPage(
      {super.key, required this.classFirebase, required this.listSubject});

  @override
  State<CreateNotesPage> createState() => _CreateNotesPageState();
}

class _CreateNotesPageState extends State<CreateNotesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarUserComponent(userFirebase: AuthUserService().currentUser),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 15),
                    Text(
                      "Turma ${widget.classFirebase.name}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                        "Adicionar notas Trabalhos ou Provas para a matéria ${widget.listSubject.where((subject) => widget.classFirebase.subject.contains(subject.uid)).map((subject) => subject.title).join(', ')} "),
                    const SizedBox(height: 20),
                    CreateNotesCard()
                  ],
                ),
              ),
            ),
          ),
          const Footer(), // Footer sempre no final da tela
        ],
      ),
    );
  }
}
