import 'package:cached_network_image/cached_network_image.dart';
import 'package:editora_izyncor_app/interior_usuario/chat/chat_mensagem/widget_chat/icone_more_chat.dart';
import 'package:editora_izyncor_app/interior_usuario/perfil_visita/perfil_visita.dart';
import 'package:flutter/material.dart';

class appbar_chat extends StatelessWidget implements PreferredSizeWidget {
  appbar_chat({
    Key? key,
    required this.idUsuarioDestino,
    required this.nomeDestino,
    required this.imagemPerfilDestino,
    required this.sobrenomeDestino,
    required this.idUsuarioLogado,
    required this.usernameDestino,
  }) : super(key: key);

  final String idUsuarioDestino;
  final String nomeDestino;
  final String imagemPerfilDestino;
  final String sobrenomeDestino;
  final String idUsuarioLogado;
  final String usernameDestino;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      leadingWidth: 25,
      backgroundColor: const Color.fromARGB(255, 236, 236, 236),
      foregroundColor: Colors.black,
      actions: [
        icone_more_chat(
          idUsuarioLogado: idUsuarioLogado,
          idUsuarioDestino: idUsuarioDestino,
          imagemPerfil: imagemPerfilDestino,
          usernameDestino: usernameDestino,
        )
      ],
      title: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => perfil_visita(
                uidPerfil: idUsuarioDestino,
                nome: nomeDestino,
                imagemPerfil: imagemPerfilDestino,
                sobrenome: sobrenomeDestino,
                cadastro: '',
              ),
            ),
          );
        },
        child: Row(
          children: <Widget>[
            Container(
              width: 45,
              height: 45,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: CachedNetworkImage(
                  fit: BoxFit.cover,
                  imageUrl: imagemPerfilDestino,
                  placeholder: (context, url) =>
                      const CircularProgressIndicator(
                    color: Colors.white,
                  ),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Text(
                "$nomeDestino $sobrenomeDestino",
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
