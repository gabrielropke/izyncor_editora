import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:editora_izyncor_app/interior_usuario/chat/mensagens_chat.dart';
import 'package:editora_izyncor_app/interior_usuario/chat/tela.dart';
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
  String sobrenomePerfil = '';
  String username = '';

  recuperarDadosUsuario() async {
    User? usuarioLogado = auth.currentUser;
    if (usuarioLogado != null) {
      idUsuarioLogado = usuarioLogado.uid;
    }
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
          title: Text('@$username'),
          actions: [
            Padding(
              padding: EdgeInsets.only(right: 10),
              child: GestureDetector(
                  onTap: () {
                    verItem(context);
                  },
                  child: Icon(Icons.menu)),
            )
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Row(
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
                            width: 75,
                            height: 75,
                            color: Colors.black12,
                            child: CachedNetworkImage(
                              imageUrl: imagemPerfil,
                              fit: BoxFit
                                  .cover, // ajuste de acordo com suas necessidades
                              placeholder: (context, url) =>
                                  const CircularProgressIndicator(color: Colors.white,), // um indicador de carregamento
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
                    height: 120,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: ((context) =>
                                              const gravar())));
                                },
                                child: Column(
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
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    seguirUsuario();
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    height: 30,
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            width: 1, color: Colors.black26),
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
                                            return Text('Seguir $nome',
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.w500));
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
                                const SizedBox(height: 5),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: ((context) => Mensagens(
                                                uidPerfil: uidPerfil,
                                                nome: nome,
                                                imagemPerfil: imagemPerfil,
                                                sobrenome: sobrenome)),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        width: 190,
                                        height: 30,
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                width: 1,
                                                color: Colors.black26),
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                        child: const Center(
                                          child: Text(
                                            'Mensagem',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w500),
                                          ),
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        void verBio(BuildContext context) {
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
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
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
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 20),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              16.0),
                                                      child: Text(
                                                        biografia,
                                                        style: const TextStyle(
                                                            fontSize: 18),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 30)
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
                                            border: Border.all(
                                                width: 1,
                                                color: Colors.black26),
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                        child: const Center(
                                          child: Text('Bio',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w500)),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          )
                        ]),
                  )
                ],
              ),
              const SizedBox(height: 5),
              Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$nome $sobrenomePerfil',
                      style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                          fontSize: 20),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      cadastroPerfil,
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                height: 1,
                color: Colors.black12,
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.only(top: 5, left: 0, right: 0),
                child: Container(
                  width: 250,
                  height: 30,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12)),
                  child: TabBar(
                      indicator: BoxDecoration(
                        color: Color.fromARGB(255, 132, 165, 228),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.black,
                      tabs: const [
                        Tab(
                          child: Icon(Icons.image, size: 23),
                        ),
                        Tab(
                          child: Icon(Icons.text_fields, size: 23),
                        ),
                      ]),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Expanded(
                child: TabBarView(children: [
                  postagens_imagens_visita(autoId: uidPerfil),
                  postagens_textos_visita(autoId: uidPerfil),
                ]),
              )
            ],
          ),
        ),
      ),
    );
  }
}
