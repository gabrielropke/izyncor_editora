import 'package:flutter/material.dart';

class lista_widgets_drawer extends StatelessWidget {
  const lista_widgets_drawer(
      {super.key, required this.icone_drawer, required this.titulo_drawer});

  final String icone_drawer;
  final String titulo_drawer;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 35,
      color: Colors.white,
      child: Row(
        children: [
          SizedBox(
            width: 22,
            child: Image.asset(icone_drawer),
          ),
          const SizedBox(width: 17),
          Text(titulo_drawer,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color.fromARGB(255, 58, 56, 56))),
        ],
      ),
    );
  }
}
