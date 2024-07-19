import 'package:flutter/material.dart';
import 'package:university/components/app_bar_component.dart';
import 'package:university/core/utilities/styles.constants.dart';

class CoursesPage extends StatefulWidget {
  final String titleCourse;
  final String msgCourse;
  final String urlImage;
  final String semesters;
  final String typeFormatCourse;
  const CoursesPage(
      {super.key,
      required this.titleCourse,
      required this.msgCourse,
      required this.urlImage,
      required this.semesters,
      required this.typeFormatCourse});

  @override
  State<CoursesPage> createState() => _CoursesPageState();
}

class _CoursesPageState extends State<CoursesPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarComponent(),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
          bool isSmallScreen = constraints.maxWidth < 600;
          return Column(
            children: [
              Stack(
                children: [
                  SizedBox(
                    height: 520,
                    width: double.infinity,
                    child: Image.asset(
                      widget.urlImage,
                      fit: BoxFit.cover,
                      alignment: Alignment.centerLeft,
                    ),
                  ),
                  Container(
                    height: 520,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          const Color.fromARGB(255, 8, 21, 61).withOpacity(0.5),
                          const Color.fromARGB(255, 20, 42, 138)
                              .withOpacity(0.5),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 80,
                    left: isSmallScreen
                        ? 0
                        : MediaQuery.of(context).size.height * 0.25,
                    child: SizedBox(
                      width: isSmallScreen ? 400 : 600,
                      child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Início > Cursos > ${widget.titleCourse}',
                                style: const TextStyle(color: Colors.white),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                widget.titleCourse,
                                style: texTitleCard,
                              ),
                              const SizedBox(height: 5),
                              Text(
                                widget.msgCourse,
                                style: const TextStyle(
                                  color: Color.fromARGB(255, 226, 223, 223),
                                  fontSize: 13.0,
                                ),
                              ),
                              const SizedBox(height: 30),
                              Row(
                                children: [
                                  Container(
                                    height: 30,
                                    width: 30,
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(15)),
                                    ),
                                    child: const Icon(
                                      Icons.calendar_month_outlined,
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(widget.semesters,
                                      style: const TextStyle(
                                          fontSize: 14, color: Colors.white)),
                                  const SizedBox(width: 25),
                                  Container(
                                    height: 30,
                                    width: 30,
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(15)),
                                    ),
                                    child: const Icon(Icons.school_outlined,
                                        size: 20),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(widget.typeFormatCourse,
                                      style: const TextStyle(
                                          fontSize: 14, color: Colors.white)),
                                ],
                              ),
                            ],
                          )),
                    ),
                  ),
                ],
              ),
            ],
          );
        }),
      ),
    );
  }
}
