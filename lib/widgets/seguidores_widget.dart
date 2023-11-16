import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:editora_izyncor_app/interior_usuario/perfil/adendos/seguidores_page.dart';
import 'package:editora_izyncor_app/interior_usuario/perfil/adendos/seguindo_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class seguidores_widget extends StatefulWidget {
  const seguidores_widget({super.key});

  @override
  State<seguidores_widget> createState() => _seguidores_widgetState();
}

class _seguidores_widgetState extends State<seguidores_widget> {
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

  @override
  void initState() {
    super.initState();
    recuperarDadosUsuario();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const seguidores_page()));
          },
          child: Container(
            color: Colors.white,
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const seguindo_page()));
                  },
                  child: Container(
                    color: Colors.white,
                    child: Row(
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

                            final seguidores = snapshot.data!.get('seguindo');
                            return Text('$seguidores',
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14));
                          },
                        ),
                        const SizedBox(width: 5),
                        const Text('Seguindo',
                            style: TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.w300,
                                fontSize: 14)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 1,
                  height: 15,
                  color: Colors.black12,
                ),
                const SizedBox(width: 10),
                StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('usuarios')
                      .doc(idUsuarioLogado) // Use o título como ID do documento
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Text(
                        '0',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      );
                    }

                    final seguidores = snapshot.data!.get('seguidores');
                    return Text('$seguidores',
                        style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                            fontSize: 14));
                  },
                ),
                const SizedBox(width: 5),
                const Text('Seguidores',
                    style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w300,
                        fontSize: 14)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
