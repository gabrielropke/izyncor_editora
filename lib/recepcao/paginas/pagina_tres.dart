import 'package:flutter/material.dart';

class paginatres extends StatefulWidget {
  const paginatres({super.key});

  @override
  State<paginatres> createState() => _paginatresState();
}

class _paginatresState extends State<paginatres> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("assets/tela_03_1.jpg"),
                    fit: BoxFit.cover),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 40, left: 10),
              child: Align(
                alignment: Alignment.topLeft,
                child: Image.asset('assets/inicio_texto3.png', width: 300,),
              ),
            )
          ],
        ),
      ),
    );
  }
}
