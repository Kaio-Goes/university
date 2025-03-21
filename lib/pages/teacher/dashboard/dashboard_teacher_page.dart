import 'package:flutter/material.dart';
import 'package:university/components/app_bar_user_component.dart';
import 'package:university/components/footer.dart';
import 'package:university/components/list_class_teacher.dart';
import 'package:university/core/models/class_firebase.dart';
import 'package:university/core/models/subject_module.dart';
import 'package:university/services/auth_user_service.dart';
import 'package:university/services/class_service.dart';
import 'package:university/services/subject_service.dart';

class DashboardTeacherPage extends StatefulWidget {
  const DashboardTeacherPage({super.key});

  @override
  State<DashboardTeacherPage> createState() => _DashboardTeacherPageState();
}

class _DashboardTeacherPageState extends State<DashboardTeacherPage> {
  final TextEditingController searchController = TextEditingController();
  List<SubjectModule> listSubject = [];
  List<ClassFirebase> listClass = [];

  List<ClassFirebase> filteredClass = [];

  bool isAscendingClass = true;
  int currentPageClass = 1;
  int itemsPerPageClass = 5;

  @override
  void initState() {
    super.initState();
    _loadClass();

    searchController.addListener(() {
      filterClass();
    });
  }

  Future _loadClass() async {
    try {
      await AuthUserService().loadUserFromCache();

      var subjects = await SubjectService()
          .getSubjectsByUser(AuthUserService().currentUser!.uid);

      var subjectUids = subjects.map((subject) => subject.uid).toList();

      var classList =
          await ClassService().getClassesBySubjects(subjectUids: subjectUids);

      setState(() {
        listSubject = subjects;
        listClass = classList;
        filteredClass = listClass;
        print(listClass);
      });
    } catch (e) {
      Exception('Erro loading class $e');
    }
  }

  void filterClass() {
    setState(() {
      filteredClass = listClass.where((classe) {
        return classe.name
            .toLowerCase()
            .contains(searchController.text.toLowerCase());
      }).toList();
    });
  }

  void _sortClassByName() {
    setState(() {
      filteredClass.sort((a, b) {
        if (isAscendingClass) {
          return a.name.compareTo(b.name);
        } else {
          return b.name.compareTo(a.name);
        }
      });
      isAscendingClass = !isAscendingClass;
    });
  }

  void _nextPageClass() {
    setState(() {
      if (currentPageClass * itemsPerPageClass < filteredClass.length) {
        currentPageClass++;
      }
    });
  }

  void _previousPageClass() {
    setState(() {
      if (currentPageClass > 1) {
        currentPageClass--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    int startIndexClass = (currentPageClass - 1) * itemsPerPageClass;
    int endIndexClass = startIndexClass + itemsPerPageClass;

    List<ClassFirebase> paginetedClass = filteredClass.sublist(
        startIndexClass,
        endIndexClass > filteredClass.length
            ? filteredClass.length
            : endIndexClass);

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
                      paginetedClass: paginetedClass,
                      listSubject: listSubject,
                      sortTitleByName: _sortClassByName,
                      isAscending: isAscendingClass,
                      itemsPerPage: itemsPerPageClass,
                      currentPage: currentPageClass,
                      filteredClass: filteredClass,
                      previousPage: _previousPageClass,
                      nextPage: _nextPageClass,
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
