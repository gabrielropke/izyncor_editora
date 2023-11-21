import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class post_imagens extends StatefulWidget {
  final String idUsuarioLogado;
  final String autorId;
  final String usernameAutor;
  final String idPostagem;
  final String legenda;
  final String titulo;
  final String imagemUrl;
  final Color corBotao;
  const post_imagens(
      {super.key,
      required this.idUsuarioLogado,
      required this.autorId,
      required this.usernameAutor,
      required this.idPostagem,
      required this.legenda,
      required this.titulo,
      required this.imagemUrl,
      required this.corBotao});

  @override
  State<post_imagens> createState() => _post_imagensState();
}

class _post_imagensState extends State<post_imagens> {
  late List<Map<String, dynamic>> postagens;
  late String idUsuarioLogado;
  late String autorId;
  late String usernameAutor;
  late String idPostagem;
  late String legenda;
  late String titulo;
  late String imagemUrl;
  late Color corBotao;

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
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: () {
        void enviarCurtida(String titulo) {
          CollectionReference novidadesCollection =
              FirebaseFirestore.instance.collection('feed');

          // Verificar se o idUsuarioLogado já existe na coleção de curtir
          novidadesCollection
              .doc(idPostagem)
              .collection('curtir')
              .doc(idUsuarioLogado)
              .get()
              .then((doc) {
            if (doc.exists) {
              // O usuário já curtiu, então remova a curtida
              doc.reference.delete().then((_) {
                // Atualize o campo 'curtidas' na novidade (reduza em 1)
                novidadesCollection.doc(idPostagem).update({
                  'curtidas': FieldValue.increment(
                      -1), // Reduz o contador de curtidas em 1
                });
              });
            } else {
              // O usuário ainda não curtiu, adicione a curtida
              Map<String, dynamic> curtidaData = {
                'hora': DateTime.now().toString(),
                'uidusuario': idUsuarioLogado,
              };

              // Adicione a curtida na coleção 'curtir' da novidade
              novidadesCollection
                  .doc(idPostagem)
                  .collection('curtir')
                  .doc(idUsuarioLogado)
                  .set(curtidaData)
                  .then((_) {
                // Atualize o campo 'curtidas' na novidade (aumente em 1)
                novidadesCollection.doc(idPostagem).update({
                  'curtidas': FieldValue.increment(
                      1), // Incrementa o contador de curtidas
                });
              });
            }
          });
                }

        enviarCurtida(idPostagem);
      },
      child: CachedNetworkImage(imageUrl: imagemUrl),
    );
  }
}
