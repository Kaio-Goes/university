class UserNote {
  late String uid;
  late String value;
  late String userId;
  late String classId;
  late String noteId;
  late String teacherId;
  late String subjectId;

  UserNote({
    required this.uid,
    required this.value,
    required this.userId,
    required this.classId,
    required this.noteId,
    required this.teacherId,
    required this.subjectId,
  });

  UserNote.fromJson(Map<String, dynamic> json) {
    uid = json['uid'];
    value = json['value'];
    userId = json['user_id'];
    classId = json['class_id'];
    noteId = json['note_id'];
    teacherId = json['teacher_id'];
    subjectId = json['subject_id'];
  }
}
