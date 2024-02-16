import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class imagens_chat extends StatelessWidget {
  const imagens_chat(
      {super.key,
      required this.remetente,
      required this.idUsuarioLogado,
      required this.idUsuarioDestino,
      required this.mensagem});

  final String remetente;
  final String idUsuarioLogado;
  final String idUsuarioDestino;
  final String mensagem;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Opacity(
          opacity: 0.6,
          child: Container(
            width: 206,
            height: 176,
            decoration: BoxDecoration(
              color: remetente == idUsuarioLogado
                  ? mensagem == 'Mensagem apagada'
                      ? Colors.white54
                      : const Color.fromARGB(255, 146, 18, 57)
                  : mensagem == 'Mensagem apagada'
                      ? Colors.white54
                      : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: remetente == idUsuarioLogado
                    ? const Radius.circular(32)
                    : const Radius.circular(32),
                bottomLeft: remetente == idUsuarioLogado
                    ? const Radius.circular(32)
                    : const Radius.circular(2),
                bottomRight: const Radius.circular(32),
                topRight: remetente == idUsuarioLogado
                    ? const Radius.circular(2)
                    : const Radius.circular(32),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 3, left: 3),
          child: ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: remetente == idUsuarioLogado
                  ? const Radius.circular(29)
                  : const Radius.circular(29),
              bottomLeft: remetente == idUsuarioLogado
                  ? const Radius.circular(29)
                  : const Radius.circular(2),
              bottomRight: const Radius.circular(29),
              topRight: remetente == idUsuarioLogado
                  ? const Radius.circular(2)
                  : const Radius.circular(29),
            ),
            child: GestureDetector(
              onTap: () {
                  Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => telacheia(
                      imagemUrl: mensagem,
                    )));
              },
              child: SizedBox(
                width: 200,
                height: 170,
                child: CachedNetworkImage(
                  imageUrl: mensagem,
                  fit: BoxFit.cover,
                ),
              ),
              
            ),
          ),
        ),
      ],
    );
  }
}

class telacheia extends StatelessWidget {
  final String imagemUrl;

  telacheia({required this.imagemUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        child: Center(
          child: Hero(
            tag: imagemUrl, // Use a mesma tag para a miniatura e a tela cheia
            child: PhotoView(
              imageProvider: NetworkImage(imagemUrl),
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.covered * 2,
            ),
          ),
        ),
        onTap: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}