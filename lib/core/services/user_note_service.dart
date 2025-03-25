import 'package:firebase_database/firebase_database.dart';
import 'package:university/core/models/user_note.dart';

class UserNoteService {
  Future createUserNote(
      {required String note,
      required String classId,
      required String studentId,
      required String teacherId,
      required String noteId,
      required}) async {
    DatabaseReference userNoteRef =
        FirebaseDatabase.instance.ref().child("user_note");

    DatabaseReference newUserNoteRef = userNoteRef.push();

    String uid = newUserNoteRef.key ?? '';

    String formattedNote = note.replaceAll(',', '.');

    Map<String, String> values = {
      "uid": uid,
      "value": formattedNote,
      "class_id": classId,
      "user_id": studentId,
      "teacher_id": teacherId,
      "note_id": noteId,
      "created_at": DateTime.now().toLocal().toString(),
      "updated_at": DateTime.now().toLocal().toString(),
    };

    await newUserNoteRef.set(values);
  }

  Future<List<UserNote>> getListUserNote({
    required String classId,
    required String userId,
    String? teacherId, // Opcional
  }) async {
    DatabaseReference userNoteRef =
        FirebaseDatabase.instance.ref().child("user_note");

    DatabaseEvent event = await userNoteRef.once();
    DataSnapshot snapshot = event.snapshot;

    List<UserNote> userNotes = [];

    if (snapshot.value != null && snapshot.value is Map) {
      Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;

      data.forEach((key, value) {
        if (value is Map) {
          // Verifica os filtros
          bool matchClass = value["class_id"] == classId;
          bool matchUser = value["user_id"] == userId;
          bool matchTeacher =
              teacherId == null || value["teacher_id"] == teacherId;

          if (matchClass && matchUser && matchTeacher) {
            userNotes.add(UserNote.fromJson(Map<String, dynamic>.from(value)));
          }
        }
      });
    }

    return userNotes;
  }

  Future<void> updateUserNote({
    required String uid,
    required String newNote,
    required String teacherId,
  }) async {
    DatabaseReference userNoteRef =
        FirebaseDatabase.instance.ref().child("user_note").child(uid);

    String formattedNote = newNote.replaceAll(',', '.');

    Map<String, String> updatedValues = {
      "value": formattedNote,
      "teacher_id": teacherId,
      "updated_at": DateTime.now().toLocal().toString(),
    };

    await userNoteRef.update(updatedValues);
  }
}
