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
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.85,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: SizedBox(
                    width: widget.isSmallScreen
                        ? MediaQuery.of(context).size.width * 0.5
                        : MediaQuery.of(context).size.width * 0.35,
                    child: TextField(
                      controller: widget.searchController,
                      decoration: InputDecoration(
                        labelText: 'Pesquisar por nome ou email',
                        prefixIcon: const Icon(Icons.search, color: Colors.deepPurple),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
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
                            Text('Unidade: ${user.unity ?? ''}'),
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
                      2: FlexColumnWidth(4),
                      3: FlexColumnWidth(2),
                      4: FlexColumnWidth(3),
                      5: FixedColumnWidth(120),
                      6: FixedColumnWidth(50),
                    },
                    border: TableBorder(
                      horizontalInside: BorderSide(
                        color: Colors.grey.shade200,
                        width: 1,
                      ),
                    ),
                    children: [
                      TableRow(
                        decoration: BoxDecoration(
                          color: Colors.deepPurple.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        children: [
                          if (widget.title == "Lista de Alunos")
                            const Padding(
                              padding: EdgeInsets.all(12.0),
                              child: Text('Matrícula',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepPurple,
                                ),
                              ),
                            ),
                          GestureDetector(
                            onTap: widget.sortTeachersByName,
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                children: [
                                  const Text('Nome ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.deepPurple,
                                    ),
                                  ),
                                  Icon(
                                    widget.isAscending
                                        ? Icons.arrow_upward
                                        : Icons.arrow_downward,
                                    size: 16,
                                    color: Colors.deepPurple,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.all(12.0),
                            child: Text('Email',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple,
                              ),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.all(12.0),
                            child: Text('CPF',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple,
                              ),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.all(12.0),
                            child: Text('Telefone',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple,
                              ),
                            ),
                          ),
                          if (widget.title == "Lista de Alunos")
                            const Padding(
                              padding: EdgeInsets.all(12.0),
                              child: Text('Unidade',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepPurple,
                                ),
                              ),
                            ),
                          const Padding(
                            padding: EdgeInsets.all(12.0),
                            child: Text('Status',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple,
                              ),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.all(12.0),
                            child: Text('Ações',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                      for (var user in widget.paginetedUsers)
                        TableRow(
                          children: [
                            if (user.role == "student")
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Text('${user.registration}'),
                              ),
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Text('${user.name} ${user.surname ?? ''}'),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Text(user.email),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Text(user.cpf),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Text(user.phone),
                            ),
                            if (user.role == "student")
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Text(user.unity ?? ''),
                              ),
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: user.isActive
                                    ? Colors.green.shade50
                                    : Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  user.isActive ? "Ativo" : "Desativado",
                                  style: TextStyle(
                                    color: user.isActive
                                      ? Colors.green.shade700
                                      : Colors.red.shade700,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            Center(
                              child: PopupMenuButton<String>(
                                icon: const Icon(Icons.more_vert, color: Colors.deepPurple),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
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
                                      children: [
                                        Icon(Icons.edit, size: 18, color: Colors.deepPurple),
                                        SizedBox(width: 8),
                                        Text('Editar'),
                                      ],
                                    ),
                                  ),
                                  if (user.role == "student")
                                    const PopupMenuItem<String>(
                                      value: 'historyNotes',
                                      child: Row(
                                        children: [
                                          Icon(Icons.history, size: 18, color: Colors.deepPurple),
                                          SizedBox(width: 8),
                                          Text('Histórico de Notas'),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            )
                          ],
                        ),
                    ],
                  ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: widget.previousPage,
                        icon: const Icon(Icons.arrow_back_ios, size: 16),
                        color: widget.currentPage > 1 ? Colors.deepPurple : Colors.grey,
                        tooltip: 'Página anterior',
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Text(
                          'Página ${widget.currentPage} de ${(widget.filteredUsers.length / widget.itemsPerPage).ceil()}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.deepPurple,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: widget.nextPage,
                        icon: const Icon(Icons.arrow_forward_ios, size: 16),
                        color: widget.currentPage * widget.itemsPerPage <
                                widget.filteredUsers.length
                            ? Colors.deepPurple
                            : Colors.grey,
                        tooltip: 'Próxima página',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
