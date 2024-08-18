import 'package:flutter/material.dart';

class ListClass extends StatefulWidget {
  final bool isSmallScreen;
  final TextEditingController searchController;

  const ListClass(
      {super.key, required this.isSmallScreen, required this.searchController});

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
                        labelText: 'Pesquisar por nome ou email',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // widget.isSmallScreen
              //     ? Column(
              //         children: widget.paginetedClass.map((user) {
              //           return Padding(
              //             padding: const EdgeInsets.symmetric(vertical: 8.0),
              //             child: Column(
              //               crossAxisAlignment: CrossAxisAlignment.start,
              //               children: [
              //                 Row(
              //                   mainAxisAlignment:
              //                       MainAxisAlignment.spaceBetween,
              //                   children: [
              //                     Text(
              //                       '${user.name} ${user.surname ?? ''}',
              //                       style: textFontBold,
              //                     ),
              //                     PopupMenuButton<String>(
              //                       icon: const Icon(Icons.more_vert),
              //                       onSelected: (String result) {
              //                         if (result == 'Edit') {
              //                           Navigator.of(context).push(
              //                             MaterialPageRoute(
              //                               builder: (context) =>
              //                                   user.role == 'teacher'
              //                                       ? TeacherCreatePage(
              //                                           userTeacher: user)
              //                                       : StudantCreatePage(
              //                                           userTeacher: user),
              //                             ),
              //                           );
              //                         }
              //                       },
              //                       itemBuilder: (BuildContext context) =>
              //                           <PopupMenuEntry<String>>[
              //                         const PopupMenuItem<String>(
              //                           value: 'Edit',
              //                           child: Row(
              //                             mainAxisAlignment:
              //                                 MainAxisAlignment.spaceBetween,
              //                             children: [
              //                               Text('Editar'),
              //                               Icon(Icons.edit, size: 16)
              //                             ],
              //                           ),
              //                         ),
              //                       ],
              //                     ),
              //                   ],
              //                 ),
              //                 Text('Email: ${user.email}'),
              //                 Text('CPF: ${user.cpf}'),
              //                 Text('Telefone: ${user.phone}'),
              //                 Text(
              //                   'Status: ${user.isActive ? "Ativo" : "Desativado"}',
              //                 ),
              //                 const Divider(),
              //               ],
              //             ),
              //           );
              //         }).toList(),
              //       )
              //     : Table(
              //         columnWidths: const {
              //           0: FlexColumnWidth(2),
              //           1: FlexColumnWidth(3),
              //           2: FlexColumnWidth(2),
              //           3: FlexColumnWidth(2),
              //           4: FlexColumnWidth(1),
              //           5: FixedColumnWidth(50),
              //         },
              //         children: [
              //           TableRow(
              //             children: [
              //               GestureDetector(
              //                 onTap: widget.sortTeachersByName,
              //                 child: Row(
              //                   children: [
              //                     const Padding(
              //                       padding:
              //                           EdgeInsets.symmetric(vertical: 8.0),
              //                       child: Text('Nome', style: textFontBold),
              //                     ),
              //                     Icon(
              //                       widget.isAscending
              //                           ? Icons.arrow_upward
              //                           : Icons.arrow_downward,
              //                       size: 16,
              //                     ),
              //                   ],
              //                 ),
              //               ),
              //               const Padding(
              //                 padding: EdgeInsets.symmetric(vertical: 8.0),
              //                 child: Text('Email', style: textFontBold),
              //               ),
              //               const Padding(
              //                 padding: EdgeInsets.symmetric(vertical: 8.0),
              //                 child: Text('CPF', style: textFontBold),
              //               ),
              //               const Padding(
              //                 padding: EdgeInsets.symmetric(vertical: 8.0),
              //                 child: Text('Telefone', style: textFontBold),
              //               ),
              //               const Padding(
              //                 padding: EdgeInsets.symmetric(vertical: 8.0),
              //                 child: Text('Status', style: textFontBold),
              //               ),
              //               const Padding(
              //                 padding: EdgeInsets.symmetric(vertical: 8.0),
              //                 child: Text('Editar',
              //                     style: textFontBold,
              //                     textAlign: TextAlign.center),
              //               ),
              //             ],
              //           ),
              //           for (var user in widget.paginetedUsers) ...[
              //             TableRow(
              //               children: [
              //                 Padding(
              //                   padding:
              //                       const EdgeInsets.symmetric(vertical: 8.0),
              //                   child:
              //                       Text('${user.name} ${user.surname ?? ''}'),
              //                 ),
              //                 Padding(
              //                   padding:
              //                       const EdgeInsets.symmetric(vertical: 8.0),
              //                   child: Text(user.email),
              //                 ),
              //                 Padding(
              //                   padding:
              //                       const EdgeInsets.symmetric(vertical: 8.0),
              //                   child: Text(user.cpf),
              //                 ),
              //                 Padding(
              //                   padding:
              //                       const EdgeInsets.symmetric(vertical: 8.0),
              //                   child: Text(user.phone),
              //                 ),
              //                 Padding(
              //                   padding:
              //                       const EdgeInsets.symmetric(vertical: 8.0),
              //                   child: Text(
              //                       user.isActive ? "Ativo" : "Desativado"),
              //                 ),
              //                 Center(
              //                   child: PopupMenuButton<String>(
              //                     icon: const Icon(Icons.more_vert),
              //                     onSelected: (String result) {
              //                       if (result == 'Edit') {
              //                         Navigator.of(context).push(
              //                           MaterialPageRoute(
              //                             builder: (context) =>
              //                                 user.role == 'teacher'
              //                                     ? TeacherCreatePage(
              //                                         userTeacher: user)
              //                                     : StudantCreatePage(
              //                                         userTeacher: user),
              //                           ),
              //                         );
              //                       }
              //                     },
              //                     itemBuilder: (BuildContext context) =>
              //                         <PopupMenuEntry<String>>[
              //                       const PopupMenuItem<String>(
              //                         value: 'Edit',
              //                         child: Row(
              //                           mainAxisAlignment:
              //                               MainAxisAlignment.spaceBetween,
              //                           children: [
              //                             Text('Editar'),
              //                             Icon(Icons.edit, size: 16)
              //                           ],
              //                         ),
              //                       ),
              //                     ],
              //                   ),
              //                 )
              //               ],
              //             ),
              //             TableRow(
              //               children: List.generate(
              //                 6,
              //                 (_) => const Padding(
              //                   padding: EdgeInsets.symmetric(vertical: 8.0),
              //                   child: Divider(),
              //                 ),
              //               ),
              //             ),
              //           ],
              //         ],
              //       ),
            ],
          ),
        ),
      ),
    );
  }
}
