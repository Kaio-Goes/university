import 'package:flutter/material.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue[300],
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          SizedBox(
            height: 60,
            child: Image.asset(
              "assets/images/annamery.png",
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Mais de 5 anos formando novos profissionais e levando educação com confiança e tradição.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.facebook, color: Colors.white),
                onPressed: () {
                  // Add your code here
                },
              ),
              IconButton(
                icon: const Icon(Icons.wb_twilight, color: Colors.white),
                onPressed: () {
                  // Add your code here
                },
              ),
              IconButton(
                icon: const Icon(Icons.linked_camera_outlined,
                    color: Colors.white),
                onPressed: () {
                  // Add your code here
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            '© 2024 Anna Nery. Todos os direitos reservados.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
