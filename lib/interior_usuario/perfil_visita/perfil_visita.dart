import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:editora_izyncor_app/interior_usuario/chat/chat_mensagem/mensagens.dart';
import 'package:editora_izyncor_app/interior_usuario/chat/chat_mensagem/widget_chat/anexos_chat.dart';
import 'package:editora_izyncor_app/interior_usuario/perfil_visita/galeria_visita/postagens_imagens_visita.dart';
import 'package:editora_izyncor_app/interior_usuario/perfil_visita/galeria_visita/postagens_textos.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class perfil_visita extends StatefulWidget {
  final String uidPerfil;
  final String nome;
  final String imagemPerfil;
  final String sobrenome;
  final String cadastro;
  const perfil_visita(
      {super.key,
      required this.uidPerfil,
      required this.nome,
      required this.imagemPerfil,
      required this.sobrenome,
      required this.cadastro});

  @override
  State<perfil_visita> createState() => _perfil_visitaState();
}

class _perfil_visitaState extends State<perfil_visita> {
  FirebaseAuth auth = FirebaseAuth.instance;

  String? idUsuarioLogado;
  String urlImagem = '';
  late String uidPerfil;
  late String nome;
  late String imagemPerfil;
  late String sobrenome;
  late String cadastro;
  String biografia = '';
  String cadastroPerfil = '';
  String nomePerfil = '';
  String sobrenomePerfil = '';
  String username = '';
  String? usernameLogado;
  String perfilLogado = '';

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
          usernameLogado = userData['username'];
          perfilLogado = userData['urlImagem'];
        });
      }
    }
  }

  void enviarNotificacao() {
    CollectionReference usuariosCollection =
        FirebaseFirestore.instance.collection('usuarios');

    DocumentReference usuarioRef = usuariosCollection.doc(uidPerfil);

    usuarioRef.collection('notificacoes').add({
      'username': usernameLogado,
      'idUsuario': idUsuarioLogado,
      'mensagem': 'começou a seguir você.',
      'hora': DateTime.now().toString(),
      'postagem': 'vazio',
      'idPostagem': '',
      'perfil': perfilLogado,
    });
  }

  void enviarNotificacao2() {
    CollectionReference usuariosCollection =
        FirebaseFirestore.instance.collection('usuarios');

    DocumentReference usuarioRef = usuariosCollection.doc(uidPerfil);

    usuarioRef.collection('notificacoes').add({
      'username': usernameLogado,
      'idUsuario': idUsuarioLogado,
      'mensagem': 'deixou de seguir você.',
      'hora': DateTime.now().toString(),
      'postagem': 'vazio',
      'idPostagem': '',
      'perfil': perfilLogado,
    });
  }

  void seguirUsuario() {
    if (idUsuarioLogado != null) {
      CollectionReference novidadesCollection =
          FirebaseFirestore.instance.collection('usuarios');

      novidadesCollection
          .doc(idUsuarioLogado)
          .collection('seguindo')
          .doc(uidPerfil)
          .get()
          .then((doc) {
        if (doc.exists) {
          doc.reference.delete().then((_) {
            novidadesCollection.doc(idUsuarioLogado).update({
              'seguindo': FieldValue.increment(-1),
            });
            enviarNotificacao2();
          });
        } else {
          Map<String, dynamic> seguindoData = {
            'hora': DateTime.now().toString(),
            'uidusuario': uidPerfil,
          };

          novidadesCollection
              .doc(idUsuarioLogado)
              .collection('seguindo')
              .doc(uidPerfil)
              .set(seguindoData)
              .then((_) {
            novidadesCollection.doc(idUsuarioLogado).update({
              'seguindo': FieldValue.increment(1),
            });
            enviarNotificacao();
          });
        }
      });

      // Verificar se o idUsuarioLogado já existe na coleção de curtir
      novidadesCollection
          .doc(uidPerfil)
          .collection('seguidores')
          .doc(idUsuarioLogado)
          .get()
          .then((doc) {
        if (doc.exists) {
          doc.reference.delete().then((_) {
            novidadesCollection.doc(uidPerfil).update({
              'seguidores': FieldValue.increment(-1),
            });
          });
        } else {
          Map<String, dynamic> seguidoresData = {
            'hora': DateTime.now().toString(),
            'uidusuario': idUsuarioLogado,
          };

          novidadesCollection
              .doc(uidPerfil)
              .collection('seguidores')
              .doc(idUsuarioLogado)
              .set(seguidoresData)
              .then((_) {
            novidadesCollection.doc(uidPerfil).update({
              'seguidores': FieldValue.increment(1),
            });
          });
        }
      });
    }
  }

  void verItem(BuildContext context) {
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
          children: <Widget>[
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: Colors.black38,
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: ListTile(
                leading: const Icon(
                  Icons.warning_amber_outlined,
                  color: Colors.black,
                ),
                title: const Text('Denunciar'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ),
            ListTile(
              leading: const Icon(
                Icons.block,
                color: Colors.black,
              ),
              title: const Text('Bloquear'),
              onTap: () {
                // Lógica para obter o link
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.share_outlined,
                color: Colors.black,
              ),
              title: const Text('Compartilhar perfil'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void carregarDadosPerfil() {
    FirebaseFirestore.instance
        .collection('usuarios')
        .doc(uidPerfil)
        .get()
        .then((doc) {
      if (doc.exists) {
        setState(() {
          biografia = doc.data()?['biografia'] ?? '';
          cadastroPerfil = doc.data()?['Cadastro'] ?? '';
          sobrenomePerfil = doc.data()?['sobrenome'] ?? '';
          username = doc.data()?['username'] ?? '';
          nomePerfil = doc.data()?['nome'] ?? '';
        });
      }
    }).catchError((error) {
      print('Erro ao carregar os dados: $error');
    });
  }

  void _exibirImagemFullScreen(String urlImagem4) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return Scaffold(
        backgroundColor: Colors.black.withOpacity(0.5),
        body: Center(
          child: GestureDetector(
            onDoubleTap: () {
              Navigator.pop(context);
            },
            child: InteractiveViewer(
              child: Hero(
                tag: urlImagem4,
                child: Image.network(
                  imagemPerfil,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
      );
    }));
  }

  @override
  initState() {
    super.initState();
    recuperarDadosUsuario();
    uidPerfil = widget.uidPerfil;
    nome = widget.nome;
    imagemPerfil = widget.imagemPerfil;
    sobrenome = widget.sobrenome;
    cadastro = widget.cadastro;
    carregarDadosPerfil();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          foregroundColor: Colors.black,
          elevation: 0,
          leadingWidth: 26,
          backgroundColor: Colors.transparent,
          // title: Text('@$username'),
          actions: [
            Padding(
              padding: EdgeInsets.only(right: 10),
              child: GestureDetector(
                onTap: () {},
                child: SizedBox(
                    width: 23, child: Image.asset('assets/settings.png')),
              ),
            )
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Column(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Stack(
                      children: [
                        GestureDetector(
                          onTap: () {
                            _exibirImagemFullScreen(imagemPerfil);
                          },
                          child: ClipOval(
                            child: Container(
                              width: 90,
                              height: 90,
                              color: Colors.black12,
                              child: CachedNetworkImage(
                                imageUrl: imagemPerfil,
                                fit: BoxFit
                                    .cover, // ajuste de acordo com suas necessidades
                                placeholder: (context, url) =>
                                    const CircularProgressIndicator(
                                  color: Colors.white,
                                ), // um indicador de carregamento
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error), // widget de erro
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      width: 280,
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '$nomePerfil $sobrenomePerfil',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black,
                                        fontSize: 20),
                                  ),
                                  const SizedBox(height: 3),
                                  Row(
                                    children: [
                                      Text(
                                        '@$username',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black,
                                            fontSize: 16),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        cadastroPerfil,
                                        style: const TextStyle(
                                            color: Colors.black38,
                                            fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Column(
                                  children: [
                                    StreamBuilder<DocumentSnapshot>(
                                      stream: FirebaseFirestore.instance
                                          .collection('usuarios')
                                          .doc(
                                              uidPerfil) // Use o título como ID do documento
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

                                        final seguidores =
                                            snapshot.data!.get('postagens');
                                        return Text(
                                          '$seguidores',
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16),
                                        );
                                      },
                                    ),
                                    const Text('Postagens'),
                                  ],
                                ),
                                const SizedBox(width: 15),
                                Container(
                                  width: 1,
                                  height: 25,
                                  color: Colors.black12,
                                ),
                                const SizedBox(width: 15),
                                Column(
                                  children: [
                                    StreamBuilder<DocumentSnapshot>(
                                      stream: FirebaseFirestore.instance
                                          .collection('usuarios')
                                          .doc(
                                              uidPerfil) // Use o título como ID do documento
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

                                        final seguidores =
                                            snapshot.data!.get('seguidores');
                                        return Text('$seguidores',
                                            style: const TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16));
                                      },
                                    ),
                                    const Text('Seguidores'),
                                  ],
                                ),
                                const SizedBox(width: 15),
                                Container(
                                  width: 1,
                                  height: 25,
                                  color: Colors.black12,
                                ),
                                const SizedBox(width: 15),
                                Column(
                                  children: [
                                    StreamBuilder<DocumentSnapshot>(
                                      stream: FirebaseFirestore.instance
                                          .collection('usuarios')
                                          .doc(
                                              uidPerfil) // Use o título como ID do documento
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

                                        final seguidores =
                                            snapshot.data!.get('seguindo');
                                        return Text('$seguidores',
                                            style: const TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16));
                                      },
                                    ),
                                    const Text('Seguindo'),
                                  ],
                                ),
                              ],
                            ),
                          ]),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            void verBio(BuildContext context) {
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Center(
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(top: 10),
                                          child: Container(
                                            width: 40,
                                            height: 4,
                                            decoration: BoxDecoration(
                                                color: Colors.black38,
                                                borderRadius:
                                                    BorderRadius.circular(12)),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Text(
                                          biografia,
                                          style: const TextStyle(fontSize: 18),
                                        ),
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
                            }

                            verBio(context);
                          },
                          child: Container(
                            width: 70,
                            height: 30,
                            decoration: BoxDecoration(
                                border:
                                    Border.all(width: 1, color: Colors.black26),
                                borderRadius: BorderRadius.circular(8)),
                            child: const Center(
                              child: Text('Bio',
                                  style:
                                      TextStyle(fontWeight: FontWeight.w500)),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: ((context) => mensagens(
                                      idUsuarioDestino: uidPerfil,
                                      nomeDestino: nomePerfil,
                                      imagemPerfilDestino: imagemPerfil,
                                      sobrenomeDestino: sobrenomePerfil,
                                      usernameDestino: username,
                                    )),
                              ),
                            );
                          },
                          child: Container(
                            width: 165,
                            height: 30,
                            decoration: BoxDecoration(
                                border:
                                    Border.all(width: 1, color: Colors.black26),
                                borderRadius: BorderRadius.circular(8)),
                            child: const Center(
                              child: Text(
                                'Mensagem',
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            seguirUsuario();
                          },
                          child: Container(
                            width: 100,
                            height: 30,
                            decoration: BoxDecoration(
                                border:
                                    Border.all(width: 1, color: Colors.black26),
                                borderRadius: BorderRadius.circular(8)),
                            child: Center(
                              child: StreamBuilder<DocumentSnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection('usuarios')
                                    .doc(uidPerfil)
                                    .collection('seguidores')
                                    .doc(idUsuarioLogado)
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData ||
                                      !snapshot.data!.exists) {
                                    // Se não houver dados (usuário não curtiu), mostre o ícone de coração vazio
                                    return const Text('Seguir',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w500));
                                  }

                                  // Se houver dados (usuário já curtiu), mostre o ícone de coração cheio
                                  return const Text('Seguindo',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500));
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 5),
              Container(
                width: double.infinity,
                height: 1,
                color: Colors.black12,
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.only(top: 5, left: 0, right: 0),
                child: Container(
                  width: 200,
                  height: 50,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12)),
                  child: TabBar(
                      indicator: const BoxDecoration(
                        color: Colors.white,
                        border: Border(
                            bottom: BorderSide(
                                width: 3,
                                color: Color.fromARGB(255, 196, 218, 255))),
                      ),
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.black,
                      tabs: [
                        Tab(
                          child: SizedBox(
                            width: 24,
                            child: Image.asset(
                              'assets/galeria.png',
                            ),
                          ),
                        ),
                        Tab(
                          child: SizedBox(
                            width: 23,
                            child: Image.asset(
                              'assets/textos_02.png',
                            ),
                          ),
                        ),
                      ]),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Expanded(
                child: TabBarView(children: [
                  postagens_imagens_visitas(
                    autoId: uidPerfil,
                    nome: nome,
                  ),
                  postagens_textos_visita(
                    autoId: uidPerfil,
                    nome: nome,
                  ),
                ]),
              )
            ],
          ),
        ),
      ),
    );
  }
}
