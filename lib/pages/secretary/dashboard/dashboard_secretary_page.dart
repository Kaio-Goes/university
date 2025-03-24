import 'package:flutter/material.dart';
import 'package:university/components/app_bar_user_component.dart';
import 'package:university/components/card_count.dart';
import 'package:university/components/card_module_component.dart';
import 'package:university/components/drawer_secretary_component.dart';
import 'package:university/components/footer.dart';
import 'package:university/components/list_class.dart';
import 'package:university/components/list_users_card.dart';
import 'package:university/core/models/class_firebase.dart';
import 'package:university/core/models/subject_module.dart';
import 'package:university/core/models/user_firebase.dart';
import 'package:university/core/services/class_service.dart';
import 'package:university/core/services/subject_service.dart';
import 'package:university/core/services/auth_user_service.dart';

class DashboardSecretaryPage extends StatefulWidget {
  const DashboardSecretaryPage({super.key});

  @override
  State<DashboardSecretaryPage> createState() => _DashboardSecretaryPageState();
}

class _DashboardSecretaryPageState extends State<DashboardSecretaryPage> {
  List<UserFirebase> teachers = [];
  List<UserFirebase> students = [];
  List<ClassFirebase> classe = [];
  List<UserFirebase> activeTeachers = [];
  List<UserFirebase> activeStudent = [];
  List<ClassFirebase> loadClass = [];

  List<SubjectModule> subjectModule1 = [];
  List<SubjectModule> subjectModule2 = [];
  List<SubjectModule> subjectModule3 = [];

  List<UserFirebase> filteredTeachers = [];
  List<UserFirebase> filteredStudents = [];
  List<ClassFirebase> filteredClass = [];

  TextEditingController searchTeachersController = TextEditingController();
  TextEditingController searchStudentsController = TextEditingController();
  TextEditingController searchClassController = TextEditingController();

  bool isAscendingStudent = true; // Para controle de ordenação
  bool isAscendingTeachers = true;
  bool isAscendingClass = true;

  int currentPageTeacher = 1;
  int itemsPerPageTeacher = 5;
  int currentPageStudent = 1;
  int itemsPerPageStudent = 5;

  int currentPageClass = 1;
  int itemsPerPageClass = 5;

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _loadClass();
    // Adiciona um listener para o TextEditingController
    searchTeachersController.addListener(() {
      filterTeachers();
    });

    searchStudentsController.addListener(() {
      filterStudent();
    });

