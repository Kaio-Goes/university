import 'package:firebase_database/firebase_database.dart';

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
}
