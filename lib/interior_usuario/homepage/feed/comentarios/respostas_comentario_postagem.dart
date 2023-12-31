import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:editora_izyncor_app/interior_usuario/perfil/meu_perfil.dart';
import 'package:editora_izyncor_app/interior_usuario/perfil_visita/perfil_visita.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:readmore/readmore.dart';

class respostas_comentario_postagem extends StatefulWidget {
  final String uidUsuario;
  final String refComentario;
  final String idPostagem;
  final String texto;
  final String hora;
  final String imageUrl;
  const respostas_comentario_postagem(
      {super.key,
      required this.uidUsuario,
      required this.refComentario,
      required this.idPostagem,
      required this.texto,
      required this.hora,
      required this.imageUrl});

  @override
  State<respostas_comentario_postagem> createState() =>
      _respostas_comentario_postagemState();
}

class _respostas_comentario_postagemState
    extends State<respostas_comentario_postagem> {
  StreamController<String> streamNome = StreamController<String>();
  StreamController<String> streamNomeComentario = StreamController<String>();
  TextEditingController respostaController = TextEditingController();

  String? uidUsuario;
  String? _idUsuarioLogado;
  String? refComentario;
  String nomeComentario = '';
  String? idPostagem;
  String? respostaId;
  String? texto;
  String? hora;
  String? imageUrl;

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

  recuperarDadosUsuario() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? usuarioLogado = auth.currentUser;
    _idUsuarioLogado = usuarioLogado?.uid;

    FirebaseFirestore db = FirebaseFirestore.instance;
    DocumentSnapshot snapshot =
        await db.collection("usuarios").doc(_idUsuarioLogado).get();

    Map<String, dynamic> dados = snapshot.data() as Map<String, dynamic>;
    streamNome.add(dados["nome"]);
  }

  recuperarDadosComentario() async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    DocumentSnapshot snapshot =
        await db.collection("usuarios").doc(uidUsuario).get();

    Map<String, dynamic> dados = snapshot.data() as Map<String, dynamic>;
    streamNomeComentario.add(dados["nome"]);

    // Atualize o hintText com o nome do usuário do comentário
    setState(() {
      nomeComentario = dados["nome"];
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    uidUsuario = widget.uidUsuario;
    refComentario = widget.refComentario;
    idPostagem = widget.idPostagem;
    texto = widget.texto;
    hora = widget.hora;
    imageUrl = widget.imageUrl;
    recuperarDadosUsuario();
    recuperarDadosComentario();
  }

  void enviarResposta() {
    String comentario = respostaController.text;
    if (comentario.isNotEmpty) {
      if (_idUsuarioLogado != null) {
        CollectionReference novidadesCollection =
            FirebaseFirestore.instance.collection('feed');

        // Adicione o comentário na coleção 'comentar' da novidade
        DocumentReference novoComentarioRef = novidadesCollection
            .doc(idPostagem)
            .collection('comentar')
            .doc(refComentario)
            .collection('respostas')
            .doc(); // Cria uma nova referência de documento

        // Atualize a variável respostaId com o ID do novo comentário
        respostaId = novoComentarioRef.id;

        novoComentarioRef.set({
          'texto': comentario,
          'ref': respostaId,
          'hora': DateTime.now().toString(),
          'uidusuario': _idUsuarioLogado,
          'curtidas': 0,
        }).then((_) {
          novidadesCollection
              .doc(idPostagem)
              .collection('comentar')
              .doc(refComentario)
              .update({
            'respostas': FieldValue.increment(1),
          });
        });
        respostaController.clear();
      }
    }
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        foregroundColor: Colors.black,
        elevation: 0,
        leadingWidth: 26,
        backgroundColor: Colors.transparent,
        title: const Text('Respostas'),
      ),
      body: Column(children: [
        ListTile(
          leading: GestureDetector(
            onTap: () {
              if (uidUsuario == _idUsuarioLogado) {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const perfil()));
              } else {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context1) => perfil_visita(
                            uidPerfil: uidUsuario!,
                            nome: nomeComentario,
                            imagemPerfil: imageUrl!,
                            sobrenome: '',
                            cadastro: 'cadastro')));
              }
            },
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color: const Color.fromARGB(255, 235, 187, 55), width: 2),
              ),
              child: ClipOval(
                child: CachedNetworkImage(
                  imageUrl: imageUrl!,
                  placeholder: (context, url) =>
                      const CircularProgressIndicator(
                    color: Colors.white,
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          title: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          nomeComentario,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const Text(
                          ' • ',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                        Text(
                          formatarHora(hora!),
                          style: const TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            curtirComentario() {
                              CollectionReference novidadesCollection =
                                  FirebaseFirestore.instance
                                      .collection('feed');

                              novidadesCollection
                                  .doc(idPostagem)
                                  .collection('comentar')
                                  .doc(refComentario)
                                  .collection('curtirComentario')
                                  .doc(_idUsuarioLogado)
                                  .get()
                                  .then((doc) {
                                if (doc.exists) {
                                  doc.reference.delete().then((_) {
                                    novidadesCollection
                                        .doc(idPostagem)
                                        .collection('comentar')
                                        .doc(refComentario)
                                        .update({
                                      'curtidas': FieldValue.increment(-1),
                                    });
                                  });
                                } else {
                                  Map<String, dynamic> curtidaComentario = {
                                    'hora': DateTime.now().toString(),
                                    'uidusuario': uidUsuario,
                                  };

                                  novidadesCollection
                                      .doc(idPostagem)
                                      .collection('comentar')
                                      .doc(refComentario)
                                      .collection('curtirComentario')
                                      .doc(_idUsuarioLogado)
                                      .set(curtidaComentario)
                                      .then((_) {
                                    novidadesCollection
                                        .doc(idPostagem)
                                        .collection('comentar')
                                        .doc(refComentario)
                                        .update({
                                      'curtidas': FieldValue.increment(1),
                                    });
                                  });
                                }
                              });
                            }

                            curtirComentario();
                          },
                          child: StreamBuilder<DocumentSnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('feed')
                                .doc(idPostagem)
                                .collection('comentar')
                                .doc(refComentario)
                                .collection('curtirComentario')
                                .doc(_idUsuarioLogado)
                                .snapshots(),
                            builder: (context, snapshot) {
                              bool usuarioCurtiu =
                                  snapshot.hasData && snapshot.data!.exists;

                              return AnimatedContainer(
                                curve: usuarioCurtiu
                                    ? Curves.elasticOut
                                    : Curves.linear,
                                duration: Duration(
                                    milliseconds: usuarioCurtiu ? 1100 : 0),
                                width: usuarioCurtiu ? 37 : 21,
                                child: usuarioCurtiu
                                    ? Image.asset('assets/coracao_02.png')
                                    : Image.asset('assets/coracao_04.png'),
                              );
                            },
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
                                      fontWeight: FontWeight.bold));
                            }

                            final curtidas = snapshot.data!.get('curtidas');
                            return Text('$curtidas',
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold));
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                Wrap(
                  children: [
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: ReadMoreText(
                        texto!,
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
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Container(
            width: double.infinity,
            height: 1,
            color: Colors.black12,
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('feed')
                .doc(idPostagem)
                .collection('comentar')
                .doc(refComentario)
                .collection('respostas')
                .orderBy('hora', descending: true)
                .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
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
                  Map<String, dynamic> comentario =
                      snapshot.data!.docs[index].data() as Map<String, dynamic>;
                  String texto = comentario['texto'];
                  String hora = comentario['hora'];
                  String uidUsuario = comentario['uidusuario'];
                  String refResposta = comentario['ref'];

                  bool idUsuarioLogado = uidUsuario == _idUsuarioLogado;

                  return FutureBuilder<Map<String, String>?>(
                    future: getUserData(uidUsuario),
                    builder: (BuildContext context,
                        AsyncSnapshot<Map<String, String>?> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SizedBox(); // Espaço em branco enquanto aguarda a resposta
                      } else if (snapshot.hasError || !snapshot.hasData) {
                        return const Text(
                            'Erro ao carregar os dados do usuário');
                      } else {
                        String userName = snapshot.data!['nome']!;
                        String imageUrl = snapshot.data!['urlImagem']!;

                        return Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: GestureDetector(
                            onLongPress: () {
                              if (idUsuarioLogado) {
                                showModalBottomSheet(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        ListTile(
                                          leading: const Icon(
                                            Icons.delete_sweep_rounded,
                                            color: Color.fromARGB(
                                                255, 191, 46, 87),
                                          ),
                                          title: const Text('Excluir'),
                                          onTap: () {
                                            FirebaseFirestore.instance
                                                .collection('feed')
                                                .doc(idPostagem)
                                                .collection('comentar')
                                                .doc(refComentario)
                                                .collection('respostas')
                                                .doc(refResposta)
                                                .delete()
                                                .then((_) {
                                              FirebaseFirestore.instance
                                                  .collection('feed')
                                                  .doc(idPostagem)
                                                  .collection('comentar')
                                                  .doc(refComentario)
                                                  .update({
                                                'respostas':
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
                            child: SizedBox(
                              width: double.infinity,
                              child: ListTile(
                                leading: GestureDetector(
                                  onTap: () {
                                    if (uidUsuario == _idUsuarioLogado) {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const perfil()));
                                    } else {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context1) =>
                                                  perfil_visita(
                                                      uidPerfil: uidUsuario,
                                                      nome: nomeComentario,
                                                      imagemPerfil: imageUrl,
                                                      sobrenome: '',
                                                      cadastro: 'cadastro')));
                                    }
                                  },
                                  child: Container(
                                    width: 48,
                                    height: 48,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                    ),
                                    child: ClipOval(
                                      child: CachedNetworkImage(
                                        imageUrl: imageUrl,
                                        placeholder: (context, url) =>
                                            const CircularProgressIndicator(
                                          color: Colors.white,
                                        ),
                                        fit: BoxFit.cover,
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
                                          ],
                                        ),
                                        const SizedBox(height: 5),
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
                                        const SizedBox(height: 15)
                                      ],
                                    ),
                                  ],
                                ),
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
                        controller: respostaController,
                        maxLines: null,
                        textAlign: TextAlign.left,
                        keyboardType: TextInputType.text,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                        decoration: InputDecoration(
                          contentPadding:
                              const EdgeInsets.fromLTRB(10.0, 25.0, 35.0, 10.0),
                          hintText:
                              'Responder @${nomeComentario}', // Modifique esta linha
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
                            borderRadius: BorderRadius.all(Radius.circular(32)),
                          ),
                        ),
                      )),
                ),
                Container(
                  width: 55,
                  height: 55,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 116, 139, 189),
                    shape: BoxShape.rectangle,
                    borderRadius: const BorderRadius.all(Radius.circular(32.0)),
                    border: Border.all(color: Colors.white, width: 0),
                  ),
                  child: IconButton(
                    color: const Color.fromARGB(255, 255, 255, 255),
                    onPressed: () {
                      enviarResposta();
                    },
                    icon: const Icon(Icons.send, size: 18),
                  ),
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}
