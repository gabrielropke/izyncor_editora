import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// ignore: camel_case_types
class SeguidoresVisita extends StatefulWidget {
  final String idPerfil;
  const SeguidoresVisita({Key? key, required this.idPerfil}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _SeguidoresVisitaState createState() => _SeguidoresVisitaState();
}

// ignore: camel_case_types
class _SeguidoresVisitaState extends State<SeguidoresVisita> {
  FirebaseAuth auth = FirebaseAuth.instance;

  String? idUsuarioLogado;
  late String idPerfil;

  @override
  void initState() {
    super.initState();
    recuperarDadosUsuario();
    idPerfil = widget.idPerfil;
  }

  Future<void> recuperarDadosUsuario() async {
    User? usuarioLogado = auth.currentUser;
    if (usuarioLogado != null) {
      idUsuarioLogado = usuarioLogado.uid;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        foregroundColor: Colors.black,
        elevation: 0,
        leadingWidth: 26,
        backgroundColor: Colors.transparent,
        centerTitle: false,
        title: const Text('Seguidores'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('usuarios')
            .doc(idPerfil)
            .collection('seguidores')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          var seguidores = snapshot.data?.docs;

          if (seguidores!.isEmpty) {
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

          return ListView.builder(
            itemCount: seguidores.length,
            itemBuilder: (context, index) {
              var seguidor = seguidores[index];
              var idSeguidor = seguidor['uidusuario'];

              return FutureBuilder(
                future: FirebaseFirestore.instance
                    .collection('usuarios')
                    .doc(idSeguidor)
                    .get(),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator(
                      color: Colors.white,
                    );
                  }
                  if (userSnapshot.hasError) {
                    return Text('Erro: ${userSnapshot.error}');
                  }

                  var userData = userSnapshot.data?.data();
                  if (userData == null) {
                    return const Text('Usuário não encontrado');
                  }

                  // Aqui você pode acessar os valores do documento do usuário
                  var nome = userData['nome'];
                  var sobrenome = userData['sobrenome'];
                  var urlImagem = userData['urlImagem'];
                  var usuario = userData['username'];

                  return ListTile(
                    title: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                ClipOval(
                                  child: CachedNetworkImage(
                                    width: 60,
                                    height: 60,
                                    imageUrl: urlImagem,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('@$usuario',
                                        style: const TextStyle(
                                            color: Colors.black, fontSize: 16)),
                                    Text('$nome $sobrenome',
                                        style: const TextStyle(
                                            color: Colors.black38,
                                            fontSize: 14))
                                  ],
                                ),
                              ],
                            ),
                            GestureDetector(
                              onTap: () {
                                void seguirUsuario() {
                                  if (idUsuarioLogado != null) {
                                    CollectionReference novidadesCollection =
                                        FirebaseFirestore.instance
                                            .collection('usuarios');

                                    novidadesCollection
                                        .doc(idUsuarioLogado)
                                        .collection('seguindo')
                                        .doc(idSeguidor)
                                        .get()
                                        .then((doc) {
                                      if (doc.exists) {
                                        doc.reference.delete().then((_) {
                                          novidadesCollection
                                              .doc(idUsuarioLogado)
                                              .update({
                                            'seguindo':
                                                FieldValue.increment(-1),
                                          });
                                        });
                                      } else {
                                        Map<String, dynamic> seguindoData = {
                                          'hora': DateTime.now().toString(),
                                          'uidusuario': idSeguidor,
                                        };

                                        novidadesCollection
                                            .doc(idUsuarioLogado)
                                            .collection('seguindo')
                                            .doc(idSeguidor)
                                            .set(seguindoData)
                                            .then((_) {
                                          novidadesCollection
                                              .doc(idUsuarioLogado)
                                              .update({
                                            'seguindo': FieldValue.increment(1),
                                          });
                                        });
                                      }
                                    });

                                    // Verificar se o idUsuarioLogado já existe na coleção de curtir
                                    novidadesCollection
                                        .doc(idSeguidor)
                                        .collection('seguidores')
                                        .doc(idUsuarioLogado)
                                        .get()
                                        .then((doc) {
                                      if (doc.exists) {
                                        doc.reference.delete().then((_) {
                                          novidadesCollection
                                              .doc(idSeguidor)
                                              .update({
                                            'seguidores':
                                                FieldValue.increment(-1),
                                          });
                                        });
                                      } else {
                                        Map<String, dynamic> seguidoresData = {
                                          'hora': DateTime.now().toString(),
                                          'uidusuario': idUsuarioLogado,
                                        };

                                        novidadesCollection
                                            .doc(idSeguidor)
                                            .collection('seguidores')
                                            .doc(idUsuarioLogado)
                                            .set(seguidoresData)
                                            .then((_) {
                                          novidadesCollection
                                              .doc(idSeguidor)
                                              .update({
                                            'seguidores':
                                                FieldValue.increment(1),
                                          });
                                        });
                                      }
                                    });
                                  }
                                }

                                seguirUsuario();
                              },
                              child: Container(
                                width: 100,
                                height: 30,
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        width: 1, color: Colors.black26),
                                    borderRadius: BorderRadius.circular(8)),
                                child: Center(
                                  child: StreamBuilder<DocumentSnapshot>(
                                    stream: FirebaseFirestore.instance
                                        .collection('usuarios')
                                        .doc(idSeguidor)
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
                        const SizedBox(height: 4),
                        const Divider(
                          color: Colors.black26,
                        )
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
