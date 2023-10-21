import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:editora_izyncor_app/interior_usuario/homepage/feed/comentarios/respostas_comentario_postagem.dart';
import 'package:editora_izyncor_app/interior_usuario/perfil/meu_perfil.dart';
import 'package:editora_izyncor_app/interior_usuario/perfil_visita/perfil_visita.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
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

  TextEditingController comentarioController = TextEditingController();

  String? _idUsuarioComentado;
  String? uidUsuario;

  Future<void> recuperarDadosUsuario() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? usuarioLogado = auth.currentUser;
    _idUsuarioComentado = usuarioLogado?.uid;
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
        });
        comentarioController.clear();
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
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('feed')
                  .doc(idPostagem)
                  .collection('comentar')
                  .orderBy('hora', descending: true)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return const Text(
                    'Ocorreu um erro ao carregar os comentários',
                    style: TextStyle(fontSize: 16),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
                  return const Center(
                      child: Text(
                    'Sem comentários disponíveis...',
                    style: TextStyle(fontSize: 16),
                  ));
                }

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (BuildContext context, int index) {
                    Map<String, dynamic> comentario = snapshot.data!.docs[index]
                        .data() as Map<String, dynamic>;
                    String texto = comentario['texto'];
                    String hora = comentario['hora'];
                    String uidUsuario = comentario['uidusuario'];
                    String refComentario = comentario['ref'];

                    bool idUsuarioLogado = uidUsuario == _idUsuarioComentado;

                    return FutureBuilder<Map<String, String>?>(
                      future: getUserData(uidUsuario),
                      builder: (BuildContext context,
                          AsyncSnapshot<Map<String, String>?> snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const SizedBox(); // Espaço em branco enquanto aguarda a resposta
                        } else if (snapshot.hasError || !snapshot.hasData) {
                          return const Text(
                              'Erro ao carregar os dados do usuário');
                        } else {
                          String userName = snapshot.data!['nome']!;
                          String imageUrl = snapshot.data!['urlImagem']!;

                          return Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: GestureDetector(
                              onLongPress: () {
                                if (idUsuarioLogado) {
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
                                          ListTile(
                                            leading: const Icon(
                                              Icons.delete_sweep_rounded,
                                              color: Colors.black,
                                            ),
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
                                                      FieldValue.increment(-1),
                                                });
                                              });
                                              // Lógica de copiar URL
                                              Navigator.pop(context);
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                }
                              },
                              child: ListTile(
                                leading: GestureDetector(
                                  onTap: () {
                                    if (uidUsuario != _idUsuarioComentado) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => perfil_visita(
                                                uidPerfil: uidUsuario,
                                                nome: userName,
                                                imagemPerfil: imageUrl,
                                                sobrenome: 'nulo',
                                                cadastro: 'nulo')));
                                    } else {
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => const perfil()));
                                    }
                                  },
                                  child: Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: const Color.fromARGB(
                                              255, 202, 30, 82),
                                          width: 2),
                                    ),
                                    child: ClipOval(
                                      child: CachedNetworkImage(
                                        imageUrl: imageUrl,
                                        placeholder: (context, url) =>
                                            const CircularProgressIndicator(
                                          color: Colors.white,
                                        ),
                                        errorWidget: (context, url, error) =>
                                            const Icon(Icons.error),
                                      ),
                                    ),
                                  ),
                                ),
                                title: Stack(
                                  children: [
                                    Column(
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
                                                void curtirComentario(
                                                    String titulo) {
                                                  CollectionReference
                                                      novidadesCollection =
                                                      FirebaseFirestore.instance
                                                          .collection('feed');

                                                  novidadesCollection
                                                      .doc(idPostagem)
                                                      .collection('comentar')
                                                      .doc(refComentario)
                                                      .collection(
                                                          'curtirComentario')
                                                      .doc(_idUsuarioComentado)
                                                      .get()
                                                      .then((doc) {
                                                    if (doc.exists) {
                                                      doc.reference
                                                          .delete()
                                                          .then((_) {
                                                        novidadesCollection
                                                            .doc(idPostagem)
                                                            .collection(
                                                                'comentar')
                                                            .doc(refComentario)
                                                            .update({
                                                          'curtidas': FieldValue
                                                              .increment(-1),
                                                        });
                                                      });
                                                    } else {
                                                      Map<String, dynamic>
                                                          curtidaComentario = {
                                                        'hora': DateTime.now()
                                                            .toString(),
                                                        'uidusuario':
                                                            _idUsuarioComentado,
                                                      };

                                                      novidadesCollection
                                                          .doc(idPostagem)
                                                          .collection(
                                                              'comentar')
                                                          .doc(refComentario)
                                                          .collection(
                                                              'curtirComentario')
                                                          .doc(
                                                              _idUsuarioComentado)
                                                          .set(
                                                              curtidaComentario)
                                                          .then((_) {
                                                        novidadesCollection
                                                            .doc(idPostagem)
                                                            .collection(
                                                                'comentar')
                                                            .doc(refComentario)
                                                            .update({
                                                          'curtidas': FieldValue
                                                              .increment(1),
                                                        });
                                                      });
                                                    }
                                                  });
                                                }

                                                curtirComentario(idPostagem);
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
                                                      if (!snapshot.hasData ||
                                                          !snapshot
                                                              .data!.exists) {
                                                        // Se não houver dados (usuário não curtiu), mostre o ícone de coração vazio
                                                        return SizedBox(
                                                                  width: 20,
                                                                  child: Image
                                                                      .asset(
                                                                          'assets/curtir_01.png'));
                                                      }

                                                      // Se houver dados (usuário já curtiu), mostre o ícone de coração cheio
                                                      return SizedBox(
                                                                  width: 20,
                                                                  child: Image
                                                                      .asset(
                                                                          'assets/curtir_02.png'));
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
                                            ),
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
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.w400,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 8),
                                          child: Row(
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
                                                                  imageUrl)),
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
                                                stream: FirebaseFirestore
                                                    .instance
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
                                                                FontWeight
                                                                    .bold));
                                                  }

                                                  final respostas = snapshot
                                                      .data!
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
                                                                    texto:
                                                                        texto,
                                                                    hora: hora,
                                                                    imageUrl:
                                                                        imageUrl)),
                                                              ),
                                                            );
                                                          },
                                                          child: Text(
                                                              '    -    Ver $respostas respostas',
                                                              style: const TextStyle(
                                                                  fontSize: 12,
                                                                  color: Colors
                                                                      .grey,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold)),
                                                        );
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }
                      },
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(26),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: TextField(
                        controller: comentarioController,
                        maxLines: null,
                        textAlign: TextAlign.left,
                        keyboardType: TextInputType.text,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                        decoration: const InputDecoration(
                          contentPadding:
                              EdgeInsets.fromLTRB(10.0, 25.0, 35.0, 10.0),
                          hintText: "Deixe seu comentário...",
                          hintStyle: TextStyle(
                            color: Color.fromARGB(255, 124, 124, 124),
                          ),
                          filled: true,
                          fillColor: Color.fromARGB(255, 243, 243, 243),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.all(Radius.circular(32)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Color.fromARGB(255, 206, 38, 88)),
                            borderRadius: BorderRadius.all(Radius.circular(32)),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 55,
                    height: 55,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 116, 139, 189),
                      shape: BoxShape.rectangle,
                      borderRadius:
                          const BorderRadius.all(Radius.circular(32.0)),
                      border: Border.all(color: Colors.white, width: 0),
                    ),
                    child: IconButton(
                      color: const Color.fromARGB(255, 255, 255, 255),
                      onPressed: enviarAvaliacao,
                      icon: const Icon(Icons.send, size: 18),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
