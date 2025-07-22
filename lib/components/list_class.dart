import 'package:flutter/material.dart';
import 'package:university/core/models/class_firebase.dart';
import 'package:university/core/utilities/alerts.dart';
import 'package:university/core/utilities/styles.constants.dart';
import 'package:university/pages/secretary/classe/class_create_page.dart';
import 'package:university/pages/secretary/classe/notes_class_page.dart';
import 'package:university/pages/secretary/dashboard/dashboard_secretary_page.dart';
import 'package:university/core/services/class_service.dart';

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
              Row(
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
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    classe.name,
                                    style: textFontBold,
                                  ),
                                  PopupMenuButton<String>(
                                    icon: const Icon(Icons.more_vert),
                                    onSelected: (String result) {
                                      if (result == 'Edit') {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ClassCreatePage(
                                              classFirebase: classe,
                                            ),
                                          ),
                                        );
                                      } else if (result == 'delete') {
                                        showDeleteDialog(
                                            context: context,
                                            onPressed: () {
                                              ClassService()
                                                  .deleteClass(uid: classe.uid);
                                              Navigator.of(context)
                                                  .pushAndRemoveUntil(
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              const DashboardSecretaryPage()),
                                                      (Route<dynamic> route) =>
                                                          false);
                                            });
                                      } else if (result == "notes") {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                NotesClassPage(
                                              classFirebase: classe,
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                    itemBuilder: (BuildContext context) =>
                                        <PopupMenuEntry<String>>[
                                      const PopupMenuItem<String>(
                                        value: 'Edit',
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text('Editar'),
                                            Icon(Icons.edit, size: 16)
                                          ],
                                        ),
                                      ),
                                      const PopupMenuItem<String>(
                                        value: 'notes',
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text('Notas dos Alunos'),
                                            Icon(Icons.groups_2_rounded,
                                                size: 16)
                                          ],
                                        ),
                                      ),
                                      // const PopupMenuItem<String>(
                                      //   value: 'delete',
                                      //   child: Row(
                                      //     mainAxisAlignment:
                                      //         MainAxisAlignment.spaceBetween,
                                      //     children: [
                                      //       Text(
                                      //         'Excluir',
                                      //         style:
                                      //             TextStyle(color: Colors.red),
                                      //       ),
                                      //       Icon(Icons.delete,
                                      //           size: 16, color: Colors.red)
                                      //     ],
                                      //   ),
                                      // ),
                                    ],
                                  ),
                                ],
                              ),
                              Text('Data de Ínicio: ${classe.startDate}'),
                              Text('Data final: ${classe.endDate}'),
                              Text(
                                  'Total de Alunos: ${classe.students.length}'),
                              Text(
                                'Total de Matérias: ${classe.subject.length}',
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
                              onTap: widget.sortTeachersByName,
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
                              child: Text('Total de Matérias',
                                  style: textFontBold),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: Text('Editar',
                                  style: textFontBold,
                                  textAlign: TextAlign.center),
                            ),
                          ],
                        ),
                        for (var classe in widget.paginetedClass) ...[
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
                                child: Text(classe.students.length.toString()),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: Text(classe.subject.length.toString()),
                              ),
                              Center(
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
                                            ClassService()
                                                .deleteClass(uid: classe.uid);
                                            Navigator.of(context)
                                                .pushAndRemoveUntil(
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            const DashboardSecretaryPage()),
                                                    (Route<dynamic> route) =>
                                                        false);
                                          });
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
                                  itemBuilder: (BuildContext context) =>
                                      <PopupMenuEntry<String>>[
                                    const PopupMenuItem<String>(
                                      value: 'Edit',
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('Editar'),
                                          Icon(Icons.edit, size: 16)
                                        ],
                                      ),
                                    ),
                                    const PopupMenuItem<String>(
                                      value: 'notes',
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('Notas dos Alunos'),
                                          Icon(Icons.groups_2_rounded, size: 16)
                                        ],
                                      ),
                                    ),
                                    // const PopupMenuItem<String>(
                                    //   value: 'delete',
                                    //   child: Row(
                                    //     mainAxisAlignment:
                                    //         MainAxisAlignment.spaceBetween,
                                    //     children: [
                                    //       Text(
                                    //         'Excluir',
                                    //         style: TextStyle(color: Colors.red),
                                    //       ),
                                    //       Icon(Icons.delete,
                                    //           size: 16, color: Colors.red)
                                    //     ],
                                    //   ),
                                    // ),
                                  ],
                                ),
                              )
                            ],
                          ),
                          TableRow(
                            children: List.generate(
                              6,
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
