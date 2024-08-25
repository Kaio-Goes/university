class UserTeacher {
  late String uid;
  late String name;
  late String surname;
  late String email;
  late String role;
  late String cpf;
  late String phone;
  late bool isActive;

  UserTeacher({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.cpf,
    required this.phone,
    required this.isActive,
    required this.surname,
  });

  UserTeacher.fromJson(Map<String, dynamic> json) {
    uid = json["uid"];
    name = json["name"];
    email = json["email"];
    role = json["role"];
    cpf = json["cpf"];
    phone = json["phone"];
    isActive = json["is_active"];
  }
}
