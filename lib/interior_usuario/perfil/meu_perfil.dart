import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:editora_izyncor_app/configuracao/tela_config.dart';
import 'package:editora_izyncor_app/interior_usuario/perfil/adendos/seguidores_page.dart';
import 'package:editora_izyncor_app/interior_usuario/perfil/adendos/seguindo_page.dart';
import 'package:editora_izyncor_app/interior_usuario/perfil/editar/editar_perfil.dart';
import 'package:editora_izyncor_app/interior_usuario/perfil/galeria/postagens_imagens.dart';
import 'package:editora_izyncor_app/interior_usuario/perfil/galeria/postagens_textos.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class perfil extends StatefulWidget {
  const perfil({
    super.key,
  });

  @override
  State<perfil> createState() => _perfilState();
}

class _perfilState extends State<perfil> {
  FirebaseAuth auth = FirebaseAuth.instance;

  String? idUsuarioLogado;
  String urlImagem = '';
  String nome = '';
  String sobrenome = '';
  String cadastro = '';
  String biografia = '';
  String username = '';

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
          cadastro = userData['Cadastro'];
          urlImagem = userData['urlImagem'];
          biografia = userData['biografia'];
          username = userData['username'];
        });
      }
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
                  Icons.settings_outlined,
                  color: Colors.black,
                ),
                title: const Text('Configurações'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const home_config()));
                },
              ),
            ),
            ListTile(
              leading: const Icon(
                Icons.account_circle_outlined,
                color: Colors.black,
              ),
              title: const Text('Configurações da conta'),
              onTap: () {
                // Lógica para obter o link
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.edit_outlined,
                color: Colors.black,
              ),
              title: const Text('Editar perfil'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const editar_perfil()));
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
  }

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
          crossAxisAlignment: CrossAxisAlignment.start,
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
              padding: const EdgeInsets.only(top: 20),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  biografia,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
            const SizedBox(height: 30)
          ],
        );
      },
    );
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
                  urlImagem,
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
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Stack(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.arrow_back_ios)),
                    GestureDetector(
                      onTap: () {
                        verItem(context);
                      },
                      child: SizedBox(
                          width: 23, child: Image.asset('assets/settings.png')),
                    )
                  ],
                ),
                Column(
                  children: [
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Stack(
                          children: [
                            Column(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    _exibirImagemFullScreen(urlImagem);
                                  },
                                  child: ClipOval(
                                    child: Container(
                                      width: 75,
                                      height: 75,
                                      color: Colors.white,
                                      child: CachedNetworkImage(
                                        imageUrl: urlImagem,
                                        fit: BoxFit
                                            .cover, // ajuste de acordo com suas necessidades
                                        placeholder: (context, url) =>
                                            const CircularProgressIndicator(
                                          color: Colors.white,
                                        ), // um indicador de carregamento
                                        errorWidget: (context, url, error) =>
                                            const Icon(
                                          Icons.error,
                                          color: Colors.white,
                                        ), // widget de erro
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '$nome $sobrenome',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black,
                                            fontSize: 20),
                                      ),
                                      Text(
                                        cadastro,
                                        style: const TextStyle(
                                            color: Colors.black54),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 90,
                                      color: Colors.white,
                                      child: Column(
                                        children: [
                                          StreamBuilder<DocumentSnapshot>(
                                            stream: FirebaseFirestore.instance
                                                .collection('usuarios')
                                                .doc(
                                                    idUsuarioLogado) // Use o título como ID do documento
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

                                              final seguidores = snapshot.data!
                                                  .get('postagens');
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
                                    Container(
                                      width: 1,
                                      height: 25,
                                      color: Colors.black12,
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const seguidores_page()));
                                      },
                                      child: Container(
                                        width: 90,
                                        color: Colors.white,
                                        child: Column(
                                          children: [
                                            StreamBuilder<DocumentSnapshot>(
                                              stream: FirebaseFirestore.instance
                                                  .collection('usuarios')
                                                  .doc(
                                                      idUsuarioLogado) // Use o título como ID do documento
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

                                                final seguidores = snapshot
                                                    .data!
                                                    .get('seguidores');
                                                return Text('$seguidores',
                                                    style: const TextStyle(
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16));
                                              },
                                            ),
                                            const Text('Seguidores'),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: 1,
                                      height: 25,
                                      color: Colors.black12,
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    seguindo_page()));
                                      },
                                      child: Container(
                                        width: 90,
                                        color: Colors.white,
                                        child: Column(
                                          children: [
                                            StreamBuilder<DocumentSnapshot>(
                                              stream: FirebaseFirestore.instance
                                                  .collection('usuarios')
                                                  .doc(
                                                      idUsuarioLogado) // Use o título como ID do documento
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

                                                final seguidores = snapshot
                                                    .data!
                                                    .get('seguindo');
                                                return Text('$seguidores',
                                                    style: const TextStyle(
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16));
                                              },
                                            ),
                                            const Text('Seguindo'),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          const editar_perfil()));
                                            },
                                            child: Container(
                                              width: 200,
                                              height: 30,
                                              decoration: BoxDecoration(
                                                  border: Border.all(
                                                      width: 1,
                                                      color: Colors.black26),
                                                  borderRadius:
                                                      BorderRadius.circular(8)),
                                              child: const Center(
                                                child: Text('Editar perfil',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500)),
                                              ),
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              verBio(context);
                                            },
                                            child: Container(
                                              width: 60,
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
                                                        fontWeight:
                                                            FontWeight.w500)),
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
                                      color:
                                          Color.fromARGB(255, 196, 218, 255))),
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
                        postagem_imagens(),
                        postagem_textos(nome: nome),
                      ]),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
