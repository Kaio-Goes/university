import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:university/core/models/user_firebase.dart';

class AuthUserService {
  static UserFirebase? _currentUser;

  UserFirebase? get currentUser {
    return _currentUser;
  }

  Future<void> addUserModel({required UserFirebase user}) async {
    _currentUser = user;
    await _saveUserToCache(user);
  }

  Future<void> logout() async {
    _currentUser = null;
    await _clearUserFromCache();
  }

  Future<void> _saveUserToCache(UserFirebase user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('uid', user.uid);
    await prefs.setString('name', user.name);
    await prefs.setString('email', user.email);
    await prefs.setString('role', user.role);
    await prefs.setString('cpf', user.cpf);
    await prefs.setString('isActive', user.isActive.toString());
    await prefs.setString('phone', user.phone);
    await prefs.setString('rg', user.rg ?? '');
    await prefs.setString('surname', user.surname ?? '');
  }

  Future<void> _clearUserFromCache() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('uid');
    await prefs.remove('name');
    await prefs.remove('email');
    await prefs.remove('role');
    await prefs.remove('cpf');
    await prefs.remove('isActive');
    await prefs.remove('phone');
    await prefs.remove('rg');
    await prefs.remove('surname');
  }

  Future<void> loadUserFromCache() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? uid = prefs.getString('uid');
    String? name = prefs.getString('name');
    String? email = prefs.getString('email');
    String? role = prefs.getString('role');
    String? cpf = prefs.getString('cpf');
    String? isActive = prefs.getString('isActive');
    String? phone = prefs.getString('phone');
    String? rg = prefs.getString('rg');
    String? surname = prefs.getString('surname');

    if (uid != null && name != null && email != null && role != null) {
      _currentUser = UserFirebase(
        uid: uid,
        name: name,
        email: email,
        cpf: cpf ?? 'Não atribuido',
        isActive: isActive == "true" ? true : false,
        phone: phone ?? "",
        rg: rg ?? "",
        surname: surname ?? "",
        role: role,
      );
    }
  }

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

Future<List<UserFirebase>> fetchStudants() async {
  Map<String, List<UserFirebase>> fetchedUsers =
      await AuthUserService().getAllUsers();
  List<UserFirebase> fetchedStudents =
      fetchedUsers['students']?.cast<UserFirebase>() ?? [];

  return fetchedStudents.where((student) => student.isActive).toList();
}
