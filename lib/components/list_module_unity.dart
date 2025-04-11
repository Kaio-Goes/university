import 'package:flutter/material.dart';
import 'package:university/components/card_module_component.dart';
import 'package:university/core/models/subject_module.dart';
import 'package:university/core/models/user_firebase.dart';
import 'package:university/core/utilities/styles.constants.dart';

class ListModuleUnity extends StatefulWidget {
  final String title;
  final bool isSmallScreen;
  final List<UserFirebase> activeTeacher;
  final List<SubjectModule>? subjectModuleUnity1;
  final List<SubjectModule>? subjectModuleUnity2;
  final List<SubjectModule>? subjectModuleUnity3;

  const ListModuleUnity({
    super.key,
    required this.title,
    required this.isSmallScreen,
    required this.activeTeacher,
    required this.subjectModuleUnity1,
    required this.subjectModuleUnity2,
    required this.subjectModuleUnity3,
  });

  @override
  State<ListModuleUnity> createState() => _ListModuleUnityState();
}

class _ListModuleUnityState extends State<ListModuleUnity> {
  int getTotalHours(List<SubjectModule>? modules) {
    if (modules == null) return 0;
    return modules.fold(0, (sum, m) => sum + int.tryParse(m.hour)!);
  }

  @override
  Widget build(BuildContext context) {
    final totalHours1 = getTotalHours(widget.subjectModuleUnity1);
    final totalHours2 = getTotalHours(widget.subjectModuleUnity2);
    final totalHours3 = getTotalHours(widget.subjectModuleUnity3);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          Column(
            children: [
              const SizedBox(height: 30),
              Row(
                children: [
                  Text(
                    widget.title,
                    style: textTitle,
                  ),
                  const SizedBox(width: 70),
                  Row(
                    children: [
                      const Text(
                        'Horas Totais:',
                        style: textLabel,
                      ),
                      const SizedBox(width: 10),
                      const Text('Módulo 1'),
                      const SizedBox(width: 5),
                      _buildCircle(colorModule1, totalHours1),
                      const SizedBox(width: 15),
                      const Text('Módulo 2'),
                      const SizedBox(width: 5),
                      _buildCircle(colorModule2, totalHours2),
                      const SizedBox(width: 15),
                      const Text('Módulo 1'),
                      const SizedBox(width: 3),
                      _buildCircle(colorModule3, totalHours3),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CardModuleComponent(
                    isSmallScreen: widget.isSmallScreen,
                    userTeacher: widget.activeTeacher,
                    title: 'Módulo 1',
                    subjectModule: widget.subjectModuleUnity1,
                  ),
                  const SizedBox(width: 10),
                  CardModuleComponent(
                    isSmallScreen: widget.isSmallScreen,
                    userTeacher: widget.activeTeacher,
                    title: 'Módulo 2',
                    subjectModule: widget.subjectModuleUnity2,
                  ),
                  const SizedBox(width: 10),
                  CardModuleComponent(
                    isSmallScreen: widget.isSmallScreen,
                    userTeacher: widget.activeTeacher,
                    title: 'Módulo 3',
                    subjectModule: widget.subjectModuleUnity3,
                  )
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCircle(Color color, int hours) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: color.withAlpha(204), // 204 é 80% de 255
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        "${hours.toString()} hr",
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
