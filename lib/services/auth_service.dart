import 'package:shared_preferences/shared_preferences.dart';
import 'package:university/core/models/user_secretary.dart';

class AuthService {
  static UserSecretary? _currentUser;

  UserSecretary? get currentUser {
    return _currentUser;
  }

  Future<void> addUserSecretaryModel({required UserSecretary user}) async {
    _currentUser = user;
    await _saveUserToCache(user);
  }

  Future<void> logout() async {
    _currentUser = null;
    await _clearUserFromCache();
  }

  Future<void> _saveUserToCache(UserSecretary user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('uid', user.uid);
    await prefs.setString('name', user.name);
    await prefs.setString('email', user.email);
    await prefs.setString('role', user.role);
  }

  Future<void> _clearUserFromCache() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('uid');
    await prefs.remove('name');
    await prefs.remove('email');
    await prefs.remove('role');
  }

  Future<void> loadUserFromCache() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? uid = prefs.getString('uid');
    String? name = prefs.getString('name');
    String? email = prefs.getString('email');
    String? role = prefs.getString('role');

    if (uid != null && name != null && email != null && role != null) {
      _currentUser = UserSecretary(
        uid: uid,
        name: name,
        email: email,
        role: role,
      );
    }
  }
}
