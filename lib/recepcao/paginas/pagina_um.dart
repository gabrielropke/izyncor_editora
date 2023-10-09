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
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("assets/tela_01_1.jpg"),
                    fit: BoxFit.cover),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 40, left: 10),
              child: Align(
                alignment: Alignment.topLeft,
                child: Image.asset('assets/inicio_texto1.png', width: 300,),
              ),
            )
          ],
        ),
      ),
    );
  }
}
