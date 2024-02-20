import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:editora_izyncor_app/interior_usuario/homepage/feed/comentarios/respostas_comentario_postagem.dart';
import 'package:editora_izyncor_app/interior_usuario/homepage/feed/denuncias/denunciar.dart';
import 'package:editora_izyncor_app/interior_usuario/perfil/meu_perfil.dart';
import 'package:editora_izyncor_app/interior_usuario/perfil_visita/perfil_visita.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:readmore/readmore.dart';

class comentarios_postagem extends StatefulWidget {
  final String idPostagem;

  const comentarios_postagem({Key? key, required this.idPostagem})
      : super(key: key);

  @override
  _comentarios_postagemState createState() => _comentarios_postagemState();
}

class _comentarios_postagemState extends State<comentarios_postagem> {
  late String idPostagem;
  String? novoComentarioId;
  late List<Map<String, dynamic>> comentarios;

  TextEditingController comentarioController = TextEditingController();
  List<Map<String, dynamic>> comentariosLocais = [];

  String? _idUsuarioComentado;
  String? uidUsuario;
  String imagemPerfil = '';

  Future<void> recuperarDadosUsuario() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? usuarioLogado = auth.currentUser;
    _idUsuarioComentado = usuarioLogado?.uid;
    DocumentSnapshot<Map<String, dynamic>> userData = await FirebaseFirestore
        .instance
        .collection('usuarios')
        .doc(_idUsuarioComentado)
        .get();
    if (userData.exists) {
      setState(() {
        imagemPerfil = userData['urlImagem'];
      });
    }
  }

  Future<String?> getUidUsuario(String idPostagem) async {
    try {
      DocumentReference livroRef =
          FirebaseFirestore.instance.collection('feed').doc(idPostagem);

      QuerySnapshot comentariosSnapshot =
          await livroRef.collection('comentar').get();

      comentariosSnapshot.docs.forEach((doc) {
        uidUsuario = doc['autorId'];
      });
    } catch (e) {
      print('Erro ao obter o UID do usuário: $e');
    }

    return uidUsuario;
  }

  Future<Map<String, String>?> getUserData(String uid) async {
    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(uid)
          .get();

      if (userSnapshot.exists) {
        String nome = userSnapshot.get('nome');
        String urlImagem = userSnapshot.get('urlImagem');
        return {
          'nome': nome,
          'urlImagem': urlImagem,
        };
      } else {
        return null;
      }
    } catch (e) {
      print('Erro ao obter os dados do usuário: $e');
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    idPostagem = widget.idPostagem;
    comentarioController = TextEditingController();
    recuperarDadosUsuario();
    getUidUsuario(idPostagem).then((value) {
      setState(() {
        uidUsuario = value;
      });
      // Carrega os comentários da postagem
      getComentariosDaPostagem(idPostagem).then((comentarios) {
        setState(() {
          this.comentarios = comentarios;
        });
      });
    });
  }

  @override
  void dispose() {
    comentarioController.dispose();
    super.dispose();
  }

  void enviarAvaliacao() {
    String comentario = comentarioController.text;
    if (comentario.isNotEmpty) {
      if (_idUsuarioComentado != null) {
        CollectionReference novidadesCollection =
            FirebaseFirestore.instance.collection('feed');

        // Adicione o comentário na coleção 'comentar' da novidade
        DocumentReference novoComentarioRef = novidadesCollection
            .doc(idPostagem)
            .collection('comentar')
            .doc(); // Cria uma nova referência de documento

        // Atualize a variável novoComentarioId com o ID do novo comentário
        novoComentarioId = novoComentarioRef.id;

        novoComentarioRef.set({
          'texto': comentario,
          'ref': novoComentarioId,
          'hora': DateTime.now().toString(),
          'uidusuario': _idUsuarioComentado,
          'curtidas': 0,
          'respostas': 0,
        }).then((_) {
          novidadesCollection.doc(idPostagem).update({
            'comentarios': FieldValue.increment(1),
          });

          // Use setState para atualizar a página
          setState(() {
            // Atualize o estado do widget
          });

          comentarioController.clear();
        });
      }
    }
  }

  String formatarHora(String hora) {
    DateTime agora = DateTime.now();
    DateTime horaEnviada = DateTime.parse(hora);

    Duration diferenca = agora.difference(horaEnviada);

    if (diferenca.inSeconds < 60) {
      return 'Agora mesmo';
    } else if (diferenca.inMinutes < 60) {
      return 'há ${diferenca.inMinutes} minutos';
    } else if (diferenca.inHours < 24) {
      return 'há ${diferenca.inHours} horas';
    } else if (diferenca.inDays < 365) {
      return 'há ${diferenca.inDays} dias';
    } else {
      int anos = diferenca.inDays ~/ 365;
      return 'há $anos ${anos == 1 ? 'ano' : 'anos'}';
    }
  }

  Future<List<Map<String, dynamic>>> getComentariosDaPostagem(
      String idPostagem) async {
    try {
      QuerySnapshot comentariosSnapshot = await FirebaseFirestore.instance
          .collection('feed')
          .doc(idPostagem)
          .collection('comentar')
          .get();

      List<Map<String, dynamic>> comentarios = [];

      comentariosSnapshot.docs.forEach((doc) {
        comentarios.add(doc.data() as Map<String, dynamic>);
      });

      return comentarios;
    } catch (e) {
      print('Erro ao obter os comentários da postagem: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        foregroundColor: Colors.black,
        elevation: 0,
        leadingWidth: 26,
        backgroundColor: Colors.transparent,
        title: const Text('Comentários'),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: getComentariosDaPostagem(idPostagem),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator(color: Colors.white);
                } else if (snapshot.hasError) {
                  return const Text("Erro ao carregar dados do Firestore");
                } else if (snapshot.data!.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.public, color: Colors.black12, size: 82),
                        Text(
                          'Nenhum comentário ainda... :(',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black26,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      var comentario = snapshot.data![index];

                      String refComentario = comentario['ref'];
                      var autorId = comentario['uidusuario'];
                      String texto = comentario['texto'];
                      String hora = comentario['hora'];
                      String uidUsuario = comentario['uidusuario'];

                      return FutureBuilder<Map<String, String>?>(
                        future: getUserData(
                            autorId), // Use a função para obter os dados do usuário
                        builder: (context, userSnapshot) {
                          if (userSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            // Se os dados do usuário estão carregando, exiba um indicador de progresso
                            return const CircularProgressIndicator(
                              color: Colors.white,
                            );
                          } else if (userSnapshot.hasError) {
                            // Se ocorrer um erro ao carregar os dados do usuário, trate o erro
                            return const Text(
                                "Erro ao carregar dados do usuário");
                          } else {
                            if (userSnapshot.data != null) {
                              String? urlImagem =
                                  userSnapshot.data!['urlImagem'];
                              String userName = userSnapshot.data!['nome']!;

                              return GestureDetector(
                                onDoubleTap: () {
                                  void enviarCurtida(String titulo) {
                                    if (_idUsuarioComentado != null) {
                                      CollectionReference novidadesCollection =
                                          FirebaseFirestore.instance
                                              .collection('feed');

                                      // Verificar se o idUsuarioLogado já existe na coleção de curtir
                                      novidadesCollection
                                          .doc(idPostagem)
                                          .collection('comentar')
                                          .doc(refComentario)
                                          .collection('curtirComentario')
                                          .doc(_idUsuarioComentado)
                                          .get()
                                          .then((doc) {
                                        if (doc.exists) {
                                          // O usuário já curtiu, então remova a curtida
                                          doc.reference.delete().then((_) {
                                            // Atualize o campo 'curtidas' na novidade (reduza em 1)
                                            novidadesCollection
                                                .doc(idPostagem)
                                                .collection('comentar')
                                                .doc(refComentario)
                                                .update({
                                              'curtidas': FieldValue.increment(
                                                  -1), // Reduz o contador de curtidas em 1
                                            });
                                          });
                                        } else {
                                          // O usuário ainda não curtiu, adicione a curtida
                                          Map<String, dynamic> curtidaData = {
                                            'hora': DateTime.now().toString(),
                                            'uidusuario': _idUsuarioComentado,
                                          };

                                          // Adicione a curtida na coleção 'curtir' da novidade
                                          novidadesCollection
                                              .doc(idPostagem)
                                              .collection('comentar')
                                              .doc(refComentario)
                                              .collection('curtirComentario')
                                              .doc(_idUsuarioComentado)
                                              .set(curtidaData)
                                              .then((_) {
                                            // Atualize o campo 'curtidas' na novidade (aumente em 1)
                                            novidadesCollection
                                                .doc(idPostagem)
                                                .collection('comentar')
                                                .doc(refComentario)
                                                .update({
                                              'curtidas': FieldValue.increment(
                                                  1), // Incrementa o contador de curtidas
                                            });
                                          });
                                        }
                                      });
                                    }
                                  }

                                  enviarCurtida(idPostagem);
                                },
                                onLongPress: () {
                                  showModalBottomSheet(
                                    context: context,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(
                                            20.0), // Defina o raio para bordas arredondadas superiores
                                      ),
                                    ),
                                    builder: (BuildContext context) {
                                      return Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Center(
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 10),
                                              child: Container(
                                                width: 40,
                                                height: 4,
                                                decoration: BoxDecoration(
                                                    color: Colors.black38,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12)),
                                              ),
                                            ),
                                          ),
                                          if (_idUsuarioComentado == autorId)
                                            ListTile(
                                              leading: SizedBox(
                                                  width: 25,
                                                  child: Image.asset(
                                                      'assets/lixeira.png')),
                                              title: const Text('Excluir'),
                                              onTap: () {
                                                FirebaseFirestore.instance
                                                    .collection('feed')
                                                    .doc(idPostagem)
                                                    .collection('comentar')
                                                    .doc(refComentario)
                                                    .delete()
                                                    .then((_) {
                                                  FirebaseFirestore.instance
                                                      .collection('feed')
                                                      .doc(idPostagem)
                                                      .update({
                                                    'comentarios':
                                                        FieldValue.increment(
                                                            -1),
                                                  });
                                                });
                                                // Lógica de copiar URL
                                                Navigator.pop(context);
                                              },
                                            ),
                                          if (_idUsuarioComentado != autorId)
                                            ListTile(
                                              leading: SizedBox(
                                                  width: 30,
                                                  child: Image.asset(
                                                      'assets/denunciar_01.png')),
                                              title: const Text(
                                                'Denunciar',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.red),
                                              ),
                                              onTap: () {
                                                // Lógica de copiar URL
                                                Navigator.pop(context);
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            denunciar(
                                                              idPostagem:
                                                                  refComentario,
                                                              autor: autorId,
                                                              nomeAutor:
                                                                  userName,
                                                            )));
                                              },
                                            ),
                                          if (Platform.isIOS)
                                            const SizedBox(
                                              width: double.infinity,
                                              height: 40,
                                            )
                                        ],
                                      );
                                    },
                                  );
                                },
                                child: Container(
                                  width: double.infinity,
                                  color: Colors.white,
                                  child: ListTile(
                                    leading: GestureDetector(
                                      onTap: () {
                                        if (uidUsuario != _idUsuarioComentado) {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      perfil_visita(
                                                          uidPerfil: uidUsuario,
                                                          nome: userName,
                                                          imagemPerfil:
                                                              urlImagem,
                                                          sobrenome: 'nulo',
                                                          cadastro: 'nulo')));
                                        } else {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      const perfil()));
                                        }
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.only(top: 5),
                                        child: Container(
                                          width: 48,
                                          height: 48,
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                          ),
                                          child: ClipOval(
                                            child: CachedNetworkImage(
                                              imageUrl: urlImagem!,
                                              placeholder: (context, url) =>
                                                  const CircularProgressIndicator(
                                                color: Colors.white,
                                              ),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    title: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  userName,
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                const Text(
                                                  ' • ',
                                                  style: TextStyle(
                                                      color: Colors.grey),
                                                ),
                                                Text(
                                                  formatarHora(hora),
                                                  style: const TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                void enviarCurtida(
                                                    String titulo) {
                                                  if (_idUsuarioComentado !=
                                                      null) {
                                                    CollectionReference
                                                        novidadesCollection =
                                                        FirebaseFirestore
                                                            .instance
                                                            .collection('feed');

                                                    // Verificar se o idUsuarioLogado já existe na coleção de curtir
                                                    novidadesCollection
                                                        .doc(idPostagem)
                                                        .collection('comentar')
                                                        .doc(refComentario)
                                                        .collection(
                                                            'curtirComentario')
                                                        .doc(
                                                            _idUsuarioComentado)
                                                        .get()
                                                        .then((doc) {
                                                      if (doc.exists) {
                                                        // O usuário já curtiu, então remova a curtida
                                                        doc.reference
                                                            .delete()
                                                            .then((_) {
                                                          // Atualize o campo 'curtidas' na novidade (reduza em 1)
                                                          novidadesCollection
                                                              .doc(idPostagem)
                                                              .collection(
                                                                  'comentar')
                                                              .doc(
                                                                  refComentario)
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
                                                              _idUsuarioComentado,
                                                        };

                                                        // Adicione a curtida na coleção 'curtir' da novidade
                                                        novidadesCollection
                                                            .doc(idPostagem)
                                                            .collection(
                                                                'comentar')
                                                            .doc(refComentario)
                                                            .collection(
                                                                'curtirComentario')
                                                            .doc(
                                                                _idUsuarioComentado)
                                                            .set(curtidaData)
                                                            .then((_) {
                                                          // Atualize o campo 'curtidas' na novidade (aumente em 1)
                                                          novidadesCollection
                                                              .doc(idPostagem)
                                                              .collection(
                                                                  'comentar')
                                                              .doc(
                                                                  refComentario)
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

                                                enviarCurtida(idPostagem);
                                              },
                                              child: Column(
                                                children: [
                                                  StreamBuilder<
                                                      DocumentSnapshot>(
                                                    stream: FirebaseFirestore
                                                        .instance
                                                        .collection('feed')
                                                        .doc(idPostagem)
                                                        .collection('comentar')
                                                        .doc(refComentario)
                                                        .collection(
                                                            'curtirComentario')
                                                        .doc(
                                                            _idUsuarioComentado)
                                                        .snapshots(),
                                                    builder:
                                                        (context, snapshot) {
                                                      bool usuarioCurtiu =
                                                          snapshot.hasData &&
                                                              snapshot
                                                                  .data!.exists;

                                                      return AnimatedContainer(
                                                        curve: usuarioCurtiu
                                                            ? Curves.elasticOut
                                                            : Curves.linear,
                                                        duration: Duration(
                                                            milliseconds:
                                                                usuarioCurtiu
                                                                    ? 1100
                                                                    : 0),
                                                        width: usuarioCurtiu
                                                            ? 37
                                                            : 21,
                                                        child: usuarioCurtiu
                                                            ? Image.asset(
                                                                'assets/coracao_02.png')
                                                            : Image.asset(
                                                                'assets/coracao_04.png'),
                                                      );
                                                    },
                                                  ),
                                                  StreamBuilder<
                                                      DocumentSnapshot>(
                                                    stream: FirebaseFirestore
                                                        .instance
                                                        .collection('feed')
                                                        .doc(idPostagem)
                                                        .collection('comentar')
                                                        .doc(refComentario)
                                                        .snapshots(),
                                                    builder:
                                                        (context, snapshot) {
                                                      if (!snapshot.hasData) {
                                                        return const Text(
                                                          '0',
                                                          style: TextStyle(
                                                              fontSize: 12,
                                                              color:
                                                                  Colors.grey,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        );
                                                      }

                                                      final curtidas = snapshot
                                                          .data!
                                                          .get('curtidas');
                                                      return Text('$curtidas',
                                                          style: const TextStyle(
                                                              fontSize: 12,
                                                              color:
                                                                  Colors.grey,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold));
                                                    },
                                                  ),
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                        Wrap(
                                          children: [
                                            ReadMoreText(
                                              texto,
                                              trimLines: 2,
                                              colorClickableText: Colors.blue,
                                              trimMode: TrimMode.Line,
                                              trimCollapsedText: 'ver mais',
                                              trimExpandedText: ' ver menos',
                                              moreStyle: const TextStyle(
                                                color: Colors.black26,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                              lessStyle: const TextStyle(
                                                color: Colors.black26,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.w400,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: ((context) =>
                                                        respostas_comentario_postagem(
                                                            uidUsuario:
                                                                uidUsuario,
                                                            refComentario:
                                                                refComentario,
                                                            idPostagem:
                                                                idPostagem,
                                                            texto: texto,
                                                            hora: hora,
                                                            imageUrl:
                                                                urlImagem)),
                                                  ),
                                                );
                                              },
                                              child: const Text(
                                                'Responder',
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                            StreamBuilder<DocumentSnapshot>(
                                              stream: FirebaseFirestore.instance
                                                  .collection('feed')
                                                  .doc(idPostagem)
                                                  .collection('comentar')
                                                  .doc(refComentario)
                                                  .snapshots(),
                                              builder: (context, snapshot) {
                                                if (!snapshot.hasData) {
                                                  return const Text(
                                                      '0', // Ou qualquer outro valor padrão
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.grey,
                                                          fontWeight:
                                                              FontWeight.bold));
                                                }

                                                final respostas = snapshot.data!
                                                    .get('respostas');
                                                return respostas == 0
                                                    ? const SizedBox.shrink()
                                                    : GestureDetector(
                                                        onTap: () {
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: ((context) => respostas_comentario_postagem(
                                                                  uidUsuario:
                                                                      uidUsuario,
                                                                  refComentario:
                                                                      refComentario,
                                                                  idPostagem:
                                                                      idPostagem,
                                                                  texto: texto,
                                                                  hora: hora,
                                                                  imageUrl:
                                                                      urlImagem)),
                                                            ),
                                                          );
                                                        },
                                                        child: Text(
                                                            '  -  Ver $respostas respostas',
                                                            style: const TextStyle(
                                                                fontSize: 12,
                                                                color:
                                                                    Colors.grey,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold)),
                                                      );
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            } else {
                              // Trate o caso em que os dados do usuário não foram encontrados
                              return const Text(
                                  "Dados do usuário não encontrados");
                            }
                          }
                        },
                      );
                    },
                  );
                }
              },
            ),
          ),
          Padding(
            padding: Platform.isAndroid
                ? const EdgeInsets.all(12)
                : const EdgeInsets.only(left: 12, right: 12, bottom: 35),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Expanded(
                child: TextField(
                  controller: comentarioController,
                  maxLines: null,
                  textAlign: TextAlign.left,
                  keyboardType: TextInputType.text,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color.fromARGB(255, 0, 0, 0),
                  ),
                  decoration: InputDecoration(
                    suffixIcon: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: IconButton(
                        color: const Color.fromARGB(255, 46, 43, 43),
                        onPressed: enviarAvaliacao,
                        icon: Opacity(
                          opacity: 0.6,
                          child: SizedBox(
                            width: 30,
                            height: 30,
                            child: Image.asset('assets/enviar_3.png',
                                color: const Color.fromARGB(
                                    255, 212, 18, 99)),
                          ),
                        ),
                      ),
                    ),
                    contentPadding:
                        const EdgeInsets.fromLTRB(10.0, 25.0, 35.0, 10.0),
                    hintText: "Deixe seu comentário...",
                    hintStyle: const TextStyle(
                      color: Color.fromARGB(255, 124, 124, 124),
                    ),
                    filled: true,
                    fillColor: const Color.fromARGB(255, 243, 243, 243),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.all(Radius.circular(32)),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Color.fromARGB(255, 206, 38, 88)),
                      borderRadius: BorderRadius.all(Radius.circular(32)),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
