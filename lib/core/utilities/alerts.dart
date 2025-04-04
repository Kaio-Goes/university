import 'package:flutter/material.dart';
import 'package:university/pages/secretary/dashboard/dashboard_secretary_page.dart';

void showSuccessDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Sucesso"),
        content: const Text("Operação realizada com sucesso!"),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                      builder: (context) => const DashboardSecretaryPage()),
                  (Route<dynamic> route) => false);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text(
              "Ir para o início",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      );
    },
  );
}

void showDeleteDialog({
  required BuildContext context,
  required void Function()? onPressed,
}) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text("Tem certeza?"),
      content: const Text("Deseja excluir a matéria"),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(ctx).pop(false);
          },
          child: const Text("Não"),
        ),
        TextButton(
          onPressed: onPressed,
          child: const Text("Sim"),
        ),
      ],
    ),
  );
}
