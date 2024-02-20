import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class icone_salvar extends StatefulWidget {
  final String idUsuarioLogado;
  final String autorId;
  final String usernameAutor;
  final String idPostagem;
  final String legenda;
  final String titulo;
  final String imagemUrl;
  final Color corBotao;
  final Color corTexto;
  const icone_salvar(
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
  State<icone_salvar> createState() => _icone_salvarState();
}

class _icone_salvarState extends State<icone_salvar> {
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

  void addClasseSalvos() async {
    CollectionReference usuariosCollection =
        FirebaseFirestore.instance.collection('usuarios');

    DocumentReference usuarioRef = usuariosCollection.doc(idUsuarioLogado);

    DocumentSnapshot snapshot =
        await usuarioRef.collection('salvos').doc(idPostagem).get();

    if (snapshot.exists) {
      await usuarioRef.collection('salvos').doc(idPostagem).delete();
    } else {
      await usuarioRef.collection('salvos').doc(idPostagem).set({
        'idPostagem': idPostagem,
        'imagemUrl': imagemUrl,
        'idAutor': autorId,
        'titulo': titulo,
        'hora': DateTime.now().toString(),
      });
    }
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
        void salvarPost(String titulo) {
          FirebaseFirestore.instance
              .collection('salvos')
              .doc(idUsuarioLogado)
              .collection('meus_salvos')
              .doc(idPostagem) // Use idPostagem como o ID do documento
              .get()
              .then((doc) {
            if (doc.exists) {
              // O documento já existe na coleção, então exclua-o
              doc.reference.delete();
            } else {
              // O documento não existe na coleção, então adicione-o
              FirebaseFirestore.instance
                  .collection('salvos')
                  .doc(idUsuarioLogado)
                  .collection('meus_salvos')
                  .doc(idPostagem)
                  .set({
                'idPostagem': idPostagem,
                'hora': DateTime.now().toString()
              });
            }
          });

          CollectionReference novidadesCollection =
              FirebaseFirestore.instance.collection('feed');

          // Verificar se o idUsuarioLogado já existe na coleção de curtir
          novidadesCollection
              .doc(idPostagem)
              .collection('salvar')
              .doc(idUsuarioLogado)
              .get()
              .then((doc) {
            if (doc.exists) {
              // O usuário já curtiu, então remova a curtida
              doc.reference.delete().then((_) {
                // Atualize o campo 'curtidas' na novidade (reduza em 1)
                novidadesCollection.doc(idPostagem).update({
                  'salvos': FieldValue.increment(
                      -1), // Reduz o contador de curtidas em 1
                });
              });
            } else {
              // O usuário ainda não curtiu, adicione a curtida
              Map<String, dynamic> salvarPost = {
                'hora': DateTime.now().toString(),
                'uidusuario': idUsuarioLogado,
              };

              // Adicione a curtida na coleção 'curtir' da novidade
              novidadesCollection
                  .doc(idPostagem)
                  .collection('salvar')
                  .doc(idUsuarioLogado)
                  .set(salvarPost)
                  .then((_) {
                // Atualize o campo 'curtidas' na novidade (aumente em 1)
                novidadesCollection.doc(idPostagem).update({
                  'salvos': FieldValue.increment(
                      1), // Incrementa o contador de curtidas
                });
              });
            }
          });
                }

        salvarPost(idPostagem);
        addClasseSalvos();
      },
      child: SizedBox(
        width: 40,
        height: 50,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('feed')
                  .doc(idPostagem)
                  .collection('salvar')
                  .doc(idUsuarioLogado)
                  .snapshots(),
              builder: (context, snapshot) {
                bool usuarioCurtiu = snapshot.hasData && snapshot.data!.exists;

                return AnimatedContainer(
                  curve: usuarioCurtiu ? Curves.elasticOut : Curves.linear,
                  duration: Duration(milliseconds: usuarioCurtiu ? 700 : 0),
                  width: usuarioCurtiu ? 22 : 23,
                  child: usuarioCurtiu
                      ? Image.asset(
                          'assets/disquete_08_branco.png',
                          color: corBotao,
                        )
                      : Image.asset(
                          'assets/salvar01_icone.png',
                          color: corBotao,
                        ),
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

                final salvos = snapshot.data!.get('salvos');
                return Text(
                  '$salvos',
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
