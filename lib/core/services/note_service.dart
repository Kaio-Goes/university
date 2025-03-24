import 'package:firebase_database/firebase_database.dart';
import 'package:university/core/models/note.dart';

class NoteService {
  Future createNote({
    required String title,
    required String note,
    required String userId,
    required String classId,
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
    };

    await newNoteRef.set(values);
  }

  Future<List<Note>> getListNotesByClass({
    required String userId,
    required String classId,
  }) async {
    DatabaseReference noteRef = FirebaseDatabase.instance.ref().child('notes');
    DataSnapshot snapshot = await noteRef.get();

    List<Note> notes = [];

    if (snapshot.exists) {
      for (var child in snapshot.children) {
        Map<dynamic, dynamic> data = child.value as Map<dynamic, dynamic>;
        if (data['user_id'] == userId && data['class_id'] == classId) {
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
  }) async {
    DatabaseReference noteRef =
        FirebaseDatabase.instance.ref().child("notes").child(uid);

    DataSnapshot snapshot = await noteRef.get();

    if (snapshot.exists) {
      Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;

      if (data['user_id'] == userId && data['class_id'] == classId) {
        await noteRef.update({
          "title": title,
          "value": note,
        });
      } else {
        throw Exception("Permissão negada: Usuário ou turma inválidos.");
      }
    } else {
      throw Exception("Nota não encontrada.");
    }
  }
}
