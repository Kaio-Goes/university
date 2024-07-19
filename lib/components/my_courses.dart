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
                      msgCourse:
                          'Torne-se um profissional que trabalha com o objetivo de prestar cuidados de saúde fundamentais e assistir na recuperação de pacientes, potencializando a qualidade dos serviços de saúde.',
                      semesters: '8 Semestres',
                      typeFormatCourse: 'Tecnólogico'),
                  TypeCourses(
                      image: 'assets/images/heart.jpg',
                      presencialOrHibrid: 'Presencial',
                      isEad: 'EAD',
                      titleCourse: 'Especialização em Sala Vermelha',
                      msgCourse:
                          'Torne-se um profissional especializado em Sala Vermelha, capacitado para atuar em situações de emergência e alta complexidade, garantindo atendimento rápido e eficiente para salvar vidas.',
                      semesters: '8 Semestres',
                      typeFormatCourse: 'Tecnólogico'),
                  TypeCourses(
                      image: 'assets/images/oconlogia.jpg',
                      presencialOrHibrid: 'Presencial',
                      isEad: 'EAD',
                      titleCourse: 'Especialização em Oncologia',
                      msgCourse:
                          'Torne-se um profissional especializado em Oncologia, capacitado para oferecer cuidados integrados e avançados no tratamento e na recuperação de pacientes com câncer, promovendo qualidade de vida e suporte contínuo.',
                      semesters: '8 Semestres',
                      typeFormatCourse: 'Tecnólogico'),
                  TypeCourses(
                      image: 'assets/images/hemodialise.jpg',
                      presencialOrHibrid: 'Presencial',
                      isEad: 'EAD',
                      titleCourse: 'Especialização em Hemodiálise',
                      msgCourse:
                          'Torne-se um profissional especializado em Hemodiálise, capacitado para realizar tratamentos de diálise com precisão e cuidado, contribuindo para a saúde e bem-estar de pacientes com insuficiência renal.',
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
