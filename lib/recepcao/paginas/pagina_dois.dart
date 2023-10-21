import 'package:flutter/material.dart';

class paginadois extends StatefulWidget {
  const paginadois({super.key});

  @override
  State<paginadois> createState() => _paginadoisState();
}

class _paginadoisState extends State<paginadois> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("assets/tela_02_1.jpg"),
                  fit: BoxFit.cover),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 100, left: 10),
            child: Align(
              alignment: Alignment.topLeft,
              child: Image.asset('assets/inicio_texto2.png', width: 300,),
            ),
          )
        ],
      ),
    );
  }
}
