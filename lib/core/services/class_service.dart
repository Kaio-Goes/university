import 'package:firebase_database/firebase_database.dart';
import 'package:university/core/models/class_firebase.dart';

class ClassService {
  Future<void> createClass({
    required String name,
    required List<String>? subject,
    required String? typeClass,
    required String startDate,
    required String endDate,
    required List<String>? students,
  }) async {
    try {
      DatabaseReference classRef =
          FirebaseDatabase.instance.ref().child('class');
      DatabaseReference newClassRef = classRef.push();
      String uid = newClassRef.key ?? '';

      Map<String, dynamic> classData = {
        'uid': uid,
        'name': name,
        'subject': subject ?? '',
        'type': typeClass ?? '',
        'startDate': startDate,
        'endDate': endDate,
        'students': students ?? [],
      };

      await newClassRef.set(classData);
    } catch (e) {
      Exception('Erro ao criar classe: \$e');
      rethrow;
    }
  }

  Future updateClassFirebase(
      {required String uid,
      required String name,
      required List<String> subject,
      required String typeClass,
      required String startDate,
      required String endDate,
      required List<String> students}) async {
    DatabaseReference classRef = FirebaseDatabase.instance.ref().child('class');
    classRef.child(uid).update({
      'name': name,
      'subject': subject,
      'type': typeClass,
      'startDate': startDate,
      'endDate': endDate,
      'students': students,
    });
  }

  Future<List<ClassFirebase>> getAllClassFirebase() async {
    try {
      DatabaseReference subjectRef =
          FirebaseDatabase.instance.ref().child('class');
      DataSnapshot snapshot = await subjectRef.get();

      List<ClassFirebase> classFirebases = [];

      if (snapshot.exists) {
        for (var child in snapshot.children) {
          Map<dynamic, dynamic> data = child.value as Map<dynamic, dynamic>;
          ClassFirebase classFirebase =
              ClassFirebase.fromJson(Map<String, dynamic>.from(data));
          classFirebases.add(classFirebase);
        }
      }
      return classFirebases;
    } catch (e) {
      Exception('Erro ao buscar classes: \$e');
      return [];
    }
  }

  Future<List<ClassFirebase>> getClassesBySubjects(
      {required List<String> subjectUids}) async {
    try {
      DatabaseReference classRef =
          FirebaseDatabase.instance.ref().child('class');
      DataSnapshot snapshot = await classRef.get();

      List<ClassFirebase> filteredClasses = [];

      if (snapshot.exists) {
        for (var child in snapshot.children) {
          Map<dynamic, dynamic> data = child.value as Map<dynamic, dynamic>;
          List<dynamic> classSubjects = data['subject'] ?? [];

          // Verifica se a turma contém pelo menos um dos subjectUids informados
          if (classSubjects.any((subject) => subjectUids.contains(subject))) {
            ClassFirebase classFirebase =
                ClassFirebase.fromJson(Map<String, dynamic>.from(data));
            filteredClasses.add(classFirebase);
          }
        }
      }
      return filteredClasses;
    } catch (e) {
      Exception('Erro ao buscar classes por subjects: $e');
      return [];
    }
  }

  Future<void> deleteClass({required String uid}) async {
    DatabaseReference classRef =
        FirebaseDatabase.instance.ref().child('class').child(uid);

    await classRef.remove();
  }
}
