import 'package:flutter/material.dart';

class ListClassTeacher extends StatefulWidget {
  final bool isSmallScreen;
  final TextEditingController searchController;
  const ListClassTeacher({
    super.key,
    required this.isSmallScreen,
    required this.searchController,
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
          width: MediaQuery.of(context).size.width * 0.85,
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
            ],
          ),
        ),
      ),
    );
  }
}
