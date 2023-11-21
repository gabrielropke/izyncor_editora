import 'package:flutter/material.dart';

class texto_editado extends StatelessWidget {
  final Color corTexto;
  const texto_editado({super.key, required this.corTexto});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 5),
      child: Text(
        '[Editado]',
        style: TextStyle(
            fontSize: 12, fontWeight: FontWeight.w500, color: corTexto),
      ),
    );
  }
}
