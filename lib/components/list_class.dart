import 'package:flutter/material.dart';
import 'package:university/core/models/class_firebase.dart';
import 'package:university/core/models/user_firebase.dart';
import 'package:university/core/models/subject_module.dart';
import 'package:university/core/services/auth_user_service.dart';
import 'package:university/core/utilities/alerts.dart';
import 'package:university/core/utilities/styles.constants.dart';
import 'package:university/pages/secretary/classe/class_create_page.dart';
import 'package:university/pages/secretary/classe/notes_class_page.dart';
import 'package:university/pages/secretary/dashboard/dashboard_secretary_page.dart';
import 'package:university/core/services/class_service.dart';
import 'package:university/core/services/subject_service.dart';
import 'package:university/pages/secretary/student/student_create_page.dart';

// --- NOVO WIDGET: _StudentExpansionPanel ---
class _StudentExpansionPanel extends StatelessWidget {
  final List<String> studentUids;
  final TextEditingController searchController;
  final String currentSearchTerm;
  final Function(List<String>) fetchStudents;
  final Function(UserFirebase) buildStudentRow;

  const _StudentExpansionPanel({
    required this.studentUids,
    required this.searchController,
    required this.currentSearchTerm,
    required this.fetchStudents,
    required this.buildStudentRow,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: searchController,
          decoration: const InputDecoration(
            labelText: 'Pesquisar Aluno',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          ),
        ),
        const SizedBox(height: 10),
        FutureBuilder<List<UserFirebase>>(
          future: fetchStudents(studentUids),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Row(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 8),
                  Text('Carregando alunos...'),
                ],
              );
            } else if (snapshot.hasError) {
              return Text('Erro ao carregar alunos: ${snapshot.error}');
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Text('Nenhum aluno associado.');
            } else {
              final students = snapshot.data!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Alunos:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  ...students.map((student) => buildStudentRow(student)),
                ],
              );
            }
          },
        ),
      ],
    );
  }
}

// --- NOVO WIDGET: _SubjectExpansionPanel ---
class _SubjectExpansionPanel extends StatelessWidget {
  final List<String> subjectUids;
  final TextEditingController searchController;
  final String currentSearchTerm;
  final Function(List<String>) fetchSubjects;
  final Function(SubjectModule) buildSubjectRow;

  const _SubjectExpansionPanel({
    required this.subjectUids,
    required this.searchController,
    required this.currentSearchTerm,
    required this.fetchSubjects,
    required this.buildSubjectRow,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: searchController,
          decoration: const InputDecoration(
            labelText: 'Pesquisar Matéria',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          ),
        ),
        const SizedBox(height: 10),
        FutureBuilder<List<SubjectModule>>(
          future: fetchSubjects(subjectUids),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Row(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 8),
                  Text('Carregando matérias...'),
                ],
              );
            } else if (snapshot.hasError) {
              return Text('Erro ao carregar matérias: ${snapshot.error}');
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Text('Nenhuma matéria associada.');
            } else {
              final subjects = snapshot.data!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Matérias:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  ...subjects.map((subject) => buildSubjectRow(subject)),
                ],
              );
            }
          },
        ),
      ],
    );
  }
}

// --- ListClass REFACTORADA (com expansão simultânea) ---
class ListClass extends StatefulWidget {
  final bool isSmallScreen;
  final TextEditingController searchController;
  final List<ClassFirebase> paginetedClass;
  final Function() sortTeachersByName;
  final bool isAscending;
  final Function() previousPage;
  final int currentPage;
  final List<ClassFirebase> filteredClass;
  final int itemsPerPage;
  final Function() nextPage;

  const ListClass({
    super.key,
    required this.isSmallScreen,
    required this.searchController,
    required this.paginetedClass,
    required this.sortTeachersByName,
    required this.isAscending,
    required this.previousPage,
    required this.currentPage,
    required this.filteredClass,
    required this.itemsPerPage,
    required this.nextPage,
  });

  @override
  State<ListClass> createState() => _ListClassState();
}

