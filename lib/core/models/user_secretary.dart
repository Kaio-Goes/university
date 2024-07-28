class UserSecretary {
  late String uid;
  late String name;
  late String email;
  late String role;

  UserSecretary({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
  });

  UserSecretary.fromJson(Map<String, dynamic> json) {
    uid = json["uid"];
    name = json["name"];
    email = json['email'];
    role = json['role'];
  }
}
