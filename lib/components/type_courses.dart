import 'package:flutter/material.dart';
import 'package:university/core/utilities/styles.constants.dart';

class TypeCourses extends StatelessWidget {
  final String image;
  final String presencialOrHibrid;
  final String isEad;
  final String titleCourse;
  final String semesters;
  final String typeFormatCourse;
  const TypeCourses(
      {super.key,
      required this.image,
      required this.presencialOrHibrid,
      required this.isEad,
      required this.titleCourse,
      required this.semesters,
      required this.typeFormatCourse});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: Container(
        height: 312,
        width: 250,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
              child: SizedBox(
                height: 130,
                width: 250,
                child: Image.asset(
                  image,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        decoration: const BoxDecoration(
                            color: Color.fromARGB(68, 158, 158, 158),
                            borderRadius:
                                BorderRadius.all(Radius.circular(12))),
                        child: Text(presencialOrHibrid, style: textPlaceholder),
                      ),
                      const SizedBox(width: 10),
                      Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          decoration: const BoxDecoration(
                              color: Color.fromARGB(68, 158, 158, 158),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(12))),
                          child: Text(isEad, style: textPlaceholder)),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Text(titleCourse, style: textTitleCard),
                  const SizedBox(height: 40),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_month_outlined,
                        size: 14,
                      ),
                      const SizedBox(width: 10),
                      Text(semesters, style: textPlaceholder),
                      const SizedBox(width: 25),
                      const Icon(Icons.school_outlined, size: 14),
                      const SizedBox(width: 10),
                      Text(typeFormatCourse, style: textPlaceholder),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 29, 25, 51),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const SizedBox(
                      width: 160,
                      child: Text(
                        'Saiba Mais',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
