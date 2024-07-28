import 'package:university/core/models/user_secretary.dart';

class AuthService {
  static UserSecretary? _currentUser;

  UserSecretary? get currentUser {
    return _currentUser;
  }

  Future addUserSecretaryModel({required UserSecretary user}) async {
    _currentUser = user;
  }

  Future<void> logout() async {
    _currentUser = null;
  }
}
