import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:university/components/app_bar_user_component.dart';
import 'package:university/components/card_subject.dart';
import 'package:university/components/footer.dart';
import 'package:university/components/list_class_teacher.dart';
import 'package:university/core/models/class_firebase.dart';
import 'package:university/core/models/subject_module.dart';
import 'package:university/core/models/user_firebase.dart'; // Importar UserFirebase
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
  UserFirebase?
      currentUser; // <-- Adicionado para armazenar o usuário carregado

  bool isAscendingClass = true;
  int currentPageClass = 1;
  int itemsPerPageClass = 5;

  final ScrollController _scrollController = ScrollController();
  bool _showLeftArrow = false;
  bool _showRightArrow = false;

  late Future<void> _loadDataFuture;

  @override
  void initState() {
    super.initState();
    _loadDataFuture = _loadInitialData(); // Inicia o carregamento dos dados
    searchController.addListener(filterClass);
    _scrollController.addListener(_updateScrollArrows);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateScrollArrows);
    _scrollController.dispose();
    searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    try {
      await AuthUserService().loadUserFromCache();
      currentUser =
          AuthUserService().currentUser; // <-- Armazena o usuário carregado

      if (currentUser == null) {
        throw Exception("Usuário não autenticado.");
      }

      var subjects = await SubjectService().getSubjectsByUser(currentUser!.uid);
      var subjectUids = subjects.map((subject) => subject.uid).toList();
      var classList =
          await ClassService().getClassesBySubjects(subjectUids: subjectUids);

      // Atualiza as listas diretamente
      listSubject = subjects;
      listClass = classList;
      filteredClass = listClass;
    } catch (e) {
      log('Erro ao carregar dados iniciais: $e');
      rethrow;
    }
  }

  void _updateScrollArrows() {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final offset = _scrollController.offset;
    final newShowLeft = offset > 0;
    final newShowRight = offset < maxScroll;
    if (newShowLeft != _showLeftArrow || newShowRight != _showRightArrow) {
      setState(() {
        _showLeftArrow = newShowLeft;
        _showRightArrow = newShowRight;
      });
    }
  }

  void filterClass() {
    setState(() {
      filteredClass = listClass.where((classe) {
        return classe.name
            .toLowerCase()
            .contains(searchController.text.toLowerCase());
      }).toList();
      currentPageClass = 1;
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
    return Scaffold(
      // Move o AppBar para dentro do FutureBuilder
      body: FutureBuilder<void>(
        future: _loadDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Scaffold(
              // Adicione um Scaffold aqui para ter um AppBar de erro
              appBar: AppBar(
                title: const Text('Erro'),
                backgroundColor: Colors.red,
              ),
              body: Center(
                child: Text(
                  'Ocorreu um erro ao carregar os dados.\nTente novamente mais tarde.\nErro: ${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                ),
              ),
            );
          }

          // Se chegou aqui, os dados foram carregados (currentUser também)
          int startIndexClass = (currentPageClass - 1) * itemsPerPageClass;
          int endIndexClass = startIndexClass + itemsPerPageClass;

          List<ClassFirebase> paginatedClass = filteredClass.sublist(
              startIndexClass,
              endIndexClass > filteredClass.length
                  ? filteredClass.length
                  : endIndexClass);

          return Scaffold(
            // Adicione outro Scaffold para o conteúdo principal
            appBar: appBarUserComponent(
                userFirebase:
                    currentUser), // Agora currentUser já estará carregado
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
                        listSubject.isEmpty
                            ? const Text(
                                "Não possuo matéria, peça ao secretário para adicionar sua matéria",
                                style: TextStyle(fontSize: 14),
                              )
                            : Stack(
                                children: [
                                  SingleChildScrollView(
                                    controller: _scrollController,
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: [
                                        LayoutBuilder(
                                          builder: (context, constraints) {
                                            bool isSmallScreen =
                                                constraints.maxWidth < 800;
                                            return isSmallScreen
                                                ? Column(
                                                    children: listSubject
                                                        .map((subject) =>
                                                            CardSubject(
                                                              subjectModule:
                                                                  subject,
                                                              classFirebase:
                                                                  listClass,
                                                            ))
                                                        .toList(),
                                                  )
                                                : Wrap(
                                                    spacing: 10.0,
                                                    runSpacing: 10.0,
                                                    alignment:
                                                        WrapAlignment.center,
                                                    children: listSubject
                                                        .map((subject) =>
                                                            CardSubject(
                                                              subjectModule:
                                                                  subject,
                                                              classFirebase:
                                                                  listClass,
                                                            ))
                                                        .toList(),
                                                  );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (_showLeftArrow)
                                    Positioned(
                                      left: 0,
                                      top: 0,
                                      bottom: 0,
                                      child: Container(
                                        width: 30,
                                        alignment: Alignment.centerLeft,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight,
                                            colors: [
                                              Colors.grey,
                                              Colors.grey.withAlpha(40)
                                            ],
                                          ),
                                        ),
                                        child: const Icon(Icons.arrow_back_ios,
                                            size: 25, color: Colors.white),
                                      ),
                                    ),
                                  if (_showRightArrow)
                                    Positioned(
                                      right: 0,
                                      top: 0,
                                      bottom: 0,
                                      child: Container(
                                        width: 30,
                                        alignment: Alignment.centerRight,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.centerRight,
                                            end: Alignment.centerLeft,
                                            colors: [
                                              Colors.grey,
                                              Colors.grey.withAlpha(40),
                                            ],
                                          ),
                                        ),
                                        child: const Icon(
                                            Icons.arrow_forward_ios,
                                            size: 25,
                                            color: Colors.white),
                                      ),
                                    ),
                                ],
                              ),
                        const SizedBox(height: 15),
                        ListClassTeacher(
                          isSmallScreen:
                              MediaQuery.of(context).size.width < 800,
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
                  const Footer(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
