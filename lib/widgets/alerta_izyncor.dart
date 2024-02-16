import 'package:flutter/material.dart';

class AlertasIzyncor {
  static void mostrarAlerta(BuildContext context, String mensagem) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SizedBox(
            height: 150,
            child: Column(
              children: [
                SizedBox(
                  height: 60,
                  width: 60,
                  child: Image.asset(
                    'assets/icone.png',
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: Text(
                    mensagem,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                )
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Ok'),
            ),
          ],
        );
      },
    );
  }
}
