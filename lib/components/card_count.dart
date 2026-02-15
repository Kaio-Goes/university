import 'package:flutter/material.dart';

class CardCount extends StatelessWidget {
  final String count;
  final String typeCount;
  final Color color;
  const CardCount(
      {super.key,
      required this.count,
      required this.typeCount,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      width: 280,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withValues(alpha: 0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    typeCount,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getIcon(typeCount),
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ],
            ),
            Text(
              count,
              style: const TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                height: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIcon(String type) {
    if (type.toLowerCase().contains('aluno')) {
      return Icons.school;
    } else if (type.toLowerCase().contains('professor')) {
      return Icons.person;
    } else if (type.toLowerCase().contains('turma')) {
      return Icons.class_;
    }
    return Icons.analytics;
  }
}
