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
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("assets/tela_03_1.jpg"), fit: BoxFit.cover),
            ),
          ),
          const SafeArea(
            child: Padding(
              padding: EdgeInsets.only(top: 35, left: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Explore nossas',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 26,
                          color: Color.fromARGB(255, 122, 108, 108))),
                  Text('possibilidades!',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 40,
                          color: Color.fromARGB(255, 122, 108, 108))),
                  SizedBox(height: 30),
                  Padding(
                    padding: EdgeInsets.only(right: 100),
                    child: Text(
                        'Seja qual for o seu estilo, nosso mmundo tem possibilidade spara você, pois Izyncor tem espaço para abrigar os mais diversos estilos autorais.',
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