class _ListClassState extends State<ListClass> {
  // Alterado para Set<String> para permitir múltiplas expansões
  Set<String> _expandedClassIds = {}; // Para painéis de alunos
  Set<String> _expandedSubjectForClassIds = {}; // Para painéis de matérias

  final Map<String, List<UserFirebase>> _cachedStudents = {};
  final Map<String, List<SubjectModule>> _cachedSubjects = {};

  final TextEditingController _studentSearchController =
      TextEditingController();
  String _currentStudentSearchTerm = '';

  final TextEditingController _subjectSearchController =
      TextEditingController();
  String _currentSubjectSearchTerm = '';

  @override
  void initState() {
    super.initState();
    _studentSearchController.addListener(_onStudentSearchChanged);
    _subjectSearchController.addListener(_onSubjectSearchChanged);
  }

  @override
  void dispose() {
    _studentSearchController.removeListener(_onStudentSearchChanged);
    _studentSearchController.dispose();
    _subjectSearchController.removeListener(_onSubjectSearchChanged);
    _subjectSearchController.dispose();
    super.dispose();
  }

  void _onStudentSearchChanged() {
    setState(() {
      _currentStudentSearchTerm = _studentSearchController.text;
    });
  }

  void _onSubjectSearchChanged() {
    setState(() {
      _currentSubjectSearchTerm = _subjectSearchController.text;
    });
  }

  Future<List<UserFirebase>> _fetchStudentsForClass(
      List<String> studentUids) async {
    if (studentUids.isEmpty) {
      return [];
    }
    final sortedUids = List<String>.from(studentUids)..sort();
    final cacheKey = sortedUids.join(',');

    if (_cachedStudents.containsKey(cacheKey)) {
      var students = _cachedStudents[cacheKey]!;
      return _filterStudents(students);
    }

    try {
      var studentsDetails =
          await AuthUserService().getUsersByUids(uids: studentUids);
      studentsDetails.sort((a, b) => a.name.compareTo(b.name));
      _cachedStudents[cacheKey] = studentsDetails;
      return _filterStudents(studentsDetails);
    } catch (e) {
      print('Erro ao buscar alunos para a turma: $e');
      return [];
    }
  }

  List<UserFirebase> _filterStudents(List<UserFirebase> students) {
    if (_currentStudentSearchTerm.isEmpty) {
      return students;
    }
    final lowerCaseSearchTerm = _currentStudentSearchTerm.toLowerCase();
    return students.where((student) {
      return student.name.toLowerCase().contains(lowerCaseSearchTerm) ||
          student.email.toLowerCase().contains(lowerCaseSearchTerm) ||
          student.cpf.contains(lowerCaseSearchTerm);
    }).toList();
  }

  Future<List<SubjectModule>> _fetchSubjectsForClass(
      List<String> subjectUids) async {
    if (subjectUids.isEmpty) {
      return [];
    }
    final sortedUids = List<String>.from(subjectUids)..sort();
    final cacheKey = sortedUids.join(',');

    if (_cachedSubjects.containsKey(cacheKey)) {
      var subjects = _cachedSubjects[cacheKey]!;
      return _filterSubjects(subjects);
    }

    try {
      var subjectsDetails =
          await SubjectService().getSubjectsByUids(uids: subjectUids);
      subjectsDetails.sort((a, b) => a.title.compareTo(b.title));
      _cachedSubjects[cacheKey] = subjectsDetails;
      return _filterSubjects(subjectsDetails);
    } catch (e) {
      print('Erro ao buscar matérias para a turma: $e');
      return [];
    }
  }

