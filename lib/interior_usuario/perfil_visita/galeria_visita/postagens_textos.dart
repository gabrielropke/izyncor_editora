import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:editora_izyncor_app/interior_usuario/homepage/feed/comentarios/comentarios_postagem.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:readmore/readmore.dart';

class postagens_textos_visita extends StatefulWidget {
  final String autoId;
  const postagens_textos_visita({super.key, required this.autoId});

  @override
  State<postagens_textos_visita> createState() => _postagens_textos_visitaState();
}

class _postagens_textos_visitaState extends State<postagens_textos_visita> {
  FirebaseAuth auth = FirebaseAuth.instance;

  late List<Map<String, dynamic>> postagens;
  String? idUsuarioLogado;
  late String autorId;

  recuperarDadosUsuario() {
    User? usuarioLogado = auth.currentUser;
    if (usuarioLogado != null) {
      idUsuarioLogado = usuarioLogado.uid;
    }
  }

  String formatDataHora(String dateTimeString) {
    DateTime now = DateTime.now();
    DateTime dateTime = DateTime.parse(dateTimeString);
    Duration difference = now.difference(dateTime);

    if (difference < Duration(minutes: 1)) {
      return 'Agora mesmo';
    } else if (difference < Duration(hours: 1)) {
      return 'Há ${difference.inMinutes} minutos';
    } else if (difference < Duration(days: 1)) {
      return 'Há ${difference.inHours} horas';
    } else if (difference < Duration(days: 30)) {
      return 'Há ${difference.inDays} dias';
    } else if (difference < Duration(days: 365)) {
      int months = difference.inDays ~/ 30;
      return 'Há $months ${months == 1 ? 'mês' : 'meses'}';
    } else {
      int years = difference.inDays ~/ 365;
      return 'Há $years ${years == 1 ? 'ano' : 'anos'}';
    }
  }

  void fetchFeed() async {
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
        'titulo': doc.get('titulo')
      };

      // Consulta para obter o nome do autor com base no 'autorId'
      DocumentSnapshot autorSnapshot = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(doc.get('autorId'))
          .get();

