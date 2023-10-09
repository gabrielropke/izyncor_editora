import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:editora_izyncor_app/interior_usuario/homepage/feed/comentarios/comentarios_postagem.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:readmore/readmore.dart';

class salvos extends StatefulWidget {
  const salvos({Key? key}) : super(key: key);

  @override
  State<salvos> createState() => _salvosState();
}

class _salvosState extends State<salvos> {
  FirebaseAuth auth = FirebaseAuth.instance;
  String? idUsuarioLogado;
  List<DocumentSnapshot<Map<String, dynamic>>> meusSalvos = [];
  String imagemPerfil = '';

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
          imagemPerfil = userData['urlImagem'];
        });
      }
    }
  }

  Future<void> carregarMeusSalvos() async {
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore
        .instance
        .collection('salvos')
        .doc(idUsuarioLogado)
        .collection('meus_salvos')
        .get();

    setState(() {
      meusSalvos = querySnapshot.docs;
    });
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

  @override
  void initState() {
    super.initState();
    recuperarDadosUsuario();
    meusSalvos = [];
    carregarMeusSalvos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: meusSalvos.length,
        itemBuilder: (BuildContext context, int index) {
          DocumentSnapshot<Map<String, dynamic>> documento = meusSalvos[index];
          String idPostagem = documento['idPostagem'];

          return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            future: FirebaseFirestore.instance
                .collection('feed')
                .doc(idPostagem)
                .get(),
            builder: (BuildContext context,
                AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>>
                    snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator(
                  color: Colors.white,
                ); // Ou outro indicador de carregamento
              }
              if (snapshot.hasError) {
                return Text('Erro: ${snapshot.error}');
              }
              if (!snapshot.hasData || !snapshot.data!.exists) {
                return Text(
                    'Nenhuma postagem encontrada com o ID: $idPostagem');
              }

              // Postagem encontrada, agora você pode acessar a 'legenda'
              String imagemUrl = snapshot.data!['imagemUrl'];
              String idPostagemFeed = snapshot.data!['idPostagem'];
              String autorId = snapshot.data!['autorId'];
              String hora = snapshot.data!['hora'];
              String legenda = snapshot.data!['legenda'];
              String titulo = snapshot.data!['titulo'];

              // Aqui você pode criar o ListTile com os dados do documento
              return Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      Column(
                        children: [
                          Visibility(
                            visible: imagemUrl == 'vazio',
                            child: Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 5),
                                    child: Text(
                                      titulo,
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Visibility(
                              visible:
                                  imagemUrl != 'vazio',
                              child: Stack(
                                children: [
                                  GestureDetector(
                                    onDoubleTap: () {
                                      void enviarCurtida(String titulo) {
                                        if (idUsuarioLogado != null) {
                                          CollectionReference
                                              novidadesCollection =
                                              FirebaseFirestore.instance
                                                  .collection('feed');

                                          // Verificar se o idUsuarioLogado já existe na coleção de curtir
                                          novidadesCollection
                                              .doc(idPostagemFeed)
                                              .collection('curtir')
                                              .doc(idUsuarioLogado)
                                              .get()
                                              .then((doc) {
                                            if (doc.exists) {
                                              // O usuário já curtiu, então remova a curtida
                                              doc.reference.delete().then((_) {
                                                // Atualize o campo 'curtidas' na novidade (reduza em 1)
                                                novidadesCollection
                                                    .doc(idPostagemFeed)
                                                    .update({
                                                  'curtidas': FieldValue.increment(
                                                      -1), // Reduz o contador de curtidas em 1
                                                });
                                              });
                                            } else {
                                              // O usuário ainda não curtiu, adicione a curtida
                                              Map<String, dynamic> curtidaData =
                                                  {
                                                'hora':
                                                    DateTime.now().toString(),
                                                'uidusuario': idUsuarioLogado,
                                              };

                                              // Adicione a curtida na coleção 'curtir' da novidade
                                              novidadesCollection
                                                  .doc(idPostagemFeed)
                                                  .collection('curtir')
                                                  .doc(idUsuarioLogado)
                                                  .set(curtidaData)
                                                  .then((_) {
                                                // Atualize o campo 'curtidas' na novidade (aumente em 1)
                                                novidadesCollection
                                                    .doc(idPostagemFeed)
                                                    .update({
                                                  'curtidas': FieldValue.increment(
                                                      1), // Incrementa o contador de curtidas
                                                });
                                              });
                                            }
                                          });
                                        }
                                      }

                                      enviarCurtida(idPostagemFeed);
                                    },
                                    child: Image.network(imagemUrl),
                                  ),
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
                                                  imageUrl: imagemPerfil,
                                                  placeholder: (context, url) =>
                                                      const CircularProgressIndicator(
                                                    color: Colors.white,
                                                  ),
                                                  errorWidget: (context, url,
                                                          error) =>
                                                      const Icon(Icons.error),
                                                ),
                                              ),
                                            ),
                                            Visibility(
                                              visible:
                                                  autorId != idUsuarioLogado,
                                              child: Positioned(
                                                bottom: 0,
                                                right: 0,
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                      color: Colors.white,
                                                      width: 2,
                                                    ),
                                                  ),
                                                  child: ClipOval(
                                                    child: Material(
                                                      color:
                                                          const Color.fromARGB(
                                                              255, 202, 30, 82),
                                                      child: InkWell(
                                                        onTap: () {
                                                          void seguirUsuario(
                                                              String titulo) {
                                                            if (idUsuarioLogado !=
                                                                null) {
                                                              CollectionReference
                                                                  novidadesCollection =
                                                                  FirebaseFirestore
                                                                      .instance
                                                                      .collection(
                                                                          'usuarios');

                                                              // Verificar se o idUsuarioLogado já existe na coleção de curtir
                                                              novidadesCollection
                                                                  .doc(autorId)
                                                                  .collection(
                                                                      'seguidores')
                                                                  .doc(
                                                                      idUsuarioLogado)
                                                                  .get()
                                                                  .then((doc) {
                                                                if (doc
                                                                    .exists) {
                                                                  doc.reference
                                                                      .delete()
                                                                      .then(
                                                                          (_) {
                                                                    novidadesCollection
                                                                        .doc(
                                                                            autorId)
                                                                        .update({
                                                                      'seguidores':
                                                                          FieldValue.increment(
                                                                              -1),
                                                                    });
                                                                  });
                                                                } else {
                                                                  Map<String,
                                                                          dynamic>
                                                                      seguidoresData =
                                                                      {
                                                                    'hora': DateTime
                                                                            .now()
                                                                        .toString(),
                                                                    'uidusuario':
                                                                        idUsuarioLogado,
                                                                  };

                                                                  novidadesCollection
                                                                      .doc(
                                                                          autorId)
                                                                      .collection(
                                                                          'seguidores')
                                                                      .doc(
                                                                          idUsuarioLogado)
                                                                      .set(
                                                                          seguidoresData)
                                                                      .then(
                                                                          (_) {
                                                                    novidadesCollection
                                                                        .doc(
                                                                            autorId)
                                                                        .update({
                                                                      'seguidores':
                                                                          FieldValue.increment(
                                                                              1),
                                                                    });
                                                                  });
                                                                }
                                                              });
                                                            }
                                                          }

                                                          seguirUsuario(
                                                              autorId);
                                                        },
                                                        child: SizedBox(
                                                          width: 20,
                                                          height: 20,
                                                          child: StreamBuilder<
                                                              DocumentSnapshot>(
                                                            stream: FirebaseFirestore
                                                                .instance
                                                                .collection(
                                                                    'usuarios')
                                                                .doc(autorId)
                                                                .collection(
                                                                    'seguidores')
                                                                .doc(
                                                                    idUsuarioLogado)
                                                                .snapshots(),
                                                            builder: (context,
                                                                snapshot) {
                                                              if (!snapshot
                                                                      .hasData ||
                                                                  !snapshot
                                                                      .data!
                                                                      .exists) {
                                                                // Se não houver dados (usuário não curtiu), mostre o ícone de coração vazio
                                                                return const Icon(
                                                                  Icons.add,
                                                                  color: Colors
                                                                      .white,
                                                                  size: 16,
                                                                );
                                                              }

                                                              // Se houver dados (usuário já curtiu), mostre o ícone de coração cheio
                                                              return const Icon(
                                                                Icons.check,
                                                                color: Colors
                                                                    .white,
                                                                size:
                                                                    16, // Ou qualquer outra cor desejada
                                                              );
                                                            },
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                        const SizedBox(width: 8),
                                        StreamBuilder<DocumentSnapshot>(
                                          stream: FirebaseFirestore.instance
                                              .collection('usuarios')
                                              .doc(
                                                  autorId) // Use o título como ID do documento
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

                                            final nomeAutor =
                                                snapshot.data!.get('nome');
                                            return Text(
                                              '$nomeAutor',
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.white,
                                                  fontSize: 16),
                                            );
                                          },
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
                                                  void enviarCurtida(
                                                      String titulo) {
                                                    if (idUsuarioLogado !=
                                                        null) {
                                                      CollectionReference
                                                          novidadesCollection =
                                                          FirebaseFirestore
                                                              .instance
                                                              .collection(
                                                                  'feed');

                                                      // Verificar se o idUsuarioLogado já existe na coleção de curtir
                                                      novidadesCollection
                                                          .doc(idPostagemFeed)
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
                                                                .doc(
                                                                    idPostagemFeed)
                                                                .update({
                                                              'curtidas': FieldValue
                                                                  .increment(
                                                                      -1), // Reduz o contador de curtidas em 1
                                                            });
                                                          });
                                                        } else {
                                                          // O usuário ainda não curtiu, adicione a curtida
                                                          Map<String, dynamic>
                                                              curtidaData = {
                                                            'hora':
                                                                DateTime.now()
                                                                    .toString(),
                                                            'uidusuario':
                                                                idUsuarioLogado,
                                                          };

                                                          // Adicione a curtida na coleção 'curtir' da novidade
                                                          novidadesCollection
                                                              .doc(
                                                                  idPostagemFeed)
                                                              .collection(
                                                                  'curtir')
                                                              .doc(
                                                                  idUsuarioLogado)
                                                              .set(curtidaData)
                                                              .then((_) {
                                                            // Atualize o campo 'curtidas' na novidade (aumente em 1)
                                                            novidadesCollection
                                                                .doc(
                                                                    idPostagemFeed)
                                                                .update({
                                                              'curtidas': FieldValue
                                                                  .increment(
                                                                      1), // Incrementa o contador de curtidas
                                                            });
                                                          });
                                                        }
                                                      });
                                                    }
                                                  }

                                                  enviarCurtida(idPostagemFeed);
                                                },
                                                child: StreamBuilder<
                                                    DocumentSnapshot>(
                                                  stream: FirebaseFirestore
                                                      .instance
                                                      .collection('feed')
                                                      .doc(idPostagemFeed)
                                                      .collection('curtir')
                                                      .doc(idUsuarioLogado)
                                                      .snapshots(),
                                                  builder: (context, snapshot) {
                                                    if (!snapshot.hasData ||
                                                        !snapshot
                                                            .data!.exists) {
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
                                                stream: FirebaseFirestore
                                                    .instance
                                                    .collection('feed')
                                                    .doc(
                                                        idPostagemFeed) // Use o título como ID do documento
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

                                                  final curtidas = snapshot
                                                      .data!
                                                      .get('curtidas');
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
                                                              idPostagem:
                                                                  idPostagemFeed)),
                                                    ),
                                                  );
                                                },
                                                child: const Icon(
                                                    Icons.comment_outlined,
                                                    color: Colors.white),
                                              ),
                                              StreamBuilder<DocumentSnapshot>(
                                                stream: FirebaseFirestore
                                                    .instance
                                                    .collection('feed')
                                                    .doc(
                                                        idPostagemFeed) // Use o título como ID do documento
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

                                                  final comentarios = snapshot
                                                      .data!
                                                      .get('comentarios');
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
                                                  void salvarPost(
                                                      String titulo) {
                                                    if (idUsuarioLogado !=
                                                        null) {
                                                      FirebaseFirestore.instance
                                                          .collection('salvos')
                                                          .doc(idUsuarioLogado)
                                                          .collection(
                                                              'meus_salvos')
                                                          .doc(
                                                              idPostagemFeed) // Use idPostagemFeed como o ID do documento
                                                          .get()
                                                          .then((doc) {
                                                        if (doc.exists) {
                                                          // O documento já existe na coleção, então exclua-o
                                                          doc.reference
                                                              .delete();
                                                        } else {
                                                          // O documento não existe na coleção, então adicione-o
                                                          FirebaseFirestore
                                                              .instance
                                                              .collection(
                                                                  'salvos')
                                                              .doc(
                                                                  idUsuarioLogado)
                                                              .collection(
                                                                  'meus_salvos')
                                                              .doc(
                                                                  idPostagemFeed)
                                                              .set({
                                                            'idPostagem':
                                                                idPostagemFeed,
                                                            'hora':
                                                                DateTime.now()
                                                                    .toString()
                                                          });
                                                        }
                                                      });

                                                      CollectionReference
                                                          novidadesCollection =
                                                          FirebaseFirestore
                                                              .instance
                                                              .collection(
                                                                  'feed');

                                                      // Verificar se o idUsuarioLogado já existe na coleção de curtir
                                                      novidadesCollection
                                                          .doc(idPostagemFeed)
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
                                                                .doc(
                                                                    idPostagemFeed)
                                                                .update({
                                                              'salvos': FieldValue
                                                                  .increment(
                                                                      -1), // Reduz o contador de curtidas em 1
                                                            });
                                                          });
                                                        } else {
                                                          // O usuário ainda não curtiu, adicione a curtida
                                                          Map<String, dynamic>
                                                              salvarPost = {
                                                            'hora':
                                                                DateTime.now()
                                                                    .toString(),
                                                            'uidusuario':
                                                                idUsuarioLogado,
                                                          };

                                                          // Adicione a curtida na coleção 'curtir' da novidade
                                                          novidadesCollection
                                                              .doc(
                                                                  idPostagemFeed)
                                                              .collection(
                                                                  'salvar')
                                                              .doc(
                                                                  idUsuarioLogado)
                                                              .set(salvarPost)
                                                              .then((_) {
                                                            // Atualize o campo 'curtidas' na novidade (aumente em 1)
                                                            novidadesCollection
                                                                .doc(
                                                                    idPostagemFeed)
                                                                .update({
                                                              'salvos': FieldValue
                                                                  .increment(
                                                                      1), // Incrementa o contador de curtidas
                                                            });
                                                          });
                                                        }
                                                      });
                                                    }
                                                  }

                                                  salvarPost(idPostagemFeed);
                                                },
                                                child: StreamBuilder<
                                                    DocumentSnapshot>(
                                                  stream: FirebaseFirestore
                                                      .instance
                                                      .collection('feed')
                                                      .doc(idPostagemFeed)
                                                      .collection('salvar')
                                                      .doc(idUsuarioLogado)
                                                      .snapshots(),
                                                  builder: (context, snapshot) {
                                                    if (!snapshot.hasData ||
                                                        !snapshot
                                                            .data!.exists) {
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
                                                stream: FirebaseFirestore
                                                    .instance
                                                    .collection('feed')
                                                    .doc(
                                                        idPostagemFeed) // Use o título como ID do documento
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

                                                  final salvos = snapshot.data!
                                                      .get('salvos');
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
                                legenda,
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
                            visible: imagemUrl == 'vazio',
                            child: Padding(
                              padding: const EdgeInsets.only(top: 20),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                                  imageUrl: imagemPerfil,
                                                  placeholder: (context, url) =>
                                                      const CircularProgressIndicator(
                                                    color: Colors.white,
                                                  ),
                                                  errorWidget: (context, url,
                                                          error) =>
                                                      const Icon(Icons.error),
                                                ),
                                              ),
                                            ),
                                            Visibility(
                                              visible:
                                                  autorId != idUsuarioLogado,
                                              child: Positioned(
                                                bottom: 0,
                                                right: 0,
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                      color: Colors.white,
                                                      width: 2,
                                                    ),
                                                  ),
                                                  child: ClipOval(
                                                    child: Material(
                                                      color:
                                                          const Color.fromARGB(
                                                              255, 202, 30, 82),
                                                      child: InkWell(
                                                        onTap: () {
                                                          void seguirUsuario(
                                                              String titulo) {
                                                            if (idUsuarioLogado !=
                                                                null) {
                                                              CollectionReference
                                                                  novidadesCollection =
                                                                  FirebaseFirestore
                                                                      .instance
                                                                      .collection(
                                                                          'usuarios');

                                                              // Verificar se o idUsuarioLogado já existe na coleção de curtir
                                                              novidadesCollection
                                                                  .doc(autorId)
                                                                  .collection(
                                                                      'seguidores')
                                                                  .doc(
                                                                      idUsuarioLogado)
                                                                  .get()
                                                                  .then((doc) {
                                                                if (doc
                                                                    .exists) {
                                                                  doc.reference
                                                                      .delete()
                                                                      .then(
                                                                          (_) {
                                                                    novidadesCollection
                                                                        .doc(
                                                                            autorId)
                                                                        .update({
                                                                      'seguidores':
                                                                          FieldValue.increment(
                                                                              -1),
                                                                    });
                                                                  });
                                                                } else {
                                                                  Map<String,
                                                                          dynamic>
                                                                      seguidoresData =
                                                                      {
                                                                    'hora': DateTime
                                                                            .now()
                                                                        .toString(),
                                                                    'uidusuario':
                                                                        idUsuarioLogado,
                                                                  };

                                                                  novidadesCollection
                                                                      .doc(
                                                                          autorId)
                                                                      .collection(
                                                                          'seguidores')
                                                                      .doc(
                                                                          idUsuarioLogado)
                                                                      .set(
                                                                          seguidoresData)
                                                                      .then(
                                                                          (_) {
                                                                    novidadesCollection
                                                                        .doc(
                                                                            autorId)
                                                                        .update({
                                                                      'seguidores':
                                                                          FieldValue.increment(
                                                                              1),
                                                                    });
                                                                  });
                                                                }
                                                              });
                                                            }
                                                          }

                                                          seguirUsuario(
                                                              autorId);
                                                        },
                                                        child: SizedBox(
                                                          width: 20,
                                                          height: 20,
                                                          child: StreamBuilder<
                                                              DocumentSnapshot>(
                                                            stream: FirebaseFirestore
                                                                .instance
                                                                .collection(
                                                                    'usuarios')
                                                                .doc(autorId)
                                                                .collection(
                                                                    'seguidores')
                                                                .doc(
                                                                    idUsuarioLogado)
                                                                .snapshots(),
                                                            builder: (context,
                                                                snapshot) {
                                                              if (!snapshot
                                                                      .hasData ||
                                                                  !snapshot
                                                                      .data!
                                                                      .exists) {
                                                                // Se não houver dados (usuário não curtiu), mostre o ícone de coração vazio
                                                                return const Icon(
                                                                  Icons.add,
                                                                  color: Colors
                                                                      .white,
                                                                  size: 16,
                                                                );
                                                              }

                                                              // Se houver dados (usuário já curtiu), mostre o ícone de coração cheio
                                                              return const Icon(
                                                                Icons.check,
                                                                color: Colors
                                                                    .white,
                                                                size:
                                                                    16, // Ou qualquer outra cor desejada
                                                              );
                                                            },
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      StreamBuilder<DocumentSnapshot>(
                                          stream: FirebaseFirestore.instance
                                              .collection('usuarios')
                                              .doc(
                                                  autorId) // Use o título como ID do documento
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
                                      
                                            final nomeAutor =
                                                snapshot.data!.get('nome');
                                            return Text(
                                              '$nomeAutor',
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.black,
                                                  fontSize: 16),
                                            );
                                          },
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
                                                void enviarCurtida(
                                                    String titulo) {
                                                  if (idUsuarioLogado != null) {
                                                    CollectionReference
                                                        novidadesCollection =
                                                        FirebaseFirestore
                                                            .instance
                                                            .collection('feed');

                                                    // Verificar se o idUsuarioLogado já existe na coleção de curtir
                                                    novidadesCollection
                                                        .doc(idPostagemFeed)
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
                                                              .doc(
                                                                  idPostagemFeed)
                                                              .update({
                                                            'curtidas': FieldValue
                                                                .increment(
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
                                                            .doc(idPostagemFeed)
                                                            .collection(
                                                                'curtir')
                                                            .doc(
                                                                idUsuarioLogado)
                                                            .set(curtidaData)
                                                            .then((_) {
                                                          // Atualize o campo 'curtidas' na novidade (aumente em 1)
                                                          novidadesCollection
                                                              .doc(
                                                                  idPostagemFeed)
                                                              .update({
                                                            'curtidas': FieldValue
                                                                .increment(
                                                                    1), // Incrementa o contador de curtidas
                                                          });
                                                        });
                                                      }
                                                    });
                                                  }
                                                }

                                                enviarCurtida(idPostagemFeed);
                                              },
                                              child: StreamBuilder<
                                                  DocumentSnapshot>(
                                                stream: FirebaseFirestore
                                                    .instance
                                                    .collection('feed')
                                                    .doc(idPostagemFeed)
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
                                                  .doc(
                                                      idPostagemFeed) // Use o título como ID do documento
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

                                                final curtidas = snapshot.data!
                                                    .get('curtidas');
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
                                                            idPostagem:
                                                                idPostagemFeed)),
                                                  ),
                                                );
                                              },
                                              child: const Icon(
                                                  Icons.comment_outlined,
                                                  color: Colors.black),
                                            ),
                                            StreamBuilder<DocumentSnapshot>(
                                              stream: FirebaseFirestore.instance
                                                  .collection('feed')
                                                  .doc(
                                                      idPostagemFeed) // Use o título como ID do documento
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

                                                final comentarios = snapshot
                                                    .data!
                                                    .get('comentarios');
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
                                                        .collection(
                                                            'meus_salvos')
                                                        .doc(
                                                            idPostagemFeed) // Use idPostagemFeed como o ID do documento
                                                        .get()
                                                        .then((doc) {
                                                      if (doc.exists) {
                                                        // O documento já existe na coleção, então exclua-o
                                                        doc.reference.delete();
                                                      } else {
                                                        // O documento não existe na coleção, então adicione-o
                                                        FirebaseFirestore
                                                            .instance
                                                            .collection(
                                                                'salvos')
                                                            .doc(
                                                                idUsuarioLogado)
                                                            .collection(
                                                                'meus_salvos')
                                                            .doc(idPostagemFeed)
                                                            .set({
                                                          'idPostagem':
                                                              idPostagemFeed,
                                                          'hora': DateTime.now()
                                                              .toString()
                                                        });
                                                      }
                                                    });

                                                    CollectionReference
                                                        novidadesCollection =
                                                        FirebaseFirestore
                                                            .instance
                                                            .collection('feed');

                                                    // Verificar se o idUsuarioLogado já existe na coleção de curtir
                                                    novidadesCollection
                                                        .doc(idPostagemFeed)
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
                                                              .doc(
                                                                  idPostagemFeed)
                                                              .update({
                                                            'salvos': FieldValue
                                                                .increment(
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
                                                            .doc(idPostagemFeed)
                                                            .collection(
                                                                'salvar')
                                                            .doc(
                                                                idUsuarioLogado)
                                                            .set(salvarPost)
                                                            .then((_) {
                                                          // Atualize o campo 'curtidas' na novidade (aumente em 1)
                                                          novidadesCollection
                                                              .doc(
                                                                  idPostagemFeed)
                                                              .update({
                                                            'salvos': FieldValue
                                                                .increment(
                                                                    1), // Incrementa o contador de curtidas
                                                          });
                                                        });
                                                      }
                                                    });
                                                  }
                                                }

                                                salvarPost(idPostagemFeed);
                                              },
                                              child: StreamBuilder<
                                                  DocumentSnapshot>(
                                                stream: FirebaseFirestore
                                                    .instance
                                                    .collection('feed')
                                                    .doc(idPostagemFeed)
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
                                                  .doc(
                                                      idPostagemFeed) // Use o título como ID do documento
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

                                                final salvos = snapshot.data!
                                                    .get('salvos');
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
                                formatDataHora(hora),
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
                    ],
                  ));
            },
          );
        },
      ),
    );
  }
}
