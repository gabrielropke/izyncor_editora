import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:editora_izyncor_app/interior_usuario/chat/conversas_chat.dart';
import 'package:editora_izyncor_app/interior_usuario/chat/usuarios_chat.dart';
import 'package:editora_izyncor_app/interior_usuario/estante/estante_page.dart';
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
    const estante_page(),
    const usuarios_chat(),
    const principal(),
    const notificacao_page(),
    const conversas_chat(),
  ];

  @override
  initState() {
    super.initState();
    recuperarDadosUsuario();
    paginasIndex = widget.indexPagina;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          _paginas[paginasIndex], // Use the selected page based on paginasIndex
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
              width: 30,
              child: Image.asset(
                paginasIndex == 0
                    ? 'assets/estante_02.png'
                    : 'assets/estante_01.png',
              ),
            ),
          ),
          BottomNavigationBarItem(
            label: 'oi',
            icon: SizedBox(
              width: 22,
              child: Image.asset(
                paginasIndex == 1
                    ? 'assets/pesquisar_icone.png'
                    : 'assets/pesquisar_icone.png',
              ),
            ),
          ),
          BottomNavigationBarItem(
            label: 'oi',
            icon: SizedBox(
              width: 22,
              child: Image.asset(
                paginasIndex == 2 ? 'assets/home_02.png' : 'assets/home_01.png',
              ),
            ),
          ),
          BottomNavigationBarItem(
            label: 'oi',
            icon: SizedBox(
              width: 22,
              child: Image.asset(
                paginasIndex == 3
                    ? 'assets/icone_sino_02.png'
                    : 'assets/icone_sino_01.png',
              ),
            ),
          ),
          BottomNavigationBarItem(
            label: 'oi',
            icon: SizedBox(
              width: 20,
              child: Image.asset(
                paginasIndex == 4 ? 'assets/user_02.png' : 'assets/user_01.png',
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
        child: const Icon(Icons.add, size: 18),
      ),
    );
  }
}
