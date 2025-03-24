import 'package:flutter/material.dart';
import 'package:university/components/app_bar_user_component.dart';
import 'package:university/components/card_subject.dart';
import 'package:university/components/footer.dart';
import 'package:university/components/list_class_teacher.dart';
import 'package:university/core/models/class_firebase.dart';
import 'package:university/core/models/subject_module.dart';
import 'package:university/core/services/auth_user_service.dart';
import 'package:university/core/services/class_service.dart';
import 'package:university/core/services/subject_service.dart';

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

    List<ClassFirebase> paginatedClass = filteredClass.sublist(
        startIndexClass,
        endIndexClass > filteredClass.length
            ? filteredClass.length
            : endIndexClass);

    return Scaffold(
      appBar: appBarUserComponent(userFirebase: AuthUserService().currentUser),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 15),
                  const Text(
                    'Minhas Matérias',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  listClass.isEmpty
                      ? const Text(
                          "Não possuo matéria, peça ao secretário para adicionar sua matéria",
                          style: TextStyle(fontSize: 14),
                        )
                      : LayoutBuilder(
                          builder: (context, constraints) {
                            bool isSmallScreen = constraints.maxWidth < 800;
                            return isSmallScreen
                                ? Column(
                                    children: listSubject
                                        .map((subject) => CardSubject(
                                              subjectModule: subject,
                                              classFirebase: listClass,
                                            ))
                                        .toList(),
                                  )
                                : Wrap(
                                    spacing: 10.0,
                                    runSpacing: 10.0,
                                    alignment: WrapAlignment.center,
                                    children: listSubject
                                        .map((subject) => CardSubject(
                                              subjectModule: subject,
                                              classFirebase: listClass,
                                            ))
                                        .toList(),
                                  );
                          },
                        ),
                  const SizedBox(height: 15),
                  ListClassTeacher(
                    isSmallScreen: MediaQuery.of(context).size.width < 800,
                    searchController: searchController,
                    paginetedClass: paginatedClass,
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
            const Footer(), // Footer sempre no final
          ],
        ),
      ),
    );
  }
}
