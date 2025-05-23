import 'package:firebase_database/firebase_database.dart';
import 'package:university/core/models/subject_module.dart';

class SubjectService {
  Future<void> createSubject({
    required String title,
    required String hour,
    required String daysWeek,
    required String startHour,
    required String endHour,
    required String module,
    required String unity,
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
      'daysWeeks': daysWeek,
      'startHour': startHour,
      'unity': unity,
      'endHour': endHour,
      'created_at': DateTime.now().toLocal().toString(),
      'updated_at': DateTime.now().toLocal().toString(),
    };

    // Definir os valores no path gerado
    await newSubjectRef.set(values);
  }

  Future<List<SubjectModule>> getSubjectsByUser(String userId) async {
    DatabaseReference subjectRef =
        FirebaseDatabase.instance.ref().child('subjects');
    DataSnapshot snapshot = await subjectRef.get();

    List<SubjectModule> subjectModules = [];

    if (snapshot.exists) {
      for (var child in snapshot.children) {
        Map<dynamic, dynamic> data = child.value as Map<dynamic, dynamic>;
        if (data['user_id'] == userId) {
          SubjectModule subjectModule =
              SubjectModule.fromJson(Map<String, dynamic>.from(data));
          subjectModules.add(subjectModule);
        }
      }
    }

    return subjectModules;
  }

  Future<List<SubjectModule>> getSubjectsByUids(
      {required List<String> uids}) async {
    DatabaseReference subjectRef =
        FirebaseDatabase.instance.ref().child('subjects');
    DataSnapshot snapshot = await subjectRef.get();

    List<SubjectModule> subjectModules = [];

    if (snapshot.exists) {
      for (var child in snapshot.children) {
        Map<dynamic, dynamic> data = child.value as Map<dynamic, dynamic>;
        if (uids.contains(data['uid'])) {
          SubjectModule subjectModule =
              SubjectModule.fromJson(Map<String, dynamic>.from(data));
          subjectModules.add(subjectModule);
        }
      }
    }

    return subjectModules;
  }

  Future<List<SubjectModule>> getAllSubjectModule() async {
    DatabaseReference subjectRef =
        FirebaseDatabase.instance.ref().child('subjects');

    DataSnapshot snapshot = await subjectRef.get();

    List<SubjectModule> subjectModules = [];

    if (snapshot.exists) {
      for (var child in snapshot.children) {
        Map<dynamic, dynamic> data = child.value as Map<dynamic, dynamic>;
        SubjectModule subjectModule =
            SubjectModule.fromJson(Map<String, dynamic>.from(data));
        subjectModules.add(subjectModule);
      }
    }
    return subjectModules;
  }

  Future updateSubject({
    required String uid,
    required String title,
    required String hour,
    required String module,
    required String idUser,
    required String daysWeek,
    required String startHour,
    required String endHour,
    required String unity,
  }) async {
    DatabaseReference subjectRef =
        FirebaseDatabase.instance.ref().child('subjects');
    subjectRef.child(uid).update({
      'title': title,
      'hour': hour,
      'module': module,
      'user_id': idUser,
      'daysWeeks': daysWeek,
      'startHour': startHour,
      'unity': unity,
      'endHour': endHour,
      'updated_at': DateTime.now().toLocal().toString(),
    });
  }

  Future<void> deleteSubject({required String uid}) async {
    DatabaseReference subjectRef =
        FirebaseDatabase.instance.ref().child('subjects').child(uid);

    await subjectRef.remove();
  }

  Future<List<SubjectModule>> getSubjectsByUnity(
      {required String unity}) async {
    DatabaseReference subjectRef =
        FirebaseDatabase.instance.ref().child('subjects');
    DataSnapshot snapshot = await subjectRef.get();

    List<SubjectModule> subjectModules = [];

    if (snapshot.exists) {
      for (var child in snapshot.children) {
        Map<dynamic, dynamic> data = child.value as Map<dynamic, dynamic>;
        if (data['unity'] == unity) {
          SubjectModule subjectModule =
              SubjectModule.fromJson(Map<String, dynamic>.from(data));
          subjectModules.add(subjectModule);
        }
      }
    }

    return subjectModules;
  }
}
