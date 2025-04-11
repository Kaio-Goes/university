class SubjectModule {
  late String uid;
  late String title;
  late String hour;
  late String daysWeek;
  late String startHour;
  late String endHour;
  late String module;
  String? unity;
  late String userId;

  SubjectModule({
    required this.uid,
    required this.title,
    required this.hour,
    required this.startHour,
    required this.endHour,
    required this.module,
    this.unity,
    required this.userId,
  });

  SubjectModule.fromJson(Map<String, dynamic> json) {
    uid = json["uid"];
    title = json["title"];
    hour = json["hour"];
    daysWeek = json["daysWeeks"];
    startHour = json["startHour"];
    endHour = json["endHour"];
    module = json["module"];
    unity = json['unity'];
    userId = json["user_id"];
  }
}
