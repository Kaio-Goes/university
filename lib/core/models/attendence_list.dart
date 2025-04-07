class AttendenceList {
  late String uid;
  late String studentId;
  late String teacherId;
  late String subjectId;
  late String classId;
  late String status;
  late String dateClass;

  AttendenceList({
    required this.uid,
    required this.studentId,
    required this.teacherId,
    required this.subjectId,
    required this.classId,
    required this.status,
    required this.dateClass,
  });

  AttendenceList.fromJson(Map<String, dynamic> json) {
    uid = json['uid'];
    studentId = json['user_id'];
    teacherId = json['teacher_id'];
    subjectId = json['subject_id'];
    classId = json['class_id'];
    status = json['status'];
    dateClass = json['date_class'];
  }
}
