import 'package:flutter/material.dart';
import 'package:university/components/app_bar_secretary_component.dart';
import 'package:university/components/card_count.dart';
import 'package:university/components/drawer_secretary_component.dart';
import 'package:university/components/footer.dart';
import 'package:university/components/list_teacher_card.dart';
import 'package:university/core/models/user_firebase.dart';
import 'package:university/services/auth_service.dart';
import 'package:university/services/users_service.dart';

class DashboardSecretaryPage extends StatefulWidget {
  const DashboardSecretaryPage({super.key});

  @override
  State<DashboardSecretaryPage> createState() => _DashboardSecretaryPageState();
}

class _DashboardSecretaryPageState extends State<DashboardSecretaryPage> {
  List<UserFirebase> teachers = [];
  List<UserFirebase> activeTeachers = [];
  List<UserFirebase> activeStudent = [];

  List<UserFirebase> filteredTeachers = [];
  TextEditingController searchController = TextEditingController();
  bool isAscending = true; // Para controle de ordenação

  int currentPage = 1;
  int itemsPerPage = 5;

  @override
  void initState() {
    super.initState();
    _loadTeachers();

    // Adiciona um listener para o TextEditingController
    searchController.addListener(() {
      filterTeachers();
    });
  }

  Future<void> _loadTeachers() async {
    try {
      Map<String, List<UserFirebase>> fetchedUsers =
          await UsersService().getAllUsers();
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
      });
    } catch (e) {
      // print('Erro ao carregar professores: $e');
    }
  }

  void filterTeachers() {
    setState(() {
      filteredTeachers = teachers.where((teacher) {
        return teacher.name
                .toLowerCase()
                .contains(searchController.text.toLowerCase()) ||
            teacher.email
                .toLowerCase()
                .contains(searchController.text.toLowerCase());
      }).toList();
    });
  }

  void _sortTeachersByName() {
    setState(() {
      filteredTeachers.sort((a, b) {
        if (isAscending) {
          return a.name.compareTo(b.name);
        } else {
          return b.name.compareTo(a.name);
        }
      });
      isAscending = !isAscending; // Alterna a direção da ordenação
    });
  }

  void _nextPage() {
    setState(() {
      if (currentPage * itemsPerPage < filteredTeachers.length) {
        currentPage++;
      }
    });
  }

  void _previousPage() {
    setState(() {
      if (currentPage > 1) {
        currentPage--;
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    teachers.clear();
    searchController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int startIndex = (currentPage - 1) * itemsPerPage;
    int endIndex = startIndex + itemsPerPage;
    List<UserFirebase> paginatedTeachers = filteredTeachers.sublist(
      startIndex,
      endIndex > filteredTeachers.length ? filteredTeachers.length : endIndex,
    );

    return Scaffold(
      appBar: appBarSecretaryComponent(name: AuthService().currentUser?.name),
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
                              countTeacher: activeTeachers.length.toString()),
                        )
                      : SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: cardBuild(
                                countStudent: activeStudent.length.toString(),
                                countTeacher: activeTeachers.length.toString()),
                          ),
                        ),
                ),
                ListTeacherCard(
                  isSmallScreen: isSmallScreen,
                  searchController: searchController,
                  paginatedTeachers: paginatedTeachers,
                  sortTeachersByName: _sortTeachersByName,
                  isAscending: isAscending,
                  previousPage: _previousPage,
                  currentPage: currentPage,
                  filteredTeachers: filteredTeachers,
                  itemsPerPage: itemsPerPage,
                  nextPage: _nextPage,
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

List<Widget> cardBuild(
    {required String countStudent, required String countTeacher}) {
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
    const CardCount(
      count: '16',
      typeCount: 'Turmas Ativas',
      color: Colors.pinkAccent,
    ),
  ];
}
