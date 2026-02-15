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

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.deepPurple.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.access_time, color: Colors.deepPurple, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Carga Horária Total:',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.deepPurple,
                  ),
                ),
                const SizedBox(width: 16),
                _buildModuleBadge('Módulo 1', colorModule1, totalHours1),
                const SizedBox(width: 12),
                _buildModuleBadge('Módulo 2', colorModule2, totalHours2),
                const SizedBox(width: 12),
                _buildModuleBadge('Módulo 3', colorModule3, totalHours3),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                CardModuleComponent(
                  isSmallScreen: widget.isSmallScreen,
                  userTeacher: widget.activeTeacher,
                  title: 'Módulo 1',
                  subjectModule: widget.subjectModuleUnity1,
                ),
                const SizedBox(width: 16),
                CardModuleComponent(
                  isSmallScreen: widget.isSmallScreen,
                  userTeacher: widget.activeTeacher,
                  title: 'Módulo 2',
                  subjectModule: widget.subjectModuleUnity2,
                ),
                const SizedBox(width: 16),
                CardModuleComponent(
                  isSmallScreen: widget.isSmallScreen,
                  userTeacher: widget.activeTeacher,
                  title: 'Módulo 3',
                  subjectModule: widget.subjectModuleUnity3,
                )
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildModuleBadge(String label, Color color, int hours) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${hours}h',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCircle(Color color, int hours) {
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
