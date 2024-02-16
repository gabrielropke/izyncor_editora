import 'package:flutter/material.dart';

class mensagem_apagada extends StatelessWidget {
  const mensagem_apagada(
      {super.key,
      required this.idUsuarioLogado, required this.remetente});

  final String idUsuarioLogado;
  final String remetente;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.6,
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
            color: Colors.white54,
            borderRadius: BorderRadius.only(
                topLeft: remetente == idUsuarioLogado
                    ? const Radius.circular(32)
                    : const Radius.circular(32),
                bottomLeft: remetente == idUsuarioLogado
                    ? const Radius.circular(32)
                    : const Radius.circular(8),
                bottomRight: const Radius.circular(32),
                topRight: remetente == idUsuarioLogado
                    ? const Radius.circular(8)
                    : const Radius.circular(32))),
        child: const Align(
          alignment: Alignment.center,
          child: Wrap(
            children: [
              Text(
                'Mensagem apagada',
                style: TextStyle(
                  color: Colors.black54,
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
