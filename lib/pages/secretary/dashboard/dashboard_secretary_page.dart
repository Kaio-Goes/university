import 'package:flutter/material.dart';
import 'package:university/components/app_bar_secretary_component.dart';
import 'package:university/components/card_count.dart';
import 'package:university/components/drawer_secretary_component.dart';
import 'package:university/components/footer.dart';
import 'package:university/core/models/user_teacher.dart';
import 'package:university/core/utilities/styles.constants.dart';
import 'package:university/services/auth_service.dart';
import 'package:university/services/teacher_service.dart';

class DashboardSecretaryPage extends StatefulWidget {
  const DashboardSecretaryPage({super.key});

  @override
  State<DashboardSecretaryPage> createState() => _DashboardSecretaryPageState();
}

class _DashboardSecretaryPageState extends State<DashboardSecretaryPage> {
  List<UserTeacher> teachers = [];
  List<UserTeacher> activeTeachers = [];
  List<UserTeacher> filteredTeachers = [];
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
      List<UserTeacher> fetchedTeachers =
          await TeacherService().getAllTeacher();
      activeTeachers =
          fetchedTeachers.where((teacher) => teacher.isActive).toList();
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
    List<UserTeacher> paginatedTeachers = filteredTeachers.sublist(
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
                              countTeacher: activeTeachers.length.toString()),
                        )
                      : SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: cardBuild(
                                countTeacher: activeTeachers.length.toString()),
                          ),
                        ),
                ),
                Card(
                  elevation: 8,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.85,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Lista de Professores',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(
                                width: isSmallScreen
                                    ? MediaQuery.of(context).size.width * 0.4
                                    : MediaQuery.of(context).size.width * 0.3,
                                child: TextField(
                                  controller: searchController,
                                  decoration: const InputDecoration(
                                    labelText: 'Pesquisar por nome ou email',
                                    prefixIcon: Icon(Icons.search),
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          isSmallScreen
                              ? Column(
                                  children: paginatedTeachers.map((teacher) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                '${teacher.name} ${teacher.surname}',
                                                style: textFontBold,
                                              ),
                                              IconButton(
                                                onPressed: () {},
                                                icon:
                                                    const Icon(Icons.more_vert),
                                              ),
                                            ],
                                          ),
                                          Text('Email: ${teacher.email}'),
                                          Text('CPF: ${teacher.cpf}'),
                                          Text('Telefone: ${teacher.phone}'),
                                          Text(
                                            'Status: ${teacher.isActive ? "Ativo" : "Desativado"}',
                                          ),
                                          const Divider(),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                )
                              : Table(
                                  columnWidths: const {
                                    0: FlexColumnWidth(2),
                                    1: FlexColumnWidth(3),
                                    2: FlexColumnWidth(2),
                                    3: FlexColumnWidth(2),
                                    4: FlexColumnWidth(1),
                                    5: FixedColumnWidth(50),
                                  },
                                  children: [
                                    TableRow(
                                      children: [
                                        GestureDetector(
                                          onTap: _sortTeachersByName,
                                          child: Row(
                                            children: [
                                              const Padding(
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 8.0),
                                                child: Text('Nome',
                                                    style: textFontBold),
                                              ),
                                              Icon(
                                                isAscending
                                                    ? Icons.arrow_upward
                                                    : Icons.arrow_downward,
                                                size: 16,
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 8.0),
                                          child: Text('Email',
                                              style: textFontBold),
                                        ),
                                        const Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 8.0),
                                          child:
                                              Text('CPF', style: textFontBold),
                                        ),
                                        const Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 8.0),
                                          child: Text('Telefone',
                                              style: textFontBold),
                                        ),
                                        const Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 8.0),
                                          child: Text('Status',
                                              style: textFontBold),
                                        ),
                                        const Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 8.0),
                                          child: Text('Editar',
                                              style: textFontBold,
                                              textAlign: TextAlign.center),
                                        ),
                                      ],
                                    ),
                                    for (var teacher in paginatedTeachers) ...[
                                      TableRow(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 8.0),
                                            child: Text(
                                                '${teacher.name} ${teacher.surname}'),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 8.0),
                                            child: Text(teacher.email),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 8.0),
                                            child: Text(teacher.cpf),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 8.0),
                                            child: Text(teacher.phone),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 8.0),
                                            child: Text(teacher.isActive
                                                ? "Ativo"
                                                : "Desativado"),
                                          ),
                                          Center(
                                            child: IconButton(
                                              onPressed: () {},
                                              icon: const Icon(Icons.more_vert),
                                            ),
                                          ),
                                        ],
                                      ),
                                      TableRow(
                                        children: List.generate(
                                          6,
                                          (_) => const Padding(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 8.0),
                                            child: Divider(),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                onPressed: _previousPage,
                                icon: const Icon(Icons.arrow_back),
                                color: currentPage > 1
                                    ? Colors.black
                                    : Colors.grey,
                              ),
                              Text(
                                  '$currentPage/${(filteredTeachers.length / itemsPerPage).ceil()}'),
                              IconButton(
                                onPressed: _nextPage,
                                icon: const Icon(Icons.arrow_forward),
                                color: currentPage * itemsPerPage <
                                        filteredTeachers.length
                                    ? Colors.black
                                    : Colors.grey,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
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

List<Widget> cardBuild({required String countTeacher}) {
  return [
    const CardCount(
      count: '16',
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
