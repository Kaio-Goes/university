class UserFirebase {
  late String uid;
  late String name;
  String? surname;
  late String email;
  String? rg;
  late String cpf;
  late String phone;
  String? sex;
  String? birthDate;
  String? cep;
  String? unity;
  String? address;
  String? registration;
  String? nacionality;
  String? naturalness;
  String? uf;
  String? voterRegistration;
  String? zona;
  String? bloodType;
  String? motherName;
  String? fatherName;
  String? course;
  String? regime;
  String? monthYear;
  late String role;
  late bool isActive;

  UserFirebase({
    required this.uid,
    required this.name,
    this.surname,
    required this.email,
    this.rg,
    required this.cpf,
    required this.phone,
    this.sex,
    this.birthDate,
    this.cep,
    this.address,
    this.registration,
    this.unity,
    this.nacionality,
    this.naturalness,
    this.uf,
    this.voterRegistration,
    this.zona,
    this.bloodType,
    this.motherName,
    this.fatherName,
    this.course,
    this.regime,
    this.monthYear,
    required this.role,
    required this.isActive,
  });

  UserFirebase.fromJson(Map<String, dynamic> json) {
    uid = json["uid"];
    name = json["name"];
    surname = json['surname'];
    rg = json['rg'];
    email = json['email'];
    voterRegistration = json['voter_registration'];
    zona = json['zona'];
    motherName = json['mother_name'];
    fatherName = json['father_name'];
    cpf = json['cpf'];
    role = json['role'];
    bloodType = json['blood_type'];
    phone = json['phone'];
    sex = json['sex'];
    unity = json['unity'];
    birthDate = json['birth_date'];
    cep = json['cep'];
    address = json['address'];
    registration = json['registration'];
    nacionality = json['nacionality'];
    naturalness = json['naturalness'];
    course = json['course'];
    regime = json['regime'];
    monthYear = json['month_year'];
    uf = json['uf'];
    isActive = json['isActive'];
  }
}