    searchClassController.addListener(() {
      filterClass();
    });
  }

  Future<void> _loadUsers() async {
    try {
      await AuthUserService().loadUserFromCache();

      Map<String, List<UserFirebase>> fetchedUsers =
          await AuthUserService().getAllUsers();

      List<SubjectModule> fetchedSubjectModule =
          await SubjectService().getAllSubjectModule();

      subjectModule1 = fetchedSubjectModule
          .where((subject) => subject.module == '1')
          .toList();

      subjectModule2 = fetchedSubjectModule
          .where((subject) => subject.module == '2')
          .toList();

      subjectModule3 = fetchedSubjectModule
          .where((subject) => subject.module == '3')
          .toList();

      List<UserFirebase> fetchedTeachers = fetchedUsers['teachers'] ?? [];
      List<UserFirebase> fetchedStudents =
          fetchedUsers['students']?.cast<UserFirebase>() ?? [];

      activeTeachers =
          fetchedTeachers.where((teacher) => teacher.isActive).toList();
      activeStudent =
          fetchedStudents.where((student) => student.isActive).toList();
      setState(() {
        teachers = fetchedTeachers;
        filteredTeachers = teachers; // Inicialmente mostra todos
        students = fetchedStudents;
        filteredStudents = students;
      });
    } catch (e) {
      Exception('Erro ao carregar professores: $e');
    }
  }

  Future _loadClass() async {
    try {
      List<ClassFirebase> loadedClass =
          await ClassService().getAllClassFirebase();
      setState(() {
        loadClass = loadedClass;
        classe = loadedClass;
        filteredClass = classe;
      });
    } catch (e) {
      Exception("Erro a buscar as classes");
    }
  }

  void filterTeachers() {
    setState(() {
      filteredTeachers = teachers.where((teacher) {
        return teacher.name
                .toLowerCase()
                .contains(searchTeachersController.text.toLowerCase()) ||
            teacher.email
                .toLowerCase()
                .contains(searchTeachersController.text.toLowerCase());
      }).toList();
    });
  }

  void filterStudent() {
    setState(() {
      filteredStudents = students.where((student) {
        return student.name
                .toLowerCase()
                .contains(searchStudentsController.text.toLowerCase()) ||
            student.email
                .toLowerCase()
                .contains(searchStudentsController.text.toLowerCase());
      }).toList();
    });
  }

  void filterClass() {
    setState(() {
      filteredClass = classe.where((classe) {
        return classe.name
            .toLowerCase()
            .contains(searchClassController.text.toLowerCase());
      }).toList();
    });
  }

  void _sortTeachersByName() {
    setState(() {
      filteredTeachers.sort((a, b) {
        if (isAscendingTeachers) {
          return a.name.compareTo(b.name);
        } else {
          return b.name.compareTo(a.name);
        }
      });
      isAscendingTeachers =
          !isAscendingTeachers; // Alterna a direção da ordenação
    });
  }

  void _sortStudentsByName() {
    setState(() {
      filteredStudents.sort((a, b) {
        if (isAscendingStudent) {
          return a.name.compareTo(b.name);
        } else {
          return b.name.compareTo(a.name);
        }
      });
      isAscendingStudent =
          !isAscendingStudent; // Alterna a direção da ordenação
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

  void _nextPage() {
    setState(() {
      if (currentPageTeacher * itemsPerPageTeacher < filteredTeachers.length) {
        currentPageTeacher++;
      }
    });
  }

  void _nextPageStudent() {
    setState(() {
      if (currentPageStudent * itemsPerPageStudent < filteredStudents.length) {
        currentPageStudent++;
      }
    });
  }

  void _nextPageClass() {
    setState(() {
      if (currentPageClass * itemsPerPageClass < filteredClass.length) {
        currentPageClass++;
      }
    });
  }

  void _previousPageTeacher() {
    setState(() {
      if (currentPageTeacher > 1) {
        currentPageTeacher--;
      }
    });
  }

  void _previousPageStudent() {
    setState(() {
      if (currentPageStudent > 1) {
        currentPageStudent--;
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
  void dispose() {
    super.dispose();
    teachers.clear();
    searchTeachersController.dispose();
    searchStudentsController.dispose();
    searchClassController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int startIndexTeacher = (currentPageTeacher - 1) * itemsPerPageTeacher;
    int endIndexTeacher = startIndexTeacher + itemsPerPageTeacher;
    int startIndexStudent = (currentPageStudent - 1) * itemsPerPageStudent;
    int endIndexStudent = startIndexStudent + itemsPerPageStudent;

    int startIndexClass = (currentPageClass - 1) * itemsPerPageClass;
    int endIndexClass = startIndexClass + itemsPerPageClass;

    List<UserFirebase> paginatedTeachers = filteredTeachers.sublist(
      startIndexTeacher,
      endIndexTeacher > filteredTeachers.length
          ? filteredTeachers.length
          : endIndexTeacher,
    );

    List<UserFirebase> paginatedStudants = filteredStudents.sublist(
      startIndexStudent,
      endIndexStudent > filteredStudents.length
          ? filteredStudents.length
          : endIndexStudent,
    );

    List<ClassFirebase> paginetedClass = filteredClass.sublist(
        startIndexClass,
        endIndexClass > filteredClass.length
            ? filteredClass.length
            : endIndexClass);

    return Scaffold(
      appBar: appBarUserComponent(userFirebase: AuthUserService().currentUser),
      drawer: const DrawerSecretaryComponent(),
      body: SingleChildScrollView(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            bool isSmallScreen = constraints.maxWidth < 800;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: isSmallScreen
                      ? Column(
                          children: cardBuild(
                            countStudent: activeStudent.length.toString(),
                            countTeacher: activeTeachers.length.toString(),
                            countClass: loadClass.length.toString(),
                          ),
                        )
                      : SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: cardBuild(
                              countStudent: activeStudent.length.toString(),
                              countTeacher: activeTeachers.length.toString(),
                              countClass: loadClass.length.toString(),
                            ),
                          ),
                        ),
                ),
                ListClass(
                  isSmallScreen: isSmallScreen,
                  searchController: searchClassController,
                  paginetedClass: paginetedClass,
                  sortTeachersByName: _sortClassByName,
                  isAscending: isAscendingClass,
                  filteredClass: filteredClass,
                  currentPage: currentPageClass,
                  itemsPerPage: itemsPerPageClass,
                  previousPage: _previousPageClass,
                  nextPage: _nextPageClass,
                ),
                Padding(
                  padding: const EdgeInsets.all(2),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CardModuleComponent(
                          isSmallScreen: isSmallScreen,
                          userTeacher: activeTeachers,
                          title: 'Módulo 1',
                          subjectModule: subjectModule1,
                        ),
                        const SizedBox(width: 10),
                        CardModuleComponent(
                          isSmallScreen: isSmallScreen,
                          userTeacher: activeTeachers,
                          title: 'Módulo 2',
                          subjectModule: subjectModule2,
                        ),
                        const SizedBox(width: 10),
                        CardModuleComponent(
                          isSmallScreen: isSmallScreen,
                          userTeacher: activeTeachers,
                          title: 'Módulo 3',
                          subjectModule: subjectModule3,
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ListUsersCard(
                  isSmallScreen: isSmallScreen,
                  title: 'Lista de Professores',
                  searchController: searchTeachersController,
                  paginetedUsers: paginatedTeachers,
                  sortTeachersByName: _sortTeachersByName,
                  isAscending: isAscendingTeachers,
                  previousPage: _previousPageTeacher,
                  currentPage: currentPageTeacher,
                  filteredUsers: filteredTeachers,
                  itemsPerPage: itemsPerPageTeacher,
                  nextPage: _nextPage,
                ),
                const SizedBox(height: 40),
                ListUsersCard(
                  isSmallScreen: isSmallScreen,
                  title: 'Lista de Alunos',
                  searchController: searchStudentsController,
                  paginetedUsers: paginatedStudants,
                  sortTeachersByName: _sortStudentsByName,
                  isAscending: isAscendingStudent,
                  previousPage: _previousPageStudent,
                  currentPage: currentPageStudent,
                  filteredUsers: filteredStudents,
                  itemsPerPage: itemsPerPageStudent,
                  nextPage: _nextPageStudent,
                ),
                const SizedBox(height: 15),
                const Footer()
              ],
            );
          },
        ),
      ),
    );
  }
}

List<Widget> cardBuild({
  required String countStudent,
  required String countTeacher,
  required String countClass,
}) {
  return [
    CardCount(
      count: countStudent,
      typeCount: 'Alunos Ativos',
      color: Colors.blue,
    ),
    const SizedBox(width: 15, height: 15),
    CardCount(
      count: countTeacher,
      typeCount: 'Professores Ativos',
      color: Colors.purple,
    ),
    const SizedBox(width: 15, height: 15),
    CardCount(
      count: countClass,
      typeCount: 'Turmas Ativas',
      color: Colors.pinkAccent,
    ),
  ];
}
