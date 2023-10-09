import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class respostas_ver extends StatefulWidget {
  final String uidUsuario;
  final String refComentario;
  final String titulo;
  final String texto;
  final String hora;
  final String imageUrl;
  const respostas_ver(
      {super.key,
      required this.uidUsuario,
      required this.refComentario,
      required this.titulo,
      required this.texto,
      required this.hora,
      required this.imageUrl});

  @override
  State<respostas_ver> createState() => _respostas_verState();
}

class _respostas_verState extends State<respostas_ver> {

  StreamController<String> streamNome = StreamController<String>();
  StreamController<String> streamNomeComentario = StreamController<String>();
  TextEditingController respostaController = TextEditingController();

  String? uidUsuario;
  String? _idUsuarioLogado;
  String? refComentario;
  String nomeComentario = '';
  String? titulo;
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
    titulo = widget.titulo;
    texto = widget.texto;
    hora = widget.hora;
    imageUrl = widget.imageUrl;
    recuperarDadosUsuario();
    recuperarDadosComentario();
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
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('novidades')
            .doc(titulo)
            .collection('comentar')
            .doc(refComentario)
            .collection('respostas')
            .orderBy('hora', descending: true)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
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
                    return const Text('Erro ao carregar os dados do usuário');
                  } else {
                    String userName = snapshot.data!['nome']!;
                    String imageUrl = snapshot.data!['urlImagem']!;

                    return Padding(
                      padding: const EdgeInsets.all(12.0),
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
                                        color: Color.fromARGB(255, 191, 46, 87),
                                      ),
                                      title: const Text('Excluir'),
                                      onTap: () {
                                        FirebaseFirestore.instance
                                            .collection('novidades')
                                            .doc(titulo)
                                            .collection('comentar')
                                            .doc(refComentario)
                                            .collection('respostas')
                                            .doc(refResposta)
                                            .delete()
                                            .then((_) {
                                          FirebaseFirestore.instance
                                              .collection('novidades')
                                              .doc(titulo)
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
                            leading: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color:
                                        const Color.fromARGB(255, 202, 30, 82),
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
                            title: Stack(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            const Text(
                                              ' • ',
                                              style:
                                                  TextStyle(color: Colors.grey),
                                            ),
                                            Text(
                                              formatarHora(hora),
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(texto),
                                    ),
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
    );
  }
}
