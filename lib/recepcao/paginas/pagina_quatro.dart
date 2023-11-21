import 'package:flutter/material.dart';

class paginaquatro extends StatefulWidget {
  const paginaquatro({super.key});

  @override
  State<paginaquatro> createState() => _paginaquatroState();
}

class _paginaquatroState extends State<paginaquatro> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("assets/tela_04.png"), fit: BoxFit.cover),
            ),
          ),
          const SafeArea(
            child: Padding(
              padding: EdgeInsets.only(top: 35, left: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Aventure-se em',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 26,
                          color: Color.fromARGB(255, 122, 108, 108))),
                  Text('nossas terras!',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 40,
                          color: Color.fromARGB(255, 122, 108, 108))),
                  SizedBox(height: 30),
                  Padding(
                    padding: EdgeInsets.only(right: 100),
                    child: Text(
                        'Em nossas estantes temos projetos como romance, ficção e fantasia, não ficção, suspense, folclore, terror e horror',
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
