import 'package:firebase_database/firebase_database.dart';
import 'package:university/core/models/user_firebase.dart';

class UsersService {
  Future<Map<String, List<UserFirebase>>> getAllUsers() async {
    DatabaseReference usersRef = FirebaseDatabase.instance.ref().child('users');

    // Obter professores
    DatabaseEvent teachersEvent =
        await usersRef.orderByChild('role').equalTo('teacher').once();
    DataSnapshot teachersSnapshot = teachersEvent.snapshot;

    // Obter estudantes
    DatabaseEvent studentsEvent =
        await usersRef.orderByChild('role').equalTo('student').once();
    DataSnapshot studentsSnapshot = studentsEvent.snapshot;

    List<UserFirebase> teachersList = [];
    List<UserFirebase> studentsList = [];

    // Processar professores
    if (teachersSnapshot.value != null) {
      Map<dynamic, dynamic> teachersMap =
          teachersSnapshot.value as Map<dynamic, dynamic>;
      teachersMap.forEach((key, value) {
        teachersList
            .add(UserFirebase.fromJson(Map<String, dynamic>.from(value)));
      });
    }

    // Processar estudantes
    if (studentsSnapshot.value != null) {
      Map<dynamic, dynamic> studentsMap =
          studentsSnapshot.value as Map<dynamic, dynamic>;
      studentsMap.forEach((key, value) {
        studentsList
            .add(UserFirebase.fromJson(Map<String, dynamic>.from(value)));
      });
    }

    return {'teachers': teachersList, 'students': studentsList};
  }
}
