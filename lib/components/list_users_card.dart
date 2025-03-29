import 'package:flutter/material.dart';
import 'package:university/core/models/user_firebase.dart';
import 'package:university/core/utilities/styles.constants.dart';
import 'package:university/pages/secretary/student/history_notes_page.dart';
import 'package:university/pages/secretary/student/student_create_page.dart';
import 'package:university/pages/secretary/teacher_create_page.dart';

class ListUsersCard extends StatefulWidget {
  final bool isSmallScreen;
  final String title;
  final TextEditingController searchController;
  final List<UserFirebase> paginetedUsers;
  final Function() sortTeachersByName;
  final bool isAscending;
  final Function() previousPage;
  final int currentPage;
  final List<UserFirebase> filteredUsers;
  final int itemsPerPage;
  final Function() nextPage;

  const ListUsersCard(
      {super.key,
      required this.isSmallScreen,
      required this.title,
      required this.searchController,
      required this.paginetedUsers,
      required this.sortTeachersByName,
      required this.isAscending,
      required this.previousPage,
      required this.currentPage,
      required this.filteredUsers,
      required this.itemsPerPage,
      required this.nextPage});

  @override
  State<ListUsersCard> createState() => _ListUsersCardState();
}

class _ListUsersCardState extends State<ListUsersCard> {
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
                  Text(
                    widget.title,
                    style: const TextStyle(
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
                      children: widget.paginetedUsers.map((user) {
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
                                    '${user.name} ${user.surname ?? ''}',
                                    style: textFontBold,
                                  ),
                                  PopupMenuButton<String>(
                                    icon: const Icon(Icons.more_vert),
                                    onSelected: (String result) {
                                      if (result == 'Edit') {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                user.role == 'teacher'
                                                    ? TeacherCreatePage(
                                                        userTeacher: user)
                                                    : StudantCreatePage(
                                                        userStudent: user),
                                          ),
                                        );
                                      } else if (result == "historyNotes") {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                HistoryNotesPage(
                                              user: user,
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
                                      if (user.role == "student") ...[
                                        const PopupMenuItem<String>(
                                          value: 'historyNotes',
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text('Histórico de Notas'),
                                              Icon(Icons.history, size: 16)
                                            ],
                                          ),
                                        ),
                                      ]
                                    ],
                                  ),
                                ],
                              ),
                              Text('Email: ${user.email}'),
                              Text('CPF: ${user.cpf}'),
                              Text('Telefone: ${user.phone}'),
                              Text(
                                'Status: ${user.isActive ? "Ativo" : "Desativado"}',
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
                        for (var user in widget.paginetedUsers) ...[
                          TableRow(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child:
                                    Text('${user.name} ${user.surname ?? ''}'),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: Text(user.email),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: Text(user.cpf),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: Text(user.phone),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: Text(
                                    user.isActive ? "Ativo" : "Desativado"),
                              ),
                              Center(
                                child: PopupMenuButton<String>(
                                  icon: const Icon(Icons.more_vert),
                                  onSelected: (String result) {
                                    if (result == 'Edit') {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              user.role == 'teacher'
                                                  ? TeacherCreatePage(
                                                      userTeacher: user,
                                                    )
                                                  : StudantCreatePage(
                                                      userStudent: user,
                                                    ),
                                        ),
                                      );
                                    } else if (result == "historyNotes") {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              HistoryNotesPage(user: user),
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
                                    if (user.role == "student") ...[
                                      const PopupMenuItem<String>(
                                        value: 'historyNotes',
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text('Histórico de Notas'),
                                            Icon(Icons.history, size: 16)
                                          ],
                                        ),
                                      ),
                                    ]
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
                      '${widget.currentPage}/${(widget.filteredUsers.length / widget.itemsPerPage).ceil()}'),
                  IconButton(
                    onPressed: widget.nextPage,
                    icon: const Icon(Icons.arrow_forward),
                    color: widget.currentPage * widget.itemsPerPage <
                            widget.filteredUsers.length
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
