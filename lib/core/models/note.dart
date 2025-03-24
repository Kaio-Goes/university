class Note {
  late String uid;
  late String title;
  late String value;
  late String userId;
  late String classId;

  Note({
    required this.uid,
    required this.title,
    required this.value,
    required this.userId,
    required this.classId,
  });

  Note.fromJson(Map<String, dynamic> json) {
    uid = json['uid'];
    title = json['title'];
    value = json['value'];
    userId = json['user_id'];
    classId = json['class_id'];
  }
}