  List<SubjectModule> _filterSubjects(List<SubjectModule> subjects) {
    if (_currentSubjectSearchTerm.isEmpty) {
      return subjects;
    }
    final lowerCaseSearchTerm = _currentSubjectSearchTerm.toLowerCase();
    return subjects.where((subject) {
      return subject.title.toLowerCase().contains(lowerCaseSearchTerm);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.85,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 10),
              widget.isSmallScreen
                  ? _buildSmallScreenClassList()
                  : _buildLargeScreenClassTable(),
              _buildPaginationControls(),
            ],
          ),
        ),
      ),
    );
  }

  // --- Métodos de Construção de UI Fatorados ---

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Lista de Turmas',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(
          width: widget.isSmallScreen
              ? MediaQuery.of(context).size.width * 0.4
              : MediaQuery.of(context).size.width * 0.3,
          child: TextField(
            controller: widget.searchController,
            decoration: const InputDecoration(
              labelText: 'Pesquisar por Turma',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSmallScreenClassList() {
    return Column(
      children: widget.paginetedClass.map((classe) {
        // Verifica se a turma está no conjunto de IDs expandidos
        final isStudentsExpanded = _expandedClassIds.contains(classe.uid);
        final isSubjectsExpanded =
            _expandedSubjectForClassIds.contains(classe.uid);

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: InkWell(
            onTap: () {
              // A expansão da turma principal (nome/datas) é independente dos sub-painéis
              // Apenas limpa as pesquisas ao expandir/recolher a turma principal
              setState(() {
                if (_expandedClassIds.contains(classe.uid) ||
                    _expandedSubjectForClassIds.contains(classe.uid)) {
                  _expandedClassIds.remove(classe.uid);
                  _expandedSubjectForClassIds.remove(classe.uid);
                } else {
                  // Ação padrão ao clicar na turma: expandir alunos
                  _expandedClassIds.add(classe.uid);
                }
                _studentSearchController.clear();
                _currentStudentSearchTerm = '';
                _subjectSearchController.clear();
                _currentSubjectSearchTerm = '';
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        classe.name,
                        style: textFontBold,
                      ),
                      Icon(
                        isStudentsExpanded || isSubjectsExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                      ),
                    ],
                  ),
                  Text('Data de Início: ${classe.startDate}'),
                  Text('Data final: ${classe.endDate}'),
                  _buildStudentsSectionSmallScreen(classe, isStudentsExpanded),
                  _buildSubjectsSectionSmallScreen(classe, isSubjectsExpanded),
                  _buildClassActions(classe),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLargeScreenClassTable() {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(3),
        1: FlexColumnWidth(2),
        2: FlexColumnWidth(2),
        3: FlexColumnWidth(5),
        4: FlexColumnWidth(4),
        5: FixedColumnWidth(70),
      },
      border: TableBorder.symmetric(
          inside: BorderSide(color: Colors.grey.shade300)),
      children: [
        _buildTableHeader(),
        for (var classe in widget.paginetedClass) _buildClassTableRow(classe),
      ],
    );
  }

  TableRow _buildTableHeader() {
    return TableRow(
      decoration: BoxDecoration(color: Colors.grey.shade100),
      children: [
        GestureDetector(
          onTap: widget.sortTeachersByName,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                const Text('Turma', style: textFontBold),
                Icon(
                  widget.isAscending
                      ? Icons.arrow_upward
                      : Icons.arrow_downward,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.all(12.0),
          child: Text('Data de Início', style: textFontBold),
        ),
        const Padding(
          padding: EdgeInsets.all(12.0),
          child: Text('Data Final', style: textFontBold),
        ),
        const Padding(
          padding: EdgeInsets.all(12.0),
          child: Text('Total de Alunos', style: textFontBold),
        ),
        const Padding(
          padding: EdgeInsets.all(12.0),
          child: Text('Total de Matérias', style: textFontBold),
        ),
        const Padding(
          padding: EdgeInsets.all(12.0),
          child:
              Text('Ações', style: textFontBold, textAlign: TextAlign.center),
        ),
      ],
    );
  }

  TableRow _buildClassTableRow(ClassFirebase classe) {
    // Verifica se a turma está no conjunto de IDs expandidos para colorir a linha
    final isAnyExpanded = _expandedClassIds.contains(classe.uid) ||
        _expandedSubjectForClassIds.contains(classe.uid);

    return TableRow(
      decoration: BoxDecoration(
        color: isAnyExpanded ? Colors.blue.shade50 : Colors.transparent,
      ),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
          child: Text(classe.name),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
          child: Text(classe.startDate),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
          child: Text(classe.endDate),
        ),
        _buildStudentsSectionLargeScreen(classe),
        _buildSubjectsSectionLargeScreen(classe),
        _buildClassActions(classe),
      ],
    );
  }

  Widget _buildPaginationControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        IconButton(
          onPressed: widget.previousPage,
          icon: const Icon(Icons.arrow_back),
          color: widget.currentPage > 1 ? Colors.black : Colors.grey,
        ),
        Text(
            '${widget.currentPage}/${(widget.filteredClass.length / widget.itemsPerPage).ceil()}'),
        IconButton(
          onPressed: widget.nextPage,
          icon: const Icon(Icons.arrow_forward),
          color: widget.currentPage * widget.itemsPerPage <
                  widget.filteredClass.length
              ? Colors.black
              : Colors.grey,
        ),
      ],
    );
  }

  // Seções de Alunos (para Small e Large Screen)
  Widget _buildStudentsSectionSmallScreen(
      ClassFirebase classe, bool isStudentsExpanded) {
    return InkWell(
      onTap: () {
        setState(() {
          if (_expandedClassIds.contains(classe.uid)) {
            _expandedClassIds.remove(classe.uid);
          } else {
            _expandedClassIds.add(classe.uid);
          }
          _studentSearchController
              .clear(); // Limpa a pesquisa ao expandir/recolher
          _currentStudentSearchTerm = '';
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total de Alunos: ${classe.students.length}'),
                Icon(
                  isStudentsExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  size: 16,
                ),
              ],
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: _StudentExpansionPanel(
                  studentUids: classe.students.cast<String>(),
                  searchController: _studentSearchController,
                  currentSearchTerm: _currentStudentSearchTerm,
                  fetchStudents: _fetchStudentsForClass,
                  buildStudentRow: _buildStudentRowSmallScreen,
                ),
              ),
              crossFadeState: isStudentsExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentsSectionLargeScreen(ClassFirebase classe) {
    final isExpanded = _expandedClassIds.contains(classe.uid);
    return InkWell(
      onTap: () {
        setState(() {
          if (_expandedClassIds.contains(classe.uid)) {
            _expandedClassIds.remove(classe.uid);
          } else {
            _expandedClassIds.add(classe.uid);
          }
          _studentSearchController
              .clear(); // Limpa a pesquisa ao expandir/recolher
          _currentStudentSearchTerm = '';
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(classe.students.length.toString()),
                Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  size: 16,
                ),
              ],
            ),
            if (isExpanded)
              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: _StudentExpansionPanel(
                    studentUids: classe.students.cast<String>(),
                    searchController: _studentSearchController,
                    currentSearchTerm: _currentStudentSearchTerm,
                    fetchStudents: _fetchStudentsForClass,
                    buildStudentRow: _buildStudentRowLargeScreen,
                  ),
                ),
                crossFadeState: isExpanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 300),
              ),
          ],
        ),
      ),
    );
  }

  // Seções de Matérias (para Small e Large Screen)
  Widget _buildSubjectsSectionSmallScreen(
      ClassFirebase classe, bool isSubjectsExpanded) {
    return InkWell(
      onTap: () {
        setState(() {
          if (_expandedSubjectForClassIds.contains(classe.uid)) {
            _expandedSubjectForClassIds.remove(classe.uid);
          } else {
            _expandedSubjectForClassIds.add(classe.uid);
          }
          _subjectSearchController
              .clear(); // Limpa a pesquisa ao expandir/recolher
          _currentSubjectSearchTerm = '';
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total de Matérias: ${classe.subject.length}'),
                Icon(
                  isSubjectsExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  size: 16,
                ),
              ],
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: _SubjectExpansionPanel(
                  subjectUids: classe.subject.cast<String>(),
                  searchController: _subjectSearchController,
                  currentSearchTerm: _currentSubjectSearchTerm,
                  fetchSubjects: _fetchSubjectsForClass,
                  buildSubjectRow: _buildSubjectRowSmallScreen,
                ),
              ),
              crossFadeState: isSubjectsExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectsSectionLargeScreen(ClassFirebase classe) {
    final isSubjectsExpanded = _expandedSubjectForClassIds.contains(classe.uid);
    return InkWell(
      onTap: () {
        setState(() {
          if (_expandedSubjectForClassIds.contains(classe.uid)) {
            _expandedSubjectForClassIds.remove(classe.uid);
          } else {
            _expandedSubjectForClassIds.add(classe.uid);
          }
          _subjectSearchController
              .clear(); // Limpa a pesquisa ao expandir/recolher
          _currentSubjectSearchTerm = '';
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(classe.subject.length.toString()),
                Icon(
                  isSubjectsExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  size: 16,
                ),
              ],
            ),
            if (isSubjectsExpanded)
              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: _SubjectExpansionPanel(
                    subjectUids: classe.subject.cast<String>(),
                    searchController: _subjectSearchController,
                    currentSearchTerm: _currentSubjectSearchTerm,
                    fetchSubjects: _fetchSubjectsForClass,
                    buildSubjectRow: _buildSubjectRowLargeScreen,
                  ),
                ),
                crossFadeState: isSubjectsExpanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 300),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildClassActions(ClassFirebase classe) {
    return Center(
      child: PopupMenuButton<String>(
        icon: const Icon(Icons.more_vert),
        onSelected: (String result) {
          if (result == 'Edit') {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ClassCreatePage(
                  classFirebase: classe,
                ),
              ),
            );
          } else if (result == 'delete') {
            showDeleteDialog(
              context: context,
              onPressed: () {
                ClassService().deleteClass(uid: classe.uid);
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                      builder: (context) => const DashboardSecretaryPage()),
                  (Route<dynamic> route) => false,
                );
              },
            );
          } else if (result == "notes") {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => NotesClassPage(
                  classFirebase: classe,
                ),
              ),
            );
          }
        },
        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
          const PopupMenuItem<String>(
            value: 'Edit',
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [Text('Editar'), Icon(Icons.edit, size: 16)],
            ),
          ),
          const PopupMenuItem<String>(
            value: 'notes',
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Notas dos Alunos'),
                Icon(Icons.groups_2_rounded, size: 16)
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Métodos de Construção de Linha de Item (Aluno/Matéria) ---

  Widget _buildStudentRowSmallScreen(UserFirebase user) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 0),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Matrícula: ${user.registration.toString()}"),
                  Text("Nome: ${user.name}"),
                  Text("Email: ${user.email}"),
                  Text("CPF: ${user.cpf}"),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit, size: 20, color: Colors.blue),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => StudantCreatePage(
                      userStudent: user,
                    ),
                  ),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Editar aluno: ${user.name}')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentRowLargeScreen(UserFirebase user) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 0),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Matrícula: ${user.registration.toString()}"),
                  Text("Nome: ${user.name}"),
                  Text("Email: ${user.email}"),
                  Text("CPF: ${user.cpf}"),
                ],
              ),
            ),
            Flexible(
              flex: 1,
              child: IconButton(
                icon: const Icon(Icons.edit, size: 20, color: Colors.blue),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => StudantCreatePage(
                        userStudent: user,
                      ),
                    ),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Editar aluno: ${user.name}')),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectRowSmallScreen(SubjectModule subject) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 0),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Matéria: ${subject.title}"),
                  Text(
                      "Dias de aula: ${subject.daysWeek.toString().replaceAll('[', '').replaceAll(']', '')}"),
                  Text(
                    "Horário: ${subject.startHour} a ${subject.endHour}",
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectRowLargeScreen(SubjectModule subject) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 0),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Matéria: ${subject.title}"),
                  Text(
                      "Dias de aula: ${subject.daysWeek.toString().replaceAll('[', '').replaceAll(']', '')}"),
                  Text(
                    "Horário: ${subject.startHour} a ${subject.endHour}",
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
