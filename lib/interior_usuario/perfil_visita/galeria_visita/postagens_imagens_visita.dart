import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:editora_izyncor_app/interior_usuario/homepage/feed/comentarios/comentarios_postagem.dart';
import 'package:editora_izyncor_app/interior_usuario/homepage/feed/denuncias/denunciar.dart';
import 'package:editora_izyncor_app/interior_usuario/homepage/feed/processo_postagem/editar_postagem.dart';
import 'package:editora_izyncor_app/interior_usuario/perfil/meu_perfil.dart';
import 'package:editora_izyncor_app/interior_usuario/perfil_visita/perfil_visita.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:readmore/readmore.dart';

class postagens_imagens_visitas extends StatefulWidget {
  final String autoId;
  final String nome;
  const postagens_imagens_visitas({super.key, required this.autoId, required this.nome});

  @override
  State<postagens_imagens_visitas> createState() => _postagens_imagens_visitasState();
}

class _postagens_imagens_visitasState extends State<postagens_imagens_visitas> {
  FirebaseAuth auth = FirebaseAuth.instance;

  late List<Map<String, dynamic>> postagens;
  String? idUsuarioLogado;
  bool postagensCarregadas = false;
  late String autoId;
  late String nome;

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
    } else if (difference < Duration(minutes: 2)) {
      return 'Há ${difference.inMinutes} minuto';
    } else if (difference < Duration(hours: 1)) {
      int minutes = difference.inMinutes;
      return 'Há $minutes ${minutes == 1 ? 'minuto' : 'minutos'}';
    } else if (difference < Duration(days: 1)) {
      int hours = difference.inHours;
      return 'Há $hours ${hours == 1 ? 'hora' : 'horas'}';
    } else if (difference < Duration(days: 2)) {
      return 'Há ${difference.inDays} dia';
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
    recuperarDadosUsuario();
    autoId = widget.autoId;
    nome = widget.nome;
    postagens = [];

    if (!postagensCarregadas) {
      // Chame fetchFeed() apenas na primeira vez que a tela for aberta
      fetchFeed();
      postagensCarregadas = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: () => fetchFeed(),
        child: FutureBuilder(
            // Consulta Firestore para verificar se a coleção "feed" está vazia
            future: FirebaseFirestore.instance.collection('feed').get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator(
                  color: Colors.white,
                ); // Mostra um indicador de carregamento enquanto consulta o Firestore
              } else if (snapshot.hasError) {
                return const Text("Erro ao carregar dados do Firestore");
              } else if (!snapshot.data!.docs.any((doc) =>
                  doc['autorId'] == autoId &&
                  doc['imagemUrl'] != 'vazio')) {
                return Center(
                    child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Opacity(
                        opacity:
                            0.3, // Defina o valor desejado de opacidade entre 0.0 e 1.0
                        child: SizedBox(
                          width: 32,
                          child: Image.asset('assets/galeria.png'),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Nenhuma postagem ainda...',
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.black26,
                            fontSize: 20),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ));
              } else {
                // A coleção "feed" não está vazia, você pode criar seu ListView.builder aqui
                return ListView.builder(
                  itemCount: postagens.length,
                  itemBuilder: (context, index) {
                    var postagem = postagens[index];

                    return Padding(
                        padding: const EdgeInsets.all(3.0),
                        child: Column(
                          children: [
                            if (postagem['autorId'] == autoId)
                              Column(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Visibility(
                                      visible: postagem['imagemUrl'] != null &&
                                          postagem['imagemUrl'] != 'vazio',
                                      child: Stack(
                                        children: [
                                          GestureDetector(
                                            onDoubleTap: () {
                                              void enviarCurtida(
                                                  String titulo) {
                                                if (idUsuarioLogado != null) {
                                                  CollectionReference
                                                      novidadesCollection =
                                                      FirebaseFirestore.instance
                                                          .collection('feed');

                                                  // Verificar se o idUsuarioLogado já existe na coleção de curtir
                                                  novidadesCollection
                                                      .doc(postagem[
                                                          'idPostagem'])
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
                                                          'curtidas': FieldValue
                                                              .increment(
                                                                  1), // Incrementa o contador de curtidas
                                                        });
                                                      });
                                                    }
                                                  });
                                                }
                                              }

                                              enviarCurtida(
                                                  postagem['idPostagem']);
                                            },
                                            child: CachedNetworkImage(
                                                imageUrl:
                                                    postagem['imagemUrl']),
                                          ),
                                          if (postagem['editado'] == 'sim')
                                            const Positioned(
                                              top: 10,
                                              left: 10,
                                              child: Padding(
                                                padding:
                                                    EdgeInsets.only(left: 5),
                                                child: Text(
                                                  '[Editado]',
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Colors.white54),
                                                ),
                                              ),
                                            ),
                                          Positioned(
                                              top: 10,
                                              right: 10,
                                              child: GestureDetector(
                                                  onTap: () {
                                                    void verItem(
                                                        BuildContext context) {
                                                      showModalBottomSheet(
                                                        context: context,
                                                        shape:
                                                            const RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .vertical(
                                                            top: Radius.circular(
                                                                20.0), // Defina o raio para bordas arredondadas superiores
                                                          ),
                                                        ),
                                                        builder: (BuildContext
                                                            context) {
                                                          return Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: <Widget>[
                                                              Center(
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .only(
                                                                          top:
                                                                              10),
                                                                  child:
                                                                      Container(
                                                                    width: 40,
                                                                    height: 4,
                                                                    decoration: BoxDecoration(
                                                                        color: Colors
                                                                            .black38,
                                                                        borderRadius:
                                                                            BorderRadius.circular(12)),
                                                                  ),
                                                                ),
                                                              ),
                                                              // ListTile(
                                                              //   leading: SizedBox(
                                                              //       width: 25,
                                                              //       child: Image
                                                              //           .asset(
                                                              //               'assets/copiar.png')),
                                                              //   title: const Text(
                                                              //       'Copiar url'),
                                                              //   onTap: () {
                                                              //     // Lógica de copiar URL
                                                              //     Navigator.pop(
                                                              //         context);
                                                              //   },
                                                              // ),
                                                              if (idUsuarioLogado !=
                                                                  postagem[
                                                                      'autorId'])
                                                                ListTile(
                                                                  leading: SizedBox(
                                                                      width: 30,
                                                                      child: Image
                                                                          .asset(
                                                                              'assets/denunciar_01.png')),
                                                                  title:
                                                                      const Text(
                                                                    'Denunciar',
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w500,
                                                                        color: Colors
                                                                            .red),
                                                                  ),
                                                                  onTap: () {
                                                                    // Lógica de copiar URL
                                                                    Navigator.pop(
                                                                        context);
                                                                    Navigator.push(
                                                                        context,
                                                                        MaterialPageRoute(
                                                                            builder: (context) => denunciar(
                                                                                  idPostagem: postagem['idPostagem'],
                                                                                  autor: postagem['autorId'],
                                                                                  nomeAutor: postagem['username'],
                                                                                )));
                                                                  },
                                                                ),
                                                              Visibility(
                                                                visible: postagem[
                                                                        'autorId'] ==
                                                                    idUsuarioLogado,
                                                                child: ListTile(
                                                                  leading: SizedBox(
                                                                      width: 25,
                                                                      child: Image
                                                                          .asset(
                                                                              'assets/lixeira.png')),
                                                                  title: const Text(
                                                                      'Excluir'),
                                                                  onTap:
                                                                      () async {
                                                                    void excluirPost(
                                                                        String
                                                                            titulo) {
                                                                      if (postagem[
                                                                              'autorId'] ==
                                                                          idUsuarioLogado) {
                                                                        CollectionReference
                                                                            novidadesCollection =
                                                                            FirebaseFirestore.instance.collection('feed');

                                                                        // Excluir o documento do Firestore
                                                                        novidadesCollection
                                                                            .doc(postagem['idPostagem'])
                                                                            .delete();

                                                                        FirebaseFirestore
                                                                            .instance
                                                                            .collection('usuarios')
                                                                            .doc(idUsuarioLogado)
                                                                            .update({
                                                                          'postagens':
                                                                              FieldValue.increment(-1),
                                                                        });

                                                                        setState(
                                                                            () {
                                                                          postagens.removeWhere((postagem) =>
                                                                              postagem['idPostagem'] ==
                                                                              postagem['idPostagem']);
                                                                        });
                                                                        // Chamar fetchFeed novamente após a exclusão
                                                                        fetchFeed();
                                                                      }
                                                                    }

                                                                    excluirPost(
                                                                        postagem[
                                                                            'idPostagem']);

                                                                    // Lógica de copiar URL
                                                                    Navigator.pop(
                                                                        context);
                                                                  },
                                                                ),
                                                              ),
                                                              Visibility(
                                                                visible: postagem[
                                                                        'autorId'] ==
                                                                    idUsuarioLogado,
                                                                child: ListTile(
                                                                  leading: SizedBox(
                                                                      width: 25,
                                                                      child: Image
                                                                          .asset(
                                                                              'assets/textos_02.png')),
                                                                  title: const Text(
                                                                      'Editar'),
                                                                  onTap: () {
                                                                    Navigator.pop(
                                                                        context);
                                                                    Navigator.push(
                                                                        context,
                                                                        MaterialPageRoute(
                                                                            builder: (context) => editar_postagem(
                                                                                  idPostagem: postagem['idPostagem'],
                                                                                  legenda: postagem['legenda'],
                                                                                  imagemPostagem: postagem['imagemUrl'],
                                                                                  titulo: postagem['titulo'],
                                                                                )));
                                                                  },
                                                                ),
                                                              ),
                                                              if (Platform
                                                                  .isIOS)
                                                                const SizedBox(
                                                                  width: double
                                                                      .infinity,
                                                                  height: 40,
                                                                )
                                                            ],
                                                          );
                                                        },
                                                      );
                                                    }

                                                    verItem(context);
                                                  },
                                                  child: const Icon(
                                                      Icons.more_horiz,
                                                      color: Colors.white,
                                                      size: 26))),
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
                                                    GestureDetector(
                                                      onTap: () {
                                                        if (postagem[
                                                                'autorId'] ==
                                                            idUsuarioLogado) {
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: ((context) =>
                                                                  const perfil()),
                                                            ),
                                                          );
                                                        } else {
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder:
                                                                  ((context) =>
                                                                      perfil_visita(
                                                                        uidPerfil:
                                                                            postagem['autorId'],
                                                                        nome: postagem[
                                                                            'nome'],
                                                                        imagemPerfil:
                                                                            postagem['urlImagem'],
                                                                        sobrenome:
                                                                            postagem['sobrenome'],
                                                                        cadastro:
                                                                            postagem['Cadastro'],
                                                                      )),
                                                            ),
                                                          );
                                                        }
                                                      },
                                                      child: Container(
                                                        width: 52,
                                                        height: 52,
                                                        decoration:
                                                            const BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                        ),
                                                        child: ClipOval(
                                                          child:
                                                              CachedNetworkImage(
                                                            imageUrl: postagem[
                                                                'urlImagem'],
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Visibility(
                                                      visible:
                                                          postagem['autorId'] !=
                                                              idUsuarioLogado,
                                                      child: Positioned(
                                                        bottom: 0,
                                                        right: 0,
                                                        child: Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            shape:
                                                                BoxShape.circle,
                                                            border: Border.all(
                                                              color:
                                                                  Colors.white,
                                                              width: 2,
                                                            ),
                                                          ),
                                                          child: ClipOval(
                                                            child: Material(
                                                              color: const Color
                                                                  .fromARGB(255,
                                                                  202, 30, 82),
                                                              child: InkWell(
                                                                onTap: () {
                                                                  void seguirUsuario(
                                                                      String
                                                                          titulo) {
                                                                    if (idUsuarioLogado !=
                                                                        null) {
                                                                      CollectionReference
                                                                          novidadesCollection =
                                                                          FirebaseFirestore
                                                                              .instance
                                                                              .collection('usuarios');

                                                                      // Verificar se o idUsuarioLogado já existe na coleção de curtir
                                                                      novidadesCollection
                                                                          .doc(postagem[
                                                                              'autorId'])
                                                                          .collection(
                                                                              'seguidores')
                                                                          .doc(
                                                                              idUsuarioLogado)
                                                                          .get()
                                                                          .then(
                                                                              (doc) {
                                                                        if (doc
                                                                            .exists) {
                                                                          doc.reference
                                                                              .delete()
                                                                              .then((_) {
                                                                            novidadesCollection.doc(postagem['autorId']).update({
                                                                              'seguidores': FieldValue.increment(-1),
                                                                            });
                                                                          });
                                                                        } else {
                                                                          Map<String, dynamic>
                                                                              seguidoresData =
                                                                              {
                                                                            'hora':
                                                                                DateTime.now().toString(),
                                                                            'uidusuario':
                                                                                idUsuarioLogado,
                                                                          };

                                                                          novidadesCollection
                                                                              .doc(postagem['autorId'])
                                                                              .collection('seguidores')
                                                                              .doc(idUsuarioLogado)
                                                                              .set(seguidoresData)
                                                                              .then((_) {
                                                                            novidadesCollection.doc(postagem['autorId']).update({
                                                                              'seguidores': FieldValue.increment(1),
                                                                            });
                                                                          });
                                                                        }
                                                                      });
                                                                    }
                                                                  }

                                                                  seguirUsuario(
                                                                      postagem[
                                                                          'autorId']);
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
                                                                        .doc(postagem[
                                                                            'autorId'])
                                                                        .collection(
                                                                            'seguidores')
                                                                        .doc(
                                                                            idUsuarioLogado)
                                                                        .snapshots(),
                                                                    builder:
                                                                        (context,
                                                                            snapshot) {
                                                                      if (!snapshot
                                                                              .hasData ||
                                                                          !snapshot
                                                                              .data!
                                                                              .exists) {
                                                                        // Se não houver dados (usuário não curtiu), mostre o ícone de coração vazio
                                                                        return const Icon(
                                                                          Icons
                                                                              .add,
                                                                          color:
                                                                              Colors.white,
                                                                          size:
                                                                              16,
                                                                        );
                                                                      }

                                                                      // Se houver dados (usuário já curtiu), mostre o ícone de coração cheio
                                                                      return const Icon(
                                                                        Icons
                                                                            .check,
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
                                                GestureDetector(
                                                  onTap: () {
                                                    if (postagem['autorId'] ==
                                                        idUsuarioLogado) {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: ((context) =>
                                                              const perfil()),
                                                        ),
                                                      );
                                                    } else {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: ((context) =>
                                                              perfil_visita(
                                                                uidPerfil:
                                                                    postagem[
                                                                        'autorId'],
                                                                nome: postagem[
                                                                    'nome'],
                                                                imagemPerfil:
                                                                    postagem[
                                                                        'urlImagem'],
                                                                sobrenome: postagem[
                                                                    'sobrenome'],
                                                                cadastro: postagem[
                                                                    'Cadastro'],
                                                              )),
                                                        ),
                                                      );
                                                    }
                                                  },
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        postagem['nome'],
                                                        style: const TextStyle(
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color: Colors.white,
                                                            fontSize: 16),
                                                      ),
                                                      const SizedBox(height: 3),
                                                      Text(
                                                        formatDataHora(
                                                            postagem['hora']),
                                                        style: const TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Positioned(
                                              bottom: 15,
                                              right: 0,
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
                                                                  .doc(postagem[
                                                                      'idPostagem'])
                                                                  .collection(
                                                                      'curtir')
                                                                  .doc(
                                                                      idUsuarioLogado)
                                                                  .get()
                                                                  .then((doc) {
                                                                if (doc
                                                                    .exists) {
                                                                  // O usuário já curtiu, então remova a curtida
                                                                  doc.reference
                                                                      .delete()
                                                                      .then(
                                                                          (_) {
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
                                                                  Map<String,
                                                                          dynamic>
                                                                      curtidaData =
                                                                      {
                                                                    'hora': DateTime
                                                                            .now()
                                                                        .toString(),
                                                                    'uidusuario':
                                                                        idUsuarioLogado,
                                                                  };

                                                                  // Adicione a curtida na coleção 'curtir' da novidade
                                                                  novidadesCollection
                                                                      .doc(postagem[
                                                                          'idPostagem'])
                                                                      .collection(
                                                                          'curtir')
                                                                      .doc(
                                                                          idUsuarioLogado)
                                                                      .set(
                                                                          curtidaData)
                                                                      .then(
                                                                          (_) {
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

                                                          enviarCurtida(postagem[
                                                              'idPostagem']);
                                                        },
                                                        child: SizedBox(
                                                          width: 40,
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .end,
                                                            children: [
                                                              StreamBuilder<
                                                                  DocumentSnapshot>(
                                                                stream: FirebaseFirestore
                                                                    .instance
                                                                    .collection(
                                                                        'feed')
                                                                    .doc(postagem[
                                                                        'idPostagem'])
                                                                    .collection(
                                                                        'curtir')
                                                                    .doc(
                                                                        idUsuarioLogado)
                                                                    .snapshots(),
                                                                builder: (context,
                                                                    snapshot) {
                                                                  bool usuarioCurtiu = snapshot
                                                                          .hasData &&
                                                                      snapshot
                                                                          .data!
                                                                          .exists;

                                                                  return AnimatedContainer(
                                                                    curve: usuarioCurtiu
                                                                        ? Curves
                                                                            .elasticOut
                                                                        : Curves
                                                                            .linear,
                                                                    duration: Duration(
                                                                        milliseconds: usuarioCurtiu
                                                                            ? 1100
                                                                            : 0),
                                                                    width:
                                                                        usuarioCurtiu
                                                                            ? 37
                                                                            : 21,
                                                                    child: usuarioCurtiu
                                                                        ? Image.asset(
                                                                            'assets/coracao_02.png')
                                                                        : Image.asset(
                                                                            'assets/coracao_01_branco.png'),
                                                                  );
                                                                },
                                                              ),
                                                              const SizedBox(
                                                                  height: 5),
                                                              StreamBuilder<
                                                                  DocumentSnapshot>(
                                                                stream: FirebaseFirestore
                                                                    .instance
                                                                    .collection(
                                                                        'feed')
                                                                    .doc(postagem[
                                                                        'idPostagem']) // Use o título como ID do documento
                                                                    .snapshots(),
                                                                builder: (context,
                                                                    snapshot) {
                                                                  if (!snapshot
                                                                      .hasData) {
                                                                    return const Text(
                                                                      '0', // Ou qualquer outro valor padrão
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            14,
                                                                        color: Colors
                                                                            .white,
                                                                      ),
                                                                    );
                                                                  }

                                                                  final curtidas =
                                                                      snapshot
                                                                          .data!
                                                                          .get(
                                                                              'curtidas');
                                                                  return Text(
                                                                    '$curtidas',
                                                                    style:
                                                                        const TextStyle(
                                                                      fontSize:
                                                                          14,
                                                                      color: Colors
                                                                          .white,
                                                                    ),
                                                                  );
                                                                },
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
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
                                                                          postagem[
                                                                              'idPostagem'])),
                                                            ),
                                                          );
                                                        },
                                                        child: SizedBox(
                                                          width: 40,
                                                          height: 50,
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .end,
                                                            children: [
                                                              SizedBox(
                                                                  width: 23,
                                                                  child: Image
                                                                      .asset(
                                                                          'assets/comentar_branco.png')),
                                                              const SizedBox(
                                                                  height: 5),
                                                              StreamBuilder<
                                                                  DocumentSnapshot>(
                                                                stream: FirebaseFirestore
                                                                    .instance
                                                                    .collection(
                                                                        'feed')
                                                                    .doc(postagem[
                                                                        'idPostagem']) // Use o título como ID do documento
                                                                    .snapshots(),
                                                                builder: (context,
                                                                    snapshot) {
                                                                  if (!snapshot
                                                                      .hasData) {
                                                                    return const Text(
                                                                      '0', // Ou qualquer outro valor padrão
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            14,
                                                                        color: Colors
                                                                            .white,
                                                                      ),
                                                                    );
                                                                  }

                                                                  final comentarios =
                                                                      snapshot
                                                                          .data!
                                                                          .get(
                                                                              'comentarios');
                                                                  return Text(
                                                                    '$comentarios',
                                                                    style:
                                                                        const TextStyle(
                                                                      fontSize:
                                                                          14,
                                                                      color: Colors
                                                                          .white,
                                                                    ),
                                                                  );
                                                                },
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Column(
                                                    children: [
                                                      GestureDetector(
                                                        onTap: () {
                                                          void salvarPost(
                                                              String titulo) {
                                                            if (idUsuarioLogado !=
                                                                null) {
                                                              FirebaseFirestore
                                                                  .instance
                                                                  .collection(
                                                                      'salvos')
                                                                  .doc(
                                                                      idUsuarioLogado)
                                                                  .collection(
                                                                      'meus_salvos')
                                                                  .doc(postagem[
                                                                      'idPostagem']) // Use postagem['idPostagem'] como o ID do documento
                                                                  .get()
                                                                  .then((doc) {
                                                                if (doc
                                                                    .exists) {
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
                                                                      .doc(postagem[
                                                                          'idPostagem'])
                                                                      .set({
                                                                    'idPostagem':
                                                                        postagem[
                                                                            'idPostagem'],
                                                                    'hora': DateTime
                                                                            .now()
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
                                                                  .doc(postagem[
                                                                      'idPostagem'])
                                                                  .collection(
                                                                      'salvar')
                                                                  .doc(
                                                                      idUsuarioLogado)
                                                                  .get()
                                                                  .then((doc) {
                                                                if (doc
                                                                    .exists) {
                                                                  // O usuário já curtiu, então remova a curtida
                                                                  doc.reference
                                                                      .delete()
                                                                      .then(
                                                                          (_) {
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
                                                                  Map<String,
                                                                          dynamic>
                                                                      salvarPost =
                                                                      {
                                                                    'hora': DateTime
                                                                            .now()
                                                                        .toString(),
                                                                    'uidusuario':
                                                                        idUsuarioLogado,
                                                                  };

                                                                  // Adicione a curtida na coleção 'curtir' da novidade
                                                                  novidadesCollection
                                                                      .doc(postagem[
                                                                          'idPostagem'])
                                                                      .collection(
                                                                          'salvar')
                                                                      .doc(
                                                                          idUsuarioLogado)
                                                                      .set(
                                                                          salvarPost)
                                                                      .then(
                                                                          (_) {
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

                                                          salvarPost(postagem[
                                                              'idPostagem']);
                                                        },
                                                        child: SizedBox(
                                                          width: 40,
                                                          height: 50,
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .end,
                                                            children: [
                                                              StreamBuilder<
                                                                  DocumentSnapshot>(
                                                                stream: FirebaseFirestore
                                                                    .instance
                                                                    .collection(
                                                                        'feed')
                                                                    .doc(postagem[
                                                                        'idPostagem'])
                                                                    .collection(
                                                                        'salvar')
                                                                    .doc(
                                                                        idUsuarioLogado)
                                                                    .snapshots(),
                                                                builder: (context,
                                                                    snapshot) {
                                                                  bool usuarioCurtiu = snapshot
                                                                          .hasData &&
                                                                      snapshot
                                                                          .data!
                                                                          .exists;

                                                                  return AnimatedContainer(
                                                                    curve: usuarioCurtiu
                                                                        ? Curves
                                                                            .elasticOut
                                                                        : Curves
                                                                            .linear,
                                                                    duration: Duration(
                                                                        milliseconds: usuarioCurtiu
                                                                            ? 700
                                                                            : 0),
                                                                    width:
                                                                        usuarioCurtiu
                                                                            ? 24
                                                                            : 22,
                                                                    child: usuarioCurtiu
                                                                        ? Image.asset(
                                                                            'assets/disquete_08_branco.png')
                                                                        : Image.asset(
                                                                            'assets/disquete_06_branco.png'),
                                                                  );
                                                                },
                                                              ),
                                                              const SizedBox(
                                                                  height: 5),
                                                              StreamBuilder<
                                                                  DocumentSnapshot>(
                                                                stream: FirebaseFirestore
                                                                    .instance
                                                                    .collection(
                                                                        'feed')
                                                                    .doc(postagem[
                                                                        'idPostagem']) // Use o título como ID do documento
                                                                    .snapshots(),
                                                                builder: (context,
                                                                    snapshot) {
                                                                  if (!snapshot
                                                                      .hasData) {
                                                                    return const Text(
                                                                      '0', // Ou qualquer outro valor padrão
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            14,
                                                                        color: Colors
                                                                            .white,
                                                                      ),
                                                                    );
                                                                  }

                                                                  final salvos =
                                                                      snapshot
                                                                          .data!
                                                                          .get(
                                                                              'salvos');
                                                                  return Text(
                                                                    '$salvos',
                                                                    style:
                                                                        const TextStyle(
                                                                      fontSize:
                                                                          14,
                                                                      color: Colors
                                                                          .white,
                                                                    ),
                                                                  );
                                                                },
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(width: 5),
                                                  Column(
                                                    children: [
                                                      SizedBox(
                                                          width: 23,
                                                          child: Image.asset(
                                                              'assets/compartilhar_branco.png')),
                                                      const Text(''),
                                                    ],
                                                  ),
                                                  const SizedBox(width: 15),
                                                ],
                                              ))
                                        ],
                                      ),
                                    ),
                                  ),
                                  if (postagem['legenda'] != '')
                                    if (postagem['imagemUrl'] != 'vazio')
                                      Align(
                                        alignment: Alignment.bottomLeft,
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              top: 10, left: 15),
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
                                  if (postagem['imagemUrl'] != 'vazio')
                                    Padding(
                                      padding: const EdgeInsets.only(top: 20),
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
              }
            }),
      ),
    );
  }
}
