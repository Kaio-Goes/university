import 'package:firebase_database/firebase_database.dart';
import 'package:university/core/models/subject_module.dart';

class SubjectService {
  Future<void> createSubject({
    required String title,
    required String hour,
    required String module,
    required String idUser,
  }) async {
    // Referência para a coleção 'subjects'
    DatabaseReference subjectRef =
        FirebaseDatabase.instance.ref().child('subjects');

    // Gerar um UID aleatório para o path
    DatabaseReference newSubjectRef = subjectRef.push();

    // Recuperar o UID gerado
    String uid = newSubjectRef.key ?? '';

    // Valores a serem definidos
    Map<String, String> values = {
      'uid': uid,
      'title': title,
      'hour': hour,
      'module': module,
      'user_id': idUser,
    };

    // Definir os valores no path gerado
    await newSubjectRef.set(values);
  }

  Future<List<SubjectModule>> getAllSubjectModule() async {
    DatabaseReference subjectRef =
        FirebaseDatabase.instance.ref().child('subjects');

    DataSnapshot snapshot = await subjectRef.get();

    List<SubjectModule> subjectModules = [];

    if (snapshot.exists) {
      snapshot.children.forEach((child) {
        Map<dynamic, dynamic> data = child.value as Map<dynamic, dynamic>;
        SubjectModule subjectModule =
            SubjectModule.fromJson(Map<String, dynamic>.from(data));
        subjectModules.add(subjectModule);
      });
    }

    return subjectModules;
  }
}
