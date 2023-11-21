import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class icone_curtir extends StatefulWidget {
  final String idUsuarioLogado;
  final String autorId;
  final String usernameAutor;
  final String idPostagem;
  final String legenda;
  final String titulo;
  final String imagemUrl;
  final Color corBotao;
  final Color corTexto;
  final String perfilAutor;
  const icone_curtir(
      {super.key,
      required this.idUsuarioLogado,
      required this.autorId,
      required this.usernameAutor,
      required this.idPostagem,
      required this.legenda,
      required this.titulo,
      required this.imagemUrl,
      required this.corBotao,
      required this.corTexto,
      required this.perfilAutor});

  @override
  State<icone_curtir> createState() => _icone_curtirState();
}

class _icone_curtirState extends State<icone_curtir> {
  FirebaseAuth auth = FirebaseAuth.instance;
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
  late String perfilAutor;
  late String nome;
  late String sobrenome;
  late String username;
  late String perfilLogado;



  Future<void> recuperarDadosUsuario() async {
    User? usuarioLogado = auth.currentUser;
    if (usuarioLogado != null) {
      idUsuarioLogado = usuarioLogado.uid;
      DocumentSnapshot<Map<String, dynamic>> userData = await FirebaseFirestore
          .instance
          .collection('usuarios')
          .doc(idUsuarioLogado)
          .get();
      if (userData.exists) {
        setState(() {
          nome = userData['nome'];
          sobrenome = userData['sobrenome'];
          username = userData['username'];
          perfilLogado = userData['urlImagem'];
        });
      }
    }
  }

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

  void enviarNotificacao() {
    CollectionReference usuariosCollection =
        FirebaseFirestore.instance.collection('usuarios');

    DocumentReference usuarioRef = usuariosCollection.doc(autorId);

    usuarioRef.collection('notificacoes').add({
      'username': username,
      'idUsuario': idUsuarioLogado,
      'mensagem': 'curtiu sua publicação.',
      'hora': DateTime.now().toString(),
      'postagem': imagemUrl,
      'idPostagem': idPostagem,
      'perfil': perfilLogado,
    });
  }

  @override
  void initState() {
    super.initState();
    recuperarDadosUsuario();
    idUsuarioLogado = widget.idUsuarioLogado;
    autorId = widget.autorId;
    usernameAutor = widget.usernameAutor;
    idPostagem = widget.idPostagem;
    legenda = widget.legenda;
    titulo = widget.titulo;
    imagemUrl = widget.imagemUrl;
    corBotao = widget.corBotao;
    corTexto = widget.corTexto;
    perfilAutor = widget.perfilAutor;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
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
              enviarNotificacao();
            }
          });
        }

        enviarCurtida(idPostagem);
      },
      child: SizedBox(
        width: 40,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('feed')
                  .doc(idPostagem)
                  .collection('curtir')
                  .doc(idUsuarioLogado)
                  .snapshots(),
              builder: (context, snapshot) {
                bool usuarioCurtiu = snapshot.hasData && snapshot.data!.exists;

                return AnimatedContainer(
                  curve: usuarioCurtiu ? Curves.elasticOut : Curves.linear,
                  duration: Duration(milliseconds: usuarioCurtiu ? 1100 : 0),
                  width: usuarioCurtiu ? 37 : 21,
                  child: usuarioCurtiu
                      ? Image.asset('assets/coracao_02.png')
                      : Image.asset('assets/coracao_01_branco.png',
                          color: corBotao),
                );
              },
            ),
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

                final curtidas = snapshot.data!.get('curtidas');
                return Text(
                  '$curtidas',
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
