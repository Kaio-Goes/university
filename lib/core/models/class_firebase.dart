class ClassFirebase {
  late String id;
  late String description;
  late String idSubject;
  late List idUser;
  late String typeClass;
  late String quantityUser;
  late String startDate;
  late String endDate;

  ClassFirebase({
    required this.id,
    required this.description,
    required this.idSubject,
    required this.idUser,
    required this.typeClass,
    required this.quantityUser,
    required this.startDate,
    required this.endDate,
  });

  ClassFirebase.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    description = json['description'];
    idSubject = json['id_subject'];
    idUser = json['id_user'];
    typeClass = json['type_class'];
    quantityUser = json['quantity_user'];
    startDate = json['start_date'];
    endDate = json['end_date'];
  }
}
