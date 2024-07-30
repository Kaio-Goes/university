class UserTeacher {
  late String uid;
  late String name;
  late String surname;
  late String email;
  late String cpf;
  late String phone;
  late String role;
  late bool isActive;

  UserTeacher(
      {required this.uid,
      required this.name,
      required this.surname,
      required this.email,
      required this.cpf,
      required this.phone,
      required this.role,
      required this.isActive});

  UserTeacher.fromJson(Map<String, dynamic> json) {
    uid = json["uid"];
    name = json["name"];
    surname = json['surname'];
    email = json['email'];
    cpf = json['cpf'];
    role = json['role'];
    phone = json['phone'];
    isActive = json['isActive'];
  }
}
