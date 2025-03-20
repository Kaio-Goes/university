class ClassFirebase {
  late String uid;
  late String name;
  late String subject;
  late List<String> students;
  late String typeClass;
  late String startDate;
  late String endDate;

  ClassFirebase({
    required this.uid,
    required this.name,
    required this.subject,
    required this.students,
    required this.typeClass,
    required this.startDate,
    required this.endDate,
  });

  ClassFirebase.fromJson(Map<String, dynamic> json) {
    uid = json['uid'] ?? '';
    name = json['name'] ?? '';
    subject = json['subject'] ?? '';
    students = (json['students'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];
    typeClass = json['type'] ?? '';
    startDate = json['startDate'] ?? '';
    endDate = json['endDate'] ?? '';
  }
}
