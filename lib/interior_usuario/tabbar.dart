import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:editora_izyncor_app/interior_usuario/chat/conversas_chat.dart';
import 'package:editora_izyncor_app/interior_usuario/chat/usuarios_chat.dart';
import 'package:editora_izyncor_app/interior_usuario/homepage/feed/processo_postagem/postagem_tela01.dart';
import 'package:editora_izyncor_app/interior_usuario/interior_principal.dart';
import 'package:editora_izyncor_app/interior_usuario/notificacoes/notificacao_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class home_principal extends StatefulWidget {
  final int indexPagina;
  const home_principal({super.key, required this.indexPagina});

  @override
  State<home_principal> createState() => _home_principalState();
}

class _home_principalState extends State<home_principal> {
  late int indexPagina;
  FirebaseAuth auth = FirebaseAuth.instance;
  int paginasIndex = 0;
  String urlImagem = '';
  String? idUsuarioLogado;
  bool visto = false;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
      _notificacoesSubscription;

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
          urlImagem = userData['urlImagem'];
        });
      }
    }
  }

  void navegarPaginas(index) {
    setState(() {
      paginasIndex = index;
    });
  }

  final List _paginas = [
    const usuarios_chat(),
    const principal(),
    const notificacao_page(),
    const conversas_chat(),
  ];

  Future<void> verificarNotificacoes() async {
    QuerySnapshot<Map<String, dynamic>> notificacoesSnapshot =
        await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(idUsuarioLogado)
            .collection('notificacoes')
            .where('status', isEqualTo: 'novo')
            .get();

    if (notificacoesSnapshot.docs.isNotEmpty) {
      setState(() {
        visto = true;
      });
      print(visto);
    } else {
      setState(() {
        visto = false;
      });
      print(visto);
    }
  }

  void iniciarVerificacaoNotificacoes() {
    _notificacoesSubscription = FirebaseFirestore.instance
        .collection('usuarios')
        .doc(idUsuarioLogado)
        .collection('notificacoes')
        .where('status', isEqualTo: 'novo')
        .snapshots()
        .listen((querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          visto = true;
        });
        print(visto);
      } else {
        setState(() {
          visto = false;
        });
        print(visto);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    recuperarDadosUsuario();
    paginasIndex = widget.indexPagina;
    iniciarVerificacaoNotificacoes();
  }

  @override
  void dispose() {
    _notificacoesSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          _paginas[paginasIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        onTap: navegarPaginas,
        currentIndex: paginasIndex,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        elevation: 0,
        items: [
          BottomNavigationBarItem(
            label: 'oi',
            icon: SizedBox(
              width: 22,
              child: Image.asset(
                'assets/pesquisa.png',
              ),
            ),
          ),
          BottomNavigationBarItem(
            label: 'oi',
            icon: SizedBox(
              width: 22,
              child: Image.asset(
                paginasIndex == 1 ? 'assets/home_02.png' : 'assets/home_01.png',
              ),
            ),
          ),
          BottomNavigationBarItem(
            label: 'oi',
            icon: Stack(
              children: [
                SizedBox(
                  width: 22,
                  child: Image.asset(
                    paginasIndex == 2
                        ? 'assets/icone_sino_02.png'
                        : 'assets/icone_sino_01.png',
                  ),
                ),
                // ignore: unrelated_type_equality_checks
                if (visto == true)
                  Padding(
                    padding: const EdgeInsets.only(left: 15),
                    child: Container(
                      // width: 13,
                      // height: 13,
                      decoration: const BoxDecoration(
                          shape: BoxShape.circle, color: Colors.white),
                      child: const Icon(Icons.circle,
                          size: 12, color: Color.fromARGB(255, 212, 18, 99)),
                    ),
                  ),
              ],
            ),
          ),
          BottomNavigationBarItem(
            label: 'oi',
            icon: SizedBox(
              width: 20,
              child: Image.asset(
                paginasIndex == 3 ? 'assets/user_02.png' : 'assets/user_01.png',
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const postagem_tela01()));
        },
        backgroundColor: const Color.fromARGB(255, 42, 56, 66),
        mini: false,
        child: const Icon(
          Icons.add,
          size: 18,
          color: Colors.white,
        ),
      ),
    );
  }
}
