import 'package:cached_network_image/cached_network_image.dart';
import 'package:editora_izyncor_app/interior_usuario/homepage/feed/widgets/postagens_individuais.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CurtidasTextosPage extends StatefulWidget {
  @override
  _CurtidasTextosPageState createState() => _CurtidasTextosPageState();
}

class _CurtidasTextosPageState extends State<CurtidasTextosPage> {
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
            .collection('curtidas')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          var curtidasPost = snapshot.data?.docs;

          if (curtidasPost!.isEmpty) {
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

          List<DocumentSnapshot> curtidas = snapshot.data!.docs;

          return Padding(
            padding: const EdgeInsets.all(6.0),
            child: ListView.builder(
              itemCount: curtidas.length,
              itemBuilder: (context, index) {
                var idPostagem = curtidas[index].get('idPostagem');
                var imagemPerfil = curtidas[index].get('perfilAutor');
                var titulo = curtidas[index].get('titulo');
                var imagemUrl = curtidas[index].get('imagemUrl');

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
                                    imagemPostagem: imagemUrl)));
                      },
                      child: Container(
                        width: double.infinity,
                        height: 55,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(32),
                            color: const Color.fromARGB(255, 240, 240, 240)),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  ClipOval(
                                    child: SizedBox(
                                      width: 40,
                                      height: 40,
                                      child: CachedNetworkImage(
                                        imageUrl: imagemPerfil,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Text(
                                    titulo,
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500),
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
                                                    imagemPostagem:
                                                        imagemUrl)));
                                  },
                                  icon: const Icon(
                                      Icons.keyboard_arrow_right_rounded))
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
