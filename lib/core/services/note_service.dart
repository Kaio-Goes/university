import 'package:firebase_database/firebase_database.dart';
import 'package:university/core/models/note.dart';

class NoteService {
  Future createNote({
    required String title,
    required String note,
    required String userId,
    required String classId,
    required String subjectId,
  }) async {
    DatabaseReference noteRef = FirebaseDatabase.instance.ref().child("notes");

    DatabaseReference newNoteRef = noteRef.push();

    String uid = newNoteRef.key ?? '';

    Map<String, String> values = {
      "uid": uid,
      "title": title,
      "value": note,
      "user_id": userId,
      "class_id": classId,
      "subject_id": subjectId,
      'created_at': DateTime.now().toLocal().toString(),
      'updated_at': DateTime.now().toLocal().toString(),
    };

    await newNoteRef.set(values);
  }

  Future<List<Note>> getListNotesByClass({
    String? userId,
    required String classId,
    required String subjectId,
  }) async {
    DatabaseReference noteRef = FirebaseDatabase.instance.ref().child('notes');
    DataSnapshot snapshot = await noteRef.get();

    List<Note> notes = [];

    if (snapshot.exists) {
      for (var child in snapshot.children) {
        Map<dynamic, dynamic> data = child.value as Map<dynamic, dynamic>;
        if (data['user_id'] == userId &&
            data['class_id'] == classId &&
            data['subject_id'] == subjectId) {
          Note note = Note.fromJson(Map<String, dynamic>.from(data));
          notes.add(note);
        }
      }
    }
    return notes;
  }

  Future<void> updateNote({
    required String uid,
    required String title,
    required String note,
    required String userId,
    required String classId,
    required String subejctId,
  }) async {
    DatabaseReference noteRef =
        FirebaseDatabase.instance.ref().child("notes").child(uid);

    DataSnapshot snapshot = await noteRef.get();

    if (snapshot.exists) {
      Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;

      if (data['user_id'] == userId &&
          data['class_id'] == classId &&
          data['subject_id'] == subejctId) {
        await noteRef.update({
          "title": title,
          "value": note,
          'updated_at': DateTime.now().toLocal().toString(),
        });
      } else {
        throw Exception("Permissão negada: Usuário ou turma inválidos.");
      }
    } else {
      throw Exception("Nota não encontrada.");
    }
  }
}
