import 'package:flutter/material.dart';
import 'package:university/core/models/user_firebase.dart';
import 'package:university/core/utilities/styles.constants.dart';
import 'package:university/pages/secretary/teacher_create_page.dart';

class ListTeacherCard extends StatefulWidget {
  final bool isSmallScreen;
  final TextEditingController searchController;
  final List<UserFirebase> paginatedTeachers;
  final Function() sortTeachersByName;
  final bool isAscending;
  final Function() previousPage;
  final int currentPage;
  final List<UserFirebase> filteredTeachers;
  final int itemsPerPage;
  final Function() nextPage;

  const ListTeacherCard(
      {super.key,
      required this.isSmallScreen,
      required this.searchController,
      required this.paginatedTeachers,
      required this.sortTeachersByName,
      required this.isAscending,
      required this.previousPage,
      required this.currentPage,
      required this.filteredTeachers,
      required this.itemsPerPage,
      required this.nextPage});

  @override
  State<ListTeacherCard> createState() => _ListTeacherCardState();
}

class _ListTeacherCardState extends State<ListTeacherCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
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
                    width: widget.isSmallScreen
                        ? MediaQuery.of(context).size.width * 0.4
                        : MediaQuery.of(context).size.width * 0.3,
                    child: TextField(
                      controller: widget.searchController,
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
              widget.isSmallScreen
                  ? Column(
                      children: widget.paginatedTeachers.map((teacher) {
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
                                    '${teacher.name} ${teacher.surname}',
                                    style: textFontBold,
                                  ),
                                  PopupMenuButton<String>(
                                    icon: const Icon(Icons.more_vert),
                                    onSelected: (String result) {
                                      if (result == 'Edit') {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  TeacherCreatePage(
                                                      userTeacher: teacher)),
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
                                    ],
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
                              onTap: widget.sortTeachersByName,
                              child: Row(
                                children: [
                                  const Padding(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 8.0),
                                    child: Text('Nome', style: textFontBold),
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
                              child: Text('Email', style: textFontBold),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: Text('CPF', style: textFontBold),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: Text('Telefone', style: textFontBold),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: Text('Status', style: textFontBold),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: Text('Editar',
                                  style: textFontBold,
                                  textAlign: TextAlign.center),
                            ),
                          ],
                        ),
                        for (var teacher in widget.paginatedTeachers) ...[
                          TableRow(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child:
                                    Text('${teacher.name} ${teacher.surname}'),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: Text(teacher.email),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: Text(teacher.cpf),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: Text(teacher.phone),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: Text(
                                    teacher.isActive ? "Ativo" : "Desativado"),
                              ),
                              Center(
                                child: PopupMenuButton<String>(
                                  icon: const Icon(Icons.more_vert),
                                  onSelected: (String result) {
                                    if (result == 'Edit') {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                TeacherCreatePage(
                                                    userTeacher: teacher)),
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
                      '${widget.currentPage}/${(widget.filteredTeachers.length / widget.itemsPerPage).ceil()}'),
                  IconButton(
                    onPressed: widget.nextPage,
                    icon: const Icon(Icons.arrow_forward),
                    color: widget.currentPage * widget.itemsPerPage <
                            widget.filteredTeachers.length
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
