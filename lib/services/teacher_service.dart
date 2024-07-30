import 'package:firebase_database/firebase_database.dart';
import 'package:university/core/models/user_teacher.dart';

class TeacherService {
  static List<UserTeacher> teachers = [];

  Future<List<UserTeacher>> getAllTeacher() async {
    DatabaseReference usersRef = FirebaseDatabase.instance.ref().child('users');
    DatabaseEvent event =
        await usersRef.orderByChild('role').equalTo('teacher').once();
    DataSnapshot snapshot = event.snapshot;

    if (snapshot.value != null) {
      Map<dynamic, dynamic> usersMap = snapshot.value as Map<dynamic, dynamic>;
      usersMap.forEach((key, value) {
        teachers.add(UserTeacher.fromJson(Map<String, dynamic>.from(value)));
      });
    }

    return teachers;
  }
}
