import 'dart:io';

import 'package:flutter/material.dart';

class anexos_chat extends StatelessWidget {
  const anexos_chat({super.key});

  void caixaOpcoes(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
        top: Radius.circular(20.0),
      )),
      backgroundColor: Color.fromARGB(255, 239, 239, 248),
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: Colors.black38,
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                icone_container(
                    icone: 'assets/galeria.png',
                    corIcone: Colors.blue,
                    textoItem: 'Galeria'),
                icone_container(
                    icone: 'assets/camera2.png',
                    corIcone: Colors.orange,
                    textoItem: 'Câmera'),
                icone_container(
                    icone: 'assets/anexo2.png',
                    corIcone: Colors.pink,
                    textoItem: 'Arquivos'),
              ],
            ),
            const SizedBox(height: 40),
            if (Platform.isIOS)
              const SizedBox(
                width: double.infinity,
                height: 40,
              )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        caixaOpcoes(context);
      },
      child: Opacity(
        opacity: 0.6,
        child: Image.asset(
          'assets/anexo.png',
          scale: 3,
        ),
      ),
    );
  }
}

class icone_container extends StatelessWidget {
  const icone_container(
      {super.key,
      required this.icone,
      required this.corIcone,
      required this.textoItem});

  final String textoItem;
  final String icone;
  final Color corIcone;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 60,
          height: 60,
          decoration:
              const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          child: SizedBox(
            child: Image.asset(
              icone,
              scale: 2,
              color: corIcone,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          textoItem,
          style: const TextStyle(
              fontWeight: FontWeight.w400, color: Colors.black54),
        )
      ],
    );
  }
}
