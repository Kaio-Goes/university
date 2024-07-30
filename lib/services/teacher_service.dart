import 'package:firebase_database/firebase_database.dart';
import 'package:university/core/models/user_teacher.dart';

class TeacherService {
  Future<List<UserTeacher>> getAllTeacher() async {
    DatabaseReference usersRef = FirebaseDatabase.instance.ref().child('users');
    DatabaseEvent event =
        await usersRef.orderByChild('role').equalTo('teacher').once();
    DataSnapshot snapshot = event.snapshot;

    List<UserTeacher> teachersList = []; // Crie uma nova lista local

    if (snapshot.value != null) {
      Map<dynamic, dynamic> usersMap = snapshot.value as Map<dynamic, dynamic>;
      usersMap.forEach((key, value) {
        teachersList
            .add(UserTeacher.fromJson(Map<String, dynamic>.from(value)));
      });
    }

    return teachersList; // Retorne a nova lista
  }
}
