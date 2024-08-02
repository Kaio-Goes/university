class UserFirebase {
  late String uid;
  late String name;
  String? surname;
  late String email;
  String? rg;
  late String cpf;
  late String phone;
  late String role;
  late bool isActive;

  UserFirebase(
      {required this.uid,
      required this.name,
      this.surname,
      required this.email,
      this.rg,
      required this.cpf,
      required this.phone,
      required this.role,
      required this.isActive});

  UserFirebase.fromJson(Map<String, dynamic> json) {
    uid = json["uid"];
    name = json["name"];
    surname = json['surname'];
    rg = json['rg'];
    email = json['email'];
    cpf = json['cpf'];
    role = json['role'];
    phone = json['phone'];
    isActive = json['isActive'];
  }
}
