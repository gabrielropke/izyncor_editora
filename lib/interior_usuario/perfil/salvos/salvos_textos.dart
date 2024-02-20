import 'package:cached_network_image/cached_network_image.dart';
import 'package:editora_izyncor_app/interior_usuario/homepage/feed/widgets/postagens_individuais.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SalvosTextosPage extends StatefulWidget {
  @override
  _SalvosTextosPageState createState() => _SalvosTextosPageState();
}

class _SalvosTextosPageState extends State<SalvosTextosPage> {
  FirebaseAuth auth = FirebaseAuth.instance;

  String? idUsuarioLogado;

  Future<void> recuperarDadosUsuario() async {
    User? usuarioLogado = auth.currentUser;
    if (usuarioLogado != null) {
      idUsuarioLogado = usuarioLogado.uid;
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    recuperarDadosUsuario();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('usuarios')
            .doc(idUsuarioLogado)
            .collection('salvos')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          var salvosPost = snapshot.data?.docs;

          if (salvosPost!.isEmpty) {
            return const Center(
              child: Text(
                'Nada por aqui...',
                style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.black26,
                    fontSize: 20),
                textAlign: TextAlign.center,
              ),
            );
          }

          List<DocumentSnapshot> salvos = snapshot.data!.docs;

          return Padding(
            padding: const EdgeInsets.all(6.0),
            child: ListView.builder(
              itemCount: salvos.length,
              itemBuilder: (context, index) {
                var idPostagem = salvos[index].get('idPostagem');
                var titulo = salvos[index].get('titulo');
                var imagemUrl = salvos[index].get('imagemUrl');
                var idAutor = salvos[index].get('idAutor');

                return FutureBuilder(
                  future: FirebaseFirestore.instance
                      .collection('usuarios')
                      .doc(idAutor)
                      .get(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Container(); // Or a loading indicator
                    }

                    DocumentSnapshot post =
                        snapshot.data as DocumentSnapshot<Object?>;

                    return Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Visibility(
                        visible: imagemUrl == 'vazio',
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => postagens_individuais(
                                  idPostagem: idPostagem,
                                  imagemPostagem: imagemUrl,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            width: double.infinity,
                            height: 55,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(32),
                              color: const Color.fromARGB(255, 240, 240, 240),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      ClipOval(
                                        child: SizedBox(
                                          width: 40,
                                          height: 40,
                                          child: CachedNetworkImage(
                                            imageUrl: post['urlImagem'],
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 20),
                                      Text(
                                        titulo,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      )
                                    ],
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              postagens_individuais(
                                            idPostagem: idPostagem,
                                            imagemPostagem: imagemUrl,
                                          ),
                                        ),
                                      );
                                    },
                                    icon: const Icon(
                                        Icons.keyboard_arrow_right_rounded),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
