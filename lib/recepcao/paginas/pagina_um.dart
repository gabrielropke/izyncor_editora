import 'package:flutter/material.dart';

class paginaum extends StatefulWidget {
  const paginaum({super.key});

  @override
  State<paginaum> createState() => _paginaumState();
}

class _paginaumState extends State<paginaum> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("assets/tela_01_1.jpg"), fit: BoxFit.cover),
            ),
          ),
          const SafeArea(
            child: Padding(
              padding: EdgeInsets.only(top: 35, left: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Boas vindas a',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                          color: Color.fromARGB(255, 122, 108, 108))),
                  Text('Izyncor!',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 50,
                          color: Color.fromARGB(255, 122, 108, 108))),
                  SizedBox(height: 30),
                  Padding(
                    padding: EdgeInsets.only(right: 100),
                    child: Text(
                        'Editora dedicada a crias obras de arte literárias, que transcendem a simples leitura e se tornam verdadeira experiências sensoriais para os amantes dos livros de luxo.',
                        style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 16,
                            color: Color.fromARGB(255, 122, 108, 108))),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
