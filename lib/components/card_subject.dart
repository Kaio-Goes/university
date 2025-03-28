import 'dart:math';
import 'package:flutter/material.dart';
import 'package:university/core/models/class_firebase.dart';
import 'package:university/core/models/subject_module.dart';

class CardSubject extends StatelessWidget {
  final SubjectModule subjectModule;
  final List<ClassFirebase> classFirebase;

  const CardSubject({
    super.key,
    required this.subjectModule,
    required this.classFirebase,
  });

  Color getRandomColor() {
    final Random random = Random();
    return Color.fromRGBO(
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
      1,
    );
  }

  @override
  Widget build(BuildContext context) {
    final classes = classFirebase
        .where((c) => c.subject.contains(subjectModule.uid))
        .map((c) => c.name)
        .toList();

    return SizedBox(
      height: 160,
      width: 350,
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Align(
                alignment: Alignment.center,
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: getRandomColor(),
                  child: const Icon(Icons.book, color: Colors.white, size: 30),
                ),
              ),
              const SizedBox(width: 16), // Espaço entre o avatar e o texto
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      subjectModule.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Dias de aula: ${subjectModule.daysWeek.replaceAll('[', '').replaceAll(']', '')}',
                    ),
                    Text(
                      "Horário: ${subjectModule.startHour} - ${subjectModule.endHour}",
                    ),
                    Text("Módulo: ${subjectModule.module}"),
                    Text(
                      "Turmas: ${classes.isNotEmpty ? classes.join(', ') : 'Não possuo'}",
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
