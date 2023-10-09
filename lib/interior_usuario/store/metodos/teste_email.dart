import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class enviar_email extends StatefulWidget {
  const enviar_email({super.key});

  @override
  State<enviar_email> createState() => _enviar_emailState();
}

class _enviar_emailState extends State<enviar_email> {
  Future<void> enviar_email(String destinatario) async {
    var url =
        Uri.parse('https://api-welcome-izyncor.onrender.com/send?destinatario=$destinatario');
    var response = await http.get(url);
    print(response.body);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: [
        ElevatedButton(
          onPressed: () {
            
          },
          child: const Text('Disparar E-mail'),
        ),
      ]),
    );
  }
}
