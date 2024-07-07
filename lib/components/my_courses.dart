import 'package:flutter/material.dart';
import 'package:university/components/type_courses.dart';
import 'package:university/core/utilities/styles.constants.dart';

class MyCourses extends StatelessWidget {
  final bool isSmallScreen;
  const MyCourses({super.key, required this.isSmallScreen});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.only(
            left:
                isSmallScreen ? 0 : MediaQuery.of(context).size.height * 0.25),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Conheça os nossos Cursos', style: textSubTitle),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  TypeCourses(
                      image: 'assets/images/tecEnfemagem.jpg',
                      presencialOrHibrid: 'Presencial',
                      isEad: 'EAD',
                      titleCourse: 'Técnico de Enfermagem',
                      semesters: '8 Semestres',
                      typeFormatCourse: 'Tecnólogico'),
                  TypeCourses(
                      image: 'assets/images/heart.jpg',
                      presencialOrHibrid: 'Presencial',
                      isEad: 'EAD',
                      titleCourse: 'Especialização em Sala Vermelha',
                      semesters: '8 Semestres',
                      typeFormatCourse: 'Tecnólogico'),
                  TypeCourses(
                      image: 'assets/images/oconlogia.jpg',
                      presencialOrHibrid: 'Presencial',
                      isEad: 'EAD',
                      titleCourse: 'Especialização em Oncologia',
                      semesters: '8 Semestres',
                      typeFormatCourse: 'Tecnólogico'),
                  TypeCourses(
                      image: 'assets/images/hemodialise.jpg',
                      presencialOrHibrid: 'Presencial',
                      isEad: 'EAD',
                      titleCourse: 'Especialização em Hemodiálise',
                      semesters: '8 Semestres',
                      typeFormatCourse: 'Tecnólogico'),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
