import 'package:flutter/material.dart';
import 'package:university/components/app_bar_user_component.dart';
import 'package:university/components/footer.dart';
import 'package:university/components/list_class_teacher.dart';
import 'package:university/core/models/subject_module.dart';
import 'package:university/services/auth_user_service.dart';
import 'package:university/services/subject_service.dart';

class DashboardTeacherPage extends StatefulWidget {
  const DashboardTeacherPage({super.key});

  @override
  State<DashboardTeacherPage> createState() => _DashboardTeacherPageState();
}

class _DashboardTeacherPageState extends State<DashboardTeacherPage> {
  final TextEditingController searchController = TextEditingController();
  List<SubjectModule> listSubject = [];

  @override
  void initState() {
    super.initState();
    _loadClass();
  }

  Future _loadClass() async {
    try {
      await AuthUserService().loadUserFromCache();

      var subjects = await SubjectService()
          .getSubjectsByUser(AuthUserService().currentUser!.uid);

      setState(() {
        listSubject = subjects;
      });
    } catch (e) {
      Exception('Erro loading class $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarUserComponent(userFirebase: AuthUserService().currentUser),
      body: SingleChildScrollView(
        child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
          bool isSmallScreen = constraints.maxWidth < 800;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    const SizedBox(height: 15),
                    ListClassTeacher(
                      isSmallScreen: isSmallScreen,
                      searchController: searchController,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              const Footer(),
            ],
          );
        }),
      ),
    );
  }
}
