import 'package:flutter/material.dart';

class assuntos_item extends StatelessWidget {
  const assuntos_item({super.key, required this.assunto});

  final String assunto;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 40,
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
              width: 2, color: const Color.fromARGB(255, 185, 20, 89)),
          borderRadius: BorderRadius.circular(32)),
      child: Center(
        child: Text(assunto, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),),
      ),
    );
  }
}
