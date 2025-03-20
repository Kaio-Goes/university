import 'package:firebase_database/firebase_database.dart';

class ClassService {
  Future<void> createClass({
    required String name,
    required String? subject,
    required String? typeClass,
    required String startDate,
    required String endDate,
    required List<String>? students,
  }) async {
    DatabaseReference classRef = FirebaseDatabase.instance.ref().child('class');
    DatabaseReference newClassRef = classRef.push();
    String uid = newClassRef.key ?? '';

    Map<String, dynamic> classData = {
      'uid': uid,
      'name': name,
      'subject': subject ?? '',
      'type': typeClass ?? '',
      'startDate': startDate,
      'endDate': endDate,
      'students': students ?? '',
    };

    await newClassRef.set(classData);
  }
}
