import 'package:flutter/material.dart';
import 'package:university/core/utilities/styles.constants.dart';

class TextStudant extends StatelessWidget {
  const TextStudant({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 45,
          width: 200,
          decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(20))),
          child: const Center(
            child: Text(
              'GRADUAÇÃO 2024.2',
              style: textBold,
            ),
          ),
        ),
        const SizedBox(
          height: 8,
        ),
        const Text(
          'Transforme o seu futuro com o Anna Nery',
          style: texTitleCard,
        ),
        const Text(
          'Inscreva-se no nosso vestibular. São mais de 30 opções de cursos, nas modalidades Presencial, Híbrido e EaD. Só no UniProjeção você tem acesso a bolsas de até 100%!',
          style: TextStyle(color: Colors.white),
        ),
        const SizedBox(
          height: 15,
        ),
        Row(
          children: [
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 29, 25, 51),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text('Iniciar Inscrição'),
            ),
            const SizedBox(width: 20),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(0, 255, 255, 255),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text('Ver cursos'),
            ),
          ],
        ),
      ],
    );
  }
}
