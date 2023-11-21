import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:editora_izyncor_app/interior_usuario/homepage/feed/comentarios/comentarios_postagem.dart';
import 'package:flutter/material.dart';

class icone_comentar extends StatefulWidget {
  final String idUsuarioLogado;
  final String autorId;
  final String usernameAutor;
  final String idPostagem;
  final String legenda;
  final String titulo;
  final String imagemUrl;
  final Color corBotao;
  final Color corTexto;
  const icone_comentar(
      {super.key,
      required this.idUsuarioLogado,
      required this.autorId,
      required this.usernameAutor,
      required this.idPostagem,
      required this.legenda,
      required this.titulo,
      required this.imagemUrl,
      required this.corBotao,
      required this.corTexto});

  @override
  State<icone_comentar> createState() => _icone_comentarState();
}

class _icone_comentarState extends State<icone_comentar> {
  late List<Map<String, dynamic>> postagens;
  late String idUsuarioLogado;
  late String autorId;
  late String usernameAutor;
  late String idPostagem;
  late String legenda;
  late String titulo;
  late String imagemUrl;
  late Color corBotao;
  late Color corTexto;

  fetchFeed() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('feed').get();
    List<Map<String, dynamic>> novasPostagens = [];

    for (var doc in querySnapshot.docs) {
      Map<String, dynamic> postagensData = {
        'imagemUrl': doc.get('imagemUrl'),
        'idPostagem': doc.get('idPostagem'),
        'autorId': doc.get('autorId'),
        'hora': doc.get('hora'),
        'curtidas': doc.get('curtidas'),
        'comentarios': doc.get('comentarios'),
        'legenda': doc.get('legenda'),
        'titulo': doc.get('titulo'),
        'editado': doc.get('editado'),
      };

      // Consulta para obter o nome do autor com base no 'autorId'
      DocumentSnapshot autorSnapshot = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(doc.get('autorId'))
          .get();

      postagensData['nome'] = autorSnapshot.get('nome');
      postagensData['urlImagem'] = autorSnapshot.get('urlImagem');
      postagensData['sobrenome'] = autorSnapshot.get('sobrenome');
      postagensData['Cadastro'] = autorSnapshot.get('Cadastro');
      postagensData['seguidores'] = autorSnapshot.get('seguidores');
      postagensData['biografia'] = autorSnapshot.get('biografia');
      postagensData['username'] = autorSnapshot.get('username');

      novasPostagens.add(postagensData);
    }

    novasPostagens.sort((a, b) {
      DateTime dateTimeA = DateTime.parse(a['hora']);
      DateTime dateTimeB = DateTime.parse(b['hora']);
      return dateTimeB.compareTo(dateTimeA);
    });

    setState(() {
      postagens = novasPostagens;
    });
  }

  @override
  void initState() {
    super.initState();
    idUsuarioLogado = widget.idUsuarioLogado;
    autorId = widget.autorId;
    usernameAutor = widget.usernameAutor;
    idPostagem = widget.idPostagem;
    legenda = widget.legenda;
    titulo = widget.titulo;
    imagemUrl = widget.imagemUrl;
    corBotao = widget.corBotao;
    corTexto = widget.corTexto;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: ((context) =>
                comentarios_postagem(idPostagem: idPostagem)),
          ),
        );
      },
      child: SizedBox(
        width: 40,
        height: 50,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SizedBox(
                width: 23, child: Image.asset('assets/comentar_branco.png', color: corBotao,)),
            const SizedBox(height: 5),
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('feed')
                  .doc(idPostagem) // Use o título como ID do documento
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Text(
                    '0', // Ou qualquer outro valor padrão
                    style: TextStyle(
                      fontSize: 14,
                      color: corTexto,
                    ),
                  );
                }

                final comentarios = snapshot.data!.get('comentarios');
                return Text(
                  '$comentarios',
                  style: TextStyle(
                    fontSize: 14,
                    color: corTexto,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
