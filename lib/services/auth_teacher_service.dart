import 'package:shared_preferences/shared_preferences.dart';
import 'package:university/core/models/user_teacher.dart';

class AuthTeacherService {
  static UserTeacher? _currentUser;

  UserTeacher? get currentUser {
    return _currentUser;
  }

  Future<void> addUserTeacherModel({required UserTeacher user}) async {
    _currentUser = user;
    await _saveUserToCache(user);
  }

  Future<void> logout() async {
    _currentUser = null;
    await _clearUserFromCache();
  }

  Future<void> _saveUserToCache(UserTeacher user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('uid');
    await prefs.remove('name');
    await prefs.remove('email');
    await prefs.remove('role');
    await prefs.remove('cpf');
    await prefs.remove('surnmame');
    await prefs.remove('phone');
    await prefs.remove('is_active');
  }

  Future<void> _clearUserFromCache() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('uid');
    await prefs.remove('name');
    await prefs.remove('email');
    await prefs.remove('role');
    await prefs.remove('cpf');
    await prefs.remove('surnmame');
    await prefs.remove('phone');
    await prefs.remove('is_active');
  }

  Future<void> loadUserFromCache() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? uid = prefs.getString('uid');
    String? name = prefs.getString('name');
    String? email = prefs.getString('email');
    String? role = prefs.getString('role');
    String? cpf = prefs.getString('cpf');
    String? surname = prefs.getString('surnmame');
    String? phone = prefs.getString('phone');
    bool? isActive = prefs.getBool('is_active');
    

    if (uid != null && name != null && email != null && role != null && cpf != null && surname != null && phone != null && isActive != null) {
      _currentUser = UserTeacher(
        uid: uid,
        name: name,
        email: email,
        role: role,
        cpf: cpf,
        surname: surname,
        phone: phone,
        isActive: isActive,
      );
    }
  }
}
