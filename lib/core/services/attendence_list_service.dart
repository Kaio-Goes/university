import 'package:firebase_database/firebase_database.dart';
import 'package:university/core/models/attendence_list.dart';

class AttendenceListService {
  Future<void> createAttendenceList(
      {required String studentId,
      required String teacherId,
      required String subjectId,
      required String classId,
      required String status,
      required String classDate,
      required String roleUser}) async {
    try {
      if (roleUser != 'teacher') {
        throw Exception(
            "Apenas usuários com papel de professor podem criar lista de presença.");
      }

      DatabaseReference attendenceListRef =
          FirebaseDatabase.instance.ref().child('attendence_list');
      DatabaseReference newUserNoteRef = attendenceListRef.push();

      String uid = newUserNoteRef.key ?? '';

      Map<String, String> values = {
        "uid": uid,
        "class_id": classId,
        "user_id": studentId,
        "teacher_id": teacherId,
        "status": status,
        "subject_id": subjectId,
        "date_class": classDate,
        "created_at": DateTime.now().toLocal().toString(),
        "updated_at": DateTime.now().toLocal().toString(),
      };

      await newUserNoteRef.set(values);
    } catch (e) {
      Exception("Error create Attendence List $e");
      rethrow;
    }
  }

  Future<List<AttendenceList>> getAttendenceList({
    required String studentId,
    required String teacherId,
    required String classId,
    required String subjectId,
  }) async {
    try {
      DatabaseReference ref =
          FirebaseDatabase.instance.ref().child('attendence_list');

      final snapshot = await ref.get();

      if (snapshot.exists) {
        final Map data = snapshot.value as Map;

        final filtered = data.entries.where((entry) {
          final value = Map<String, dynamic>.from(entry.value);
          return value['user_id'] == studentId &&
              value['teacher_id'] == teacherId &&
              value['class_id'] == classId &&
              value['subject_id'] == subjectId;
        }).map((entry) {
          final value = Map<String, dynamic>.from(entry.value);
          return AttendenceList.fromJson(value);
        }).toList();

        return filtered;
      } else {
        return [];
      }
    } catch (e) {
      Exception("Erro ao buscar lista de presença: $e");
      rethrow;
    }
  }

  Future<void> updateAttendenceList({
    required String uid,
    required String studentId,
    required String teacherId,
    required String subjectId,
    required String classId,
    required String status,
  }) async {
    DatabaseReference attendenceRef =
        FirebaseDatabase.instance.ref().child("attendence_list").child(uid);

    Map<String, String> updatedValues = {
      "user_id": studentId,
      "teacher_id": teacherId,
      "subject_id": subjectId,
      "class_id": classId,
      "status": status,
      "updated_at": DateTime.now().toLocal().toString(),
    };

    await attendenceRef.update(updatedValues);
  }
}
