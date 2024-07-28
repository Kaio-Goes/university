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
    return SizedBox(
      height: 100,
      width: 270,
      child: Card(
        elevation: 1,
        child: Center(
          child: ListTile(
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Center(
                child: Text(
                  count,
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ),
            title: Text(typeCount),
          ),
        ),
      ),
    );
  }
}
