class SubjectModule {
  late String uid;
  late String title;
  late String hour;
  late String module;
  late String userId;

  SubjectModule({
    required this.uid,
    required this.title,
    required this.hour,
    required this.module,
    required this.userId,
  });

  SubjectModule.fromJson(Map<String, dynamic> json) {
    uid = json["uid"];
    title = json["title"];
    hour = json["hour"];
    module = json["module"];
    userId = json["user_id"];
  }
}