      postagensData['nome'] = autorSnapshot.get('nome');
      postagensData['urlImagem'] = autorSnapshot.get('urlImagem');

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
    recuperarDadosUsuario();
    postagens = [];
    fetchFeed();
    autorId = widget.autoId;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView.builder(
        itemCount: postagens.length,
        itemBuilder: (context, index) {
          var postagem = postagens[index];

          return Visibility(
            visible: postagem['autorId'] == autorId &&
                postagem['imagemUrl'] == 'vazio',
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  Visibility(
                    visible: postagem['imagemUrl'] != null &&
                        postagem['imagemUrl'] == 'vazio',
                    child: Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 5),
                            child: Text(
                              postagem['titulo'],
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              GestureDetector(
                                  onTap: () {
                                        void verItem(BuildContext context) {
                                          showModalBottomSheet(
                                            context: context,
                                            shape: const RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.vertical(
                                                top: Radius.circular(
                                                    20.0), // Defina o raio para bordas arredondadas superiores
                                              ),
                                            ),
                                            builder: (BuildContext context) {
                                              return Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: <Widget>[
                                                  Center(
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 10),
                                                      child: Container(
                                                        width: 40,
                                                        height: 4,
                                                        decoration: BoxDecoration(
                                                            color:
                                                                Colors.black38,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        12)),
                                                      ),
                                                    ),
                                                  ),
                                                  ListTile(
                                                    leading: const Icon(
                                                      Icons.copy,
                                                      color: Colors.black,
                                                    ),
                                                    title: const Text(
                                                        'Copiar url'),
                                                    onTap: () {
                                                      // Lógica de copiar URL
                                                      Navigator.pop(context);
                                                    },
                                                  ),
                                                  ListTile(
                                                    leading: const Icon(
                                                      Icons.warning_amber_outlined,
                                                      color: Colors.black,
                                                    ),
                                                    title:
                                                        const Text('Denunciar'),
                                                    onTap: () {
                                                      // Lógica de copiar URL
                                                      Navigator.pop(context);
                                                    },
                                                  ),
                                                  Visibility(
                                                    visible:
                                                        postagem['autorId'] ==
                                                            idUsuarioLogado,
                                                    child: ListTile(
                                                      leading: const Icon(
                                                        Icons.delete_outline_sharp,
                                                        color: Colors.black,
                                                      ),
                                                      title:
                                                          const Text('Excluir'),
                                                      onTap: () async {
                                                        void excluirPost(
                                                            String titulo) {
                                                          if (postagem[
                                                                  'autorId'] ==
                                                              idUsuarioLogado) {
                                                            CollectionReference
                                                                novidadesCollection =
                                                                FirebaseFirestore
                                                                    .instance
                                                                    .collection(
                                                                        'feed');

                                                            // Excluir o documento do Firestore
                                                            novidadesCollection
                                                                .doc(postagem[
                                                                    'idPostagem'])
                                                                .delete();

                                                            FirebaseFirestore
                                                                .instance
                                                                .collection(
                                                                    'usuarios')
                                                                .doc(
                                                                    idUsuarioLogado)
                                                                .update({
                                                              'postagens':
                                                                  FieldValue
                                                                      .increment(
                                                                          -1),
                                                            });

                                                            setState(() {
                                                              postagens.removeWhere(
                                                                  (postagem) =>
                                                                      postagem[
                                                                          'idPostagem'] ==
                                                                      postagem[
                                                                          'idPostagem']);
                                                            });
                                                            // Chamar fetchFeed novamente após a exclusão
                                                            fetchFeed();
                                                          }
                                                        }

                                                        excluirPost(postagem[
                                                            'idPostagem']);

                                                        // Lógica de copiar URL
                                                        Navigator.pop(context);
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        }

                                        verItem(context);
                                      },
                                  child: const Icon(Icons.more_horiz,
                                      color: Colors.black, size: 26)),
                              const SizedBox(width: 10),
                              const Icon(Icons.share_rounded,
                                  color: Colors.black)
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Visibility(
                      visible: postagem['imagemUrl'] != null &&
                          postagem['imagemUrl'] != 'vazio',
                      child: Stack(
                        children: [
                          GestureDetector(
                            onDoubleTap: () {
                              void enviarCurtida(String titulo) {
                                if (idUsuarioLogado != null) {
                                  CollectionReference novidadesCollection =
                                      FirebaseFirestore.instance
                                          .collection('feed');

                                  // Verificar se o idUsuarioLogado já existe na coleção de curtir
                                  novidadesCollection
                                      .doc(postagem['idPostagem'])
                                      .collection('curtir')
                                      .doc(idUsuarioLogado)
                                      .get()
                                      .then((doc) {
                                    if (doc.exists) {
                                      // O usuário já curtiu, então remova a curtida
                                      doc.reference.delete().then((_) {
                                        // Atualize o campo 'curtidas' na novidade (reduza em 1)
                                        novidadesCollection
                                            .doc(postagem['idPostagem'])
                                            .update({
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
                                          .doc(postagem['idPostagem'])
                                          .collection('curtir')
                                          .doc(idUsuarioLogado)
                                          .set(curtidaData)
                                          .then((_) {
                                        // Atualize o campo 'curtidas' na novidade (aumente em 1)
                                        novidadesCollection
                                            .doc(postagem['idPostagem'])
                                            .update({
                                          'curtidas': FieldValue.increment(
                                              1), // Incrementa o contador de curtidas
                                        });
                                      });
                                    }
                                  });
                                }
                              }

                              enviarCurtida(postagem['idPostagem']);
                            },
                            child: Image.network(postagem['imagemUrl']),
                          ),
                          Positioned(
                              top: 10,
                              right: 10,
                              child: Row(
                                children: [
                                  GestureDetector(
                                      onTap: () {
                                        void verItem(BuildContext context) {
                                          showModalBottomSheet(
                                            context: context,
                                            shape: const RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.vertical(
                                                top: Radius.circular(
                                                    20.0), // Defina o raio para bordas arredondadas superiores
                                              ),
                                            ),
                                            builder: (BuildContext context) {
                                              return Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: <Widget>[
                                                  Center(
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 10),
                                                      child: Container(
                                                        width: 40,
                                                        height: 4,
                                                        decoration: BoxDecoration(
                                                            color:
                                                                Colors.black38,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        12)),
                                                      ),
                                                    ),
                                                  ),
                                                  ListTile(
                                                    leading: const Icon(
                                                      Icons.copy,
                                                      color: Colors.black,
                                                    ),
                                                    title: const Text(
                                                        'Copiar url'),
                                                    onTap: () {
                                                      // Lógica de copiar URL
                                                      Navigator.pop(context);
                                                    },
                                                  ),
                                                  ListTile(
                                                    leading: const Icon(
                                                      Icons.warning_amber_outlined,
                                                      color: Colors.black,
                                                    ),
                                                    title:
                                                        const Text('Denunciar'),
                                                    onTap: () {
                                                      // Lógica de copiar URL
                                                      Navigator.pop(context);
                                                    },
                                                  ),
                                                  Visibility(
                                                    visible:
                                                        postagem['autorId'] ==
                                                            idUsuarioLogado,
                                                    child: ListTile(
                                                      leading: const Icon(
                                                        Icons.delete_outline_sharp,
                                                        color: Colors.black,
                                                      ),
                                                      title:
                                                          const Text('Excluir'),
                                                      onTap: () async {
                                                        void excluirPost(
                                                            String titulo) {
                                                          if (postagem[
                                                                  'autorId'] ==
                                                              idUsuarioLogado) {
                                                            CollectionReference
                                                                novidadesCollection =
                                                                FirebaseFirestore
                                                                    .instance
                                                                    .collection(
                                                                        'feed');

                                                            // Excluir o documento do Firestore
                                                            novidadesCollection
                                                                .doc(postagem[
                                                                    'idPostagem'])
                                                                .delete();

                                                            FirebaseFirestore
                                                                .instance
                                                                .collection(
                                                                    'usuarios')
                                                                .doc(
                                                                    idUsuarioLogado)
                                                                .update({
                                                              'postagens':
                                                                  FieldValue
                                                                      .increment(
                                                                          -1),
                                                            });

                                                            setState(() {
                                                              postagens.removeWhere(
                                                                  (postagem) =>
                                                                      postagem[
                                                                          'idPostagem'] ==
                                                                      postagem[
                                                                          'idPostagem']);
                                                            });
                                                            // Chamar fetchFeed novamente após a exclusão
                                                            fetchFeed();
                                                          }
                                                        }

                                                        excluirPost(postagem[
                                                            'idPostagem']);

                                                        // Lógica de copiar URL
                                                        Navigator.pop(context);
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        }

                                        verItem(context);
                                      },
                                      child: const Icon(Icons.more_horiz,
                                          color: Colors.white, size: 26)),
                                  const SizedBox(width: 10),
                                  const Icon(Icons.share_rounded,
                                      color: Colors.white)
                                ],
                              )),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            child: Container(
                              width: 400,
                              height: 70,
                              color: Colors.black54,
                            ),
                          ),
                          Positioned(
                            bottom: 11,
                            left: 11,
                            child: Row(
                              children: [
                                Stack(
                                  children: [
                                    Container(
                                      width: 52,
                                      height: 52,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                      ),
                                      child: ClipOval(
                                        child: CachedNetworkImage(
                                          imageUrl: postagem['urlImagem'],
                                          placeholder: (context, url) =>
                                              const CircularProgressIndicator(
                                            color: Colors.white,
                                          ),
                                          errorWidget: (context, url, error) =>
                                              const Icon(Icons.error),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  postagem['nome'],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                      fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                              bottom: 15,
                              right: 15,
                              child: Row(
                                children: [
                                  Column(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          void enviarCurtida(String titulo) {
                                            if (idUsuarioLogado != null) {
                                              CollectionReference
                                                  novidadesCollection =
                                                  FirebaseFirestore.instance
                                                      .collection('feed');

                                              // Verificar se o idUsuarioLogado já existe na coleção de curtir
                                              novidadesCollection
                                                  .doc(postagem['idPostagem'])
                                                  .collection('curtir')
                                                  .doc(idUsuarioLogado)
                                                  .get()
                                                  .then((doc) {
                                                if (doc.exists) {
                                                  // O usuário já curtiu, então remova a curtida
                                                  doc.reference
                                                      .delete()
                                                      .then((_) {
                                                    // Atualize o campo 'curtidas' na novidade (reduza em 1)
                                                    novidadesCollection
                                                        .doc(postagem[
                                                            'idPostagem'])
                                                        .update({
                                                      'curtidas':
                                                          FieldValue.increment(
                                                              -1), // Reduz o contador de curtidas em 1
                                                    });
                                                  });
                                                } else {
                                                  // O usuário ainda não curtiu, adicione a curtida
                                                  Map<String, dynamic>
                                                      curtidaData = {
                                                    'hora': DateTime.now()
                                                        .toString(),
                                                    'uidusuario':
                                                        idUsuarioLogado,
                                                  };

                                                  // Adicione a curtida na coleção 'curtir' da novidade
                                                  novidadesCollection
                                                      .doc(postagem[
                                                          'idPostagem'])
                                                      .collection('curtir')
                                                      .doc(idUsuarioLogado)
                                                      .set(curtidaData)
                                                      .then((_) {
                                                    // Atualize o campo 'curtidas' na novidade (aumente em 1)
                                                    novidadesCollection
                                                        .doc(postagem[
                                                            'idPostagem'])
                                                        .update({
                                                      'curtidas':
                                                          FieldValue.increment(
                                                              1), // Incrementa o contador de curtidas
                                                    });
                                                  });
                                                }
                                              });
                                            }
                                          }

                                          enviarCurtida(postagem['idPostagem']);
                                        },
                                        child: StreamBuilder<DocumentSnapshot>(
                                          stream: FirebaseFirestore.instance
                                              .collection('feed')
                                              .doc(postagem['idPostagem'])
                                              .collection('curtir')
                                              .doc(idUsuarioLogado)
                                              .snapshots(),
                                          builder: (context, snapshot) {
                                            if (!snapshot.hasData ||
                                                !snapshot.data!.exists) {
                                              // Se não houver dados (usuário não curtiu), mostre o ícone de coração vazio
                                              return const Icon(
                                                Icons.favorite_border,
                                                color: Colors.white,
                                              );
                                            }

                                            // Se houver dados (usuário já curtiu), mostre o ícone de coração cheio
                                            return const Icon(
                                              Icons.favorite,
                                              color: Colors
                                                  .red, // Ou qualquer outra cor desejada
                                            );
                                          },
                                        ),
                                      ),
                                      StreamBuilder<DocumentSnapshot>(
                                        stream: FirebaseFirestore.instance
                                            .collection('feed')
                                            .doc(postagem[
                                                'idPostagem']) // Use o título como ID do documento
                                            .snapshots(),
                                        builder: (context, snapshot) {
                                          if (!snapshot.hasData) {
                                            return const Text(
                                              '0', // Ou qualquer outro valor padrão
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.white,
                                              ),
                                            );
                                          }

                                          final curtidas =
                                              snapshot.data!.get('curtidas');
                                          return Text(
                                            '$curtidas',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.white,
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: ((context) =>
                                                  comentarios_postagem(
                                                      idPostagem: postagem[
                                                          'idPostagem'])),
                                            ),
                                          );
                                        },
                                        child: const Icon(
                                            Icons.comment_outlined,
                                            color: Colors.white),
                                      ),
                                      StreamBuilder<DocumentSnapshot>(
                                        stream: FirebaseFirestore.instance
                                            .collection('feed')
                                            .doc(postagem[
                                                'idPostagem']) // Use o título como ID do documento
                                            .snapshots(),
                                        builder: (context, snapshot) {
                                          if (!snapshot.hasData) {
                                            return const Text(
                                              '0', // Ou qualquer outro valor padrão
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.white,
                                              ),
                                            );
                                          }

                                          final comentarios =
                                              snapshot.data!.get('comentarios');
                                          return Text(
                                            '$comentarios',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.white,
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          void salvarPost(String titulo) {
                                            if (idUsuarioLogado != null) {
                                              FirebaseFirestore.instance
                                                  .collection('salvos')
                                                  .doc(idUsuarioLogado)
                                                  .collection('meus_salvos')
                                                  .doc(postagem[
                                                      'idPostagem']) // Use postagem['idPostagem'] como o ID do documento
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
                                                      .doc(postagem[
                                                          'idPostagem'])
                                                      .set({
                                                    'idPostagem':
                                                        postagem['idPostagem'],
                                                  });
                                                }
                                              });

                                              CollectionReference
                                                  novidadesCollection =
                                                  FirebaseFirestore.instance
                                                      .collection('feed');

                                              // Verificar se o idUsuarioLogado já existe na coleção de curtir
                                              novidadesCollection
                                                  .doc(postagem['idPostagem'])
                                                  .collection('salvar')
                                                  .doc(idUsuarioLogado)
                                                  .get()
                                                  .then((doc) {
                                                if (doc.exists) {
                                                  // O usuário já curtiu, então remova a curtida
                                                  doc.reference
                                                      .delete()
                                                      .then((_) {
                                                    // Atualize o campo 'curtidas' na novidade (reduza em 1)
                                                    novidadesCollection
                                                        .doc(postagem[
                                                            'idPostagem'])
                                                        .update({
                                                      'salvos':
                                                          FieldValue.increment(
                                                              -1), // Reduz o contador de curtidas em 1
                                                    });
                                                  });
                                                } else {
                                                  // O usuário ainda não curtiu, adicione a curtida
                                                  Map<String, dynamic>
                                                      salvarPost = {
                                                    'hora': DateTime.now()
                                                        .toString(),
                                                    'uidusuario':
                                                        idUsuarioLogado,
                                                  };

                                                  // Adicione a curtida na coleção 'curtir' da novidade
                                                  novidadesCollection
                                                      .doc(postagem[
                                                          'idPostagem'])
                                                      .collection('salvar')
                                                      .doc(idUsuarioLogado)
                                                      .set(salvarPost)
                                                      .then((_) {
                                                    // Atualize o campo 'curtidas' na novidade (aumente em 1)
                                                    novidadesCollection
                                                        .doc(postagem[
                                                            'idPostagem'])
                                                        .update({
                                                      'salvos':
                                                          FieldValue.increment(
                                                              1), // Incrementa o contador de curtidas
                                                    });
                                                  });
                                                }
                                              });
                                            }
                                          }

                                          salvarPost(postagem['idPostagem']);
                                        },
                                        child: StreamBuilder<DocumentSnapshot>(
                                          stream: FirebaseFirestore.instance
                                              .collection('feed')
                                              .doc(postagem['idPostagem'])
                                              .collection('salvar')
                                              .doc(idUsuarioLogado)
                                              .snapshots(),
                                          builder: (context, snapshot) {
                                            if (!snapshot.hasData ||
                                                !snapshot.data!.exists) {
                                              // Se não houver dados (usuário não curtiu), mostre o ícone de coração vazio
                                              return const Icon(
                                                Icons.bookmark_border,
                                                color: Colors.white,
                                              );
                                            }

                                            // Se houver dados (usuário já curtiu), mostre o ícone de coração cheio
                                            return const Icon(
                                              Icons.bookmark,
                                              color: Colors
                                                  .white, // Ou qualquer outra cor desejada
                                            );
                                          },
                                        ),
                                      ),
                                      StreamBuilder<DocumentSnapshot>(
                                        stream: FirebaseFirestore.instance
                                            .collection('feed')
                                            .doc(postagem[
                                                'idPostagem']) // Use o título como ID do documento
                                            .snapshots(),
                                        builder: (context, snapshot) {
                                          if (!snapshot.hasData) {
                                            return const Text(
                                              '0', // Ou qualquer outro valor padrão
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.white,
                                              ),
                                            );
                                          }

                                          final salvos =
                                              snapshot.data!.get('salvos');
                                          return Text(
                                            '$salvos',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.white,
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ))
                        ],
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10, left: 5),
                      child: ReadMoreText(
                        postagem['legenda'],
                        trimLines: 4,
                        colorClickableText: Colors.blue,
                        trimMode: TrimMode.Line,
                        trimCollapsedText: 'ver mais',
                        trimExpandedText: ' ver menos',
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: postagem['imagemUrl'] != null &&
                        postagem['imagemUrl'] == 'vazio',
                    child: Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 5),
                                child: Stack(
                                  children: [
                                    Container(
                                      width: 52,
                                      height: 52,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                      ),
                                      child: ClipOval(
                                        child: CachedNetworkImage(
                                          imageUrl: postagem['urlImagem'],
                                          placeholder: (context, url) =>
                                              const CircularProgressIndicator(
                                            color: Colors.white,
                                          ),
                                          errorWidget: (context, url, error) =>
                                              const Icon(Icons.error),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                postagem['nome'],
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                    fontSize: 16),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: Row(
                              children: [
                                Column(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        void enviarCurtida(String titulo) {
                                          if (idUsuarioLogado != null) {
                                            CollectionReference
                                                novidadesCollection =
                                                FirebaseFirestore.instance
                                                    .collection('feed');

                                            // Verificar se o idUsuarioLogado já existe na coleção de curtir
                                            novidadesCollection
                                                .doc(postagem['idPostagem'])
                                                .collection('curtir')
                                                .doc(idUsuarioLogado)
                                                .get()
                                                .then((doc) {
                                              if (doc.exists) {
                                                // O usuário já curtiu, então remova a curtida
                                                doc.reference
                                                    .delete()
                                                    .then((_) {
                                                  // Atualize o campo 'curtidas' na novidade (reduza em 1)
                                                  novidadesCollection
                                                      .doc(postagem[
                                                          'idPostagem'])
                                                      .update({
                                                    'curtidas':
                                                        FieldValue.increment(
                                                            -1), // Reduz o contador de curtidas em 1
                                                  });
                                                });
                                              } else {
                                                // O usuário ainda não curtiu, adicione a curtida
                                                Map<String, dynamic>
                                                    curtidaData = {
                                                  'hora':
                                                      DateTime.now().toString(),
                                                  'uidusuario': idUsuarioLogado,
                                                };

                                                // Adicione a curtida na coleção 'curtir' da novidade
                                                novidadesCollection
                                                    .doc(postagem['idPostagem'])
                                                    .collection('curtir')
                                                    .doc(idUsuarioLogado)
                                                    .set(curtidaData)
                                                    .then((_) {
                                                  // Atualize o campo 'curtidas' na novidade (aumente em 1)
                                                  novidadesCollection
                                                      .doc(postagem[
                                                          'idPostagem'])
                                                      .update({
                                                    'curtidas':
                                                        FieldValue.increment(
                                                            1), // Incrementa o contador de curtidas
                                                  });
                                                });
                                              }
                                            });
                                          }
                                        }

                                        enviarCurtida(postagem['idPostagem']);
                                      },
                                      child: StreamBuilder<DocumentSnapshot>(
                                        stream: FirebaseFirestore.instance
                                            .collection('feed')
                                            .doc(postagem['idPostagem'])
                                            .collection('curtir')
                                            .doc(idUsuarioLogado)
                                            .snapshots(),
                                        builder: (context, snapshot) {
                                          if (!snapshot.hasData ||
                                              !snapshot.data!.exists) {
                                            // Se não houver dados (usuário não curtiu), mostre o ícone de coração vazio
                                            return const Icon(
                                              Icons.favorite_border,
                                              color: Colors.black,
                                            );
                                          }

                                          // Se houver dados (usuário já curtiu), mostre o ícone de coração cheio
                                          return const Icon(
                                            Icons.favorite,
                                            color: Colors
                                                .red, // Ou qualquer outra cor desejada
                                          );
                                        },
                                      ),
                                    ),
                                    StreamBuilder<DocumentSnapshot>(
                                      stream: FirebaseFirestore.instance
                                          .collection('feed')
                                          .doc(postagem[
                                              'idPostagem']) // Use o título como ID do documento
                                          .snapshots(),
                                      builder: (context, snapshot) {
                                        if (!snapshot.hasData) {
                                          return const Text(
                                            '0', // Ou qualquer outro valor padrão
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.black,
                                            ),
                                          );
                                        }

                                        final curtidas =
                                            snapshot.data!.get('curtidas');
                                        return Text(
                                          '$curtidas',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.black,
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: ((context) =>
                                                comentarios_postagem(
                                                    idPostagem: postagem[
                                                        'idPostagem'])),
                                          ),
                                        );
                                      },
                                      child: const Icon(Icons.comment_outlined,
                                          color: Colors.black),
                                    ),
                                    StreamBuilder<DocumentSnapshot>(
                                      stream: FirebaseFirestore.instance
                                          .collection('feed')
                                          .doc(postagem[
                                              'idPostagem']) // Use o título como ID do documento
                                          .snapshots(),
                                      builder: (context, snapshot) {
                                        if (!snapshot.hasData) {
                                          return const Text(
                                            '0', // Ou qualquer outro valor padrão
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.white,
                                            ),
                                          );
                                        }

                                        final comentarios =
                                            snapshot.data!.get('comentarios');
                                        return Text(
                                          '$comentarios',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.black,
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        void salvarPost(String titulo) {
                                          if (idUsuarioLogado != null) {
                                            FirebaseFirestore.instance
                                                .collection('salvos')
                                                .doc(idUsuarioLogado)
                                                .collection('meus_salvos')
                                                .doc(postagem[
                                                    'idPostagem']) // Use postagem['idPostagem'] como o ID do documento
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
                                                    .doc(postagem['idPostagem'])
                                                    .set({
                                                  'idPostagem':
                                                      postagem['idPostagem'],
                                                });
                                              }
                                            });

                                            CollectionReference
                                                novidadesCollection =
                                                FirebaseFirestore.instance
                                                    .collection('feed');

                                            // Verificar se o idUsuarioLogado já existe na coleção de curtir
                                            novidadesCollection
                                                .doc(postagem['idPostagem'])
                                                .collection('salvar')
                                                .doc(idUsuarioLogado)
                                                .get()
                                                .then((doc) {
                                              if (doc.exists) {
                                                // O usuário já curtiu, então remova a curtida
                                                doc.reference
                                                    .delete()
                                                    .then((_) {
                                                  // Atualize o campo 'curtidas' na novidade (reduza em 1)
                                                  novidadesCollection
                                                      .doc(postagem[
                                                          'idPostagem'])
                                                      .update({
                                                    'salvos': FieldValue.increment(
                                                        -1), // Reduz o contador de curtidas em 1
                                                  });
                                                });
                                              } else {
                                                // O usuário ainda não curtiu, adicione a curtida
                                                Map<String, dynamic>
                                                    salvarPost = {
                                                  'hora':
                                                      DateTime.now().toString(),
                                                  'uidusuario': idUsuarioLogado,
                                                };

                                                // Adicione a curtida na coleção 'curtir' da novidade
                                                novidadesCollection
                                                    .doc(postagem['idPostagem'])
                                                    .collection('salvar')
                                                    .doc(idUsuarioLogado)
                                                    .set(salvarPost)
                                                    .then((_) {
                                                  // Atualize o campo 'curtidas' na novidade (aumente em 1)
                                                  novidadesCollection
                                                      .doc(postagem[
                                                          'idPostagem'])
                                                      .update({
                                                    'salvos': FieldValue.increment(
                                                        1), // Incrementa o contador de curtidas
                                                  });
                                                });
                                              }
                                            });
                                          }
                                        }

                                        salvarPost(postagem['idPostagem']);
                                      },
                                      child: StreamBuilder<DocumentSnapshot>(
                                        stream: FirebaseFirestore.instance
                                            .collection('feed')
                                            .doc(postagem['idPostagem'])
                                            .collection('salvar')
                                            .doc(idUsuarioLogado)
                                            .snapshots(),
                                        builder: (context, snapshot) {
                                          if (!snapshot.hasData ||
                                              !snapshot.data!.exists) {
                                            // Se não houver dados (usuário não curtiu), mostre o ícone de coração vazio
                                            return const Icon(
                                              Icons.bookmark_border,
                                              color: Colors.black,
                                            );
                                          }

                                          // Se houver dados (usuário já curtiu), mostre o ícone de coração cheio
                                          return const Icon(
                                            Icons.bookmark,
                                            color: Colors
                                                .black, // Ou qualquer outra cor desejada
                                          );
                                        },
                                      ),
                                    ),
                                    StreamBuilder<DocumentSnapshot>(
                                      stream: FirebaseFirestore.instance
                                          .collection('feed')
                                          .doc(postagem[
                                              'idPostagem']) // Use o título como ID do documento
                                          .snapshots(),
                                      builder: (context, snapshot) {
                                        if (!snapshot.hasData) {
                                          return const Text(
                                            '0', // Ou qualquer outro valor padrão
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.black,
                                            ),
                                          );
                                        }

                                        final salvos =
                                            snapshot.data!.get('salvos');
                                        return Text(
                                          '$salvos',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.black,
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10, left: 5),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        formatDataHora(postagem['hora']),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 35),
                    child: Container(
                      width: double.infinity,
                      height: 1,
                      color: Colors.black12,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
