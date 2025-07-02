import 'package:flutter/material.dart';
import 'package:university/core/models/class_firebase.dart';
import 'package:university/core/models/subject_module.dart';
import 'package:university/core/utilities/styles.constants.dart';
import 'package:university/pages/teacher/notes/add_notes_student_page.dart';
import 'package:university/pages/teacher/notes/create_notes_page.dart';

class ListClassTeacher extends StatefulWidget {
  final bool isSmallScreen;
  final TextEditingController searchController;
  final List<ClassFirebase> paginetedClass;
  final List<SubjectModule> listSubject;
  final Function() sortTitleByName;
  final bool isAscending;
  final Function() previousPage;
  final int currentPage;
  final List<ClassFirebase> filteredClass;
  final int itemsPerPage;
  final Function() nextPage;

  const ListClassTeacher({
    super.key,
    required this.isSmallScreen,
    required this.searchController,
    required this.paginetedClass,
    required this.listSubject,
    required this.sortTitleByName,
    required this.isAscending,
    required this.previousPage,
    required this.currentPage,
    required this.filteredClass,
    required this.itemsPerPage,
    required this.nextPage,
  });

  @override
  State<ListClassTeacher> createState() => _ListClassTeacherState();
}

class _ListClassTeacherState extends State<ListClassTeacher> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Minhas Turmas",
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
              ),
              const SizedBox(height: 10),
              widget.isSmallScreen
                  ? Column(
                      children: widget.paginetedClass.map((classe) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Data de Ínicio: ${classe.startDate}'),
                              Text('Data final: ${classe.endDate}'),
                              Text(
                                  'Total de Alunos: ${classe.students.length}'),
                              for (var subject in widget.listSubject
                                  .where((s) => classe.subject.contains(s.uid)))
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Matéria: ${subject.title.length > 18 ? '${subject.title.substring(0, 18)}...' : subject.title}',
                                        ),
                                        PopupMenuButton<String>(
                                          icon: const Icon(Icons.more_vert),
                                          onSelected: (String result) {
                                            if (result == 'CreateNote') {
                                              Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      CreateNotesPage(
                                                    classFirebase: classe,
                                                    subject: subject,
                                                  ),
                                                ),
                                              );
                                            } else if (result ==
                                                'ReleaseNote') {
                                              Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      AddNotesStudentPage(
                                                    classe: classe,
                                                    subject: subject,
                                                  ),
                                                ),
                                              );
                                            }
                                          },
                                          itemBuilder: (BuildContext context) =>
                                              <PopupMenuEntry<String>>[
                                            const PopupMenuItem<String>(
                                              value: 'CreateNote',
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                      'Adicionar Notas Trabalho/Provas'),
                                                  Icon(Icons.edit, size: 16)
                                                ],
                                              ),
                                            ),
                                            const PopupMenuItem<String>(
                                              value: 'ReleaseNote',
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                      'Lançar Notas/Visualizar Notas'),
                                                  Icon(
                                                      Icons
                                                          .remove_red_eye_sharp,
                                                      size: 16)
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Text('Módulo : ${subject.module}'),
                                  ],
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
                        1: FlexColumnWidth(1),
                        2: FlexColumnWidth(1),
                        3: FlexColumnWidth(1),
                        4: FlexColumnWidth(1),
                        5: FixedColumnWidth(400),
                        6: FixedColumnWidth(50),
                      },
                      children: [
                        TableRow(
                          children: [
                            GestureDetector(
                              onTap: widget.sortTitleByName,
                              child: Row(
                                children: [
                                  const Padding(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 8.0),
                                    child: Text('Turma', style: textFontBold),
                                  ),
                                  Icon(
                                    widget.isAscending
                                        ? Icons.arrow_upward
                                        : Icons.arrow_downward,
                                    size: 16,
                                  ),
                                ],
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child:
                                  Text('Data de Ínicio', style: textFontBold),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: Text('Data Final', style: textFontBold),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child:
                                  Text('Total de Alunos', style: textFontBold),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: Text('Módulo', style: textFontBold),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: Text('Matéria', style: textFontBold),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: Text('Ação',
                                  style: textFontBold,
                                  textAlign: TextAlign.center),
                            ),
                          ],
                        ),
                        for (var classe in widget.paginetedClass) ...[
                          for (var subject in widget.listSubject
                              .where((s) => classe.subject.contains(s.uid)))
                            TableRow(
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Text(classe.name),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Text(classe.startDate),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Text(classe.endDate),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child:
                                      Text(classe.students.length.toString()),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Text(subject.module),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Text(subject.title),
                                ),
                                Center(
                                  child: PopupMenuButton<String>(
                                    icon: const Icon(Icons.more_vert),
                                    onSelected: (String result) {
                                      if (result == 'CreateNote') {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                CreateNotesPage(
                                              classFirebase: classe,
                                              subject: subject,
                                            ),
                                          ),
                                        );
                                      } else if (result == 'ReleaseNote') {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                AddNotesStudentPage(
                                              classe: classe,
                                              subject: subject,
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                    itemBuilder: (BuildContext context) =>
                                        <PopupMenuEntry<String>>[
                                      const PopupMenuItem<String>(
                                        value: 'CreateNote',
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                                'Adicionar Notas Trabalho/Provas'),
                                            Icon(Icons.edit, size: 16)
                                          ],
                                        ),
                                      ),
                                      const PopupMenuItem<String>(
                                        value: 'ReleaseNote',
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                                'Lançar Notas/Visualizar Notas'),
                                            Icon(Icons.remove_red_eye_sharp,
                                                size: 16)
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          TableRow(
                            children: List.generate(
                              7,
                              (_) => const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8.0),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
