import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:editora_izyncor_app/interior_usuario/chat/visualizar_chat.dart';
import 'package:editora_izyncor_app/interior_usuario/homepage/feed/processo_postagem/postagem_tela01.dart';
import 'package:editora_izyncor_app/interior_usuario/interior_principal.dart';
import 'package:editora_izyncor_app/interior_usuario/perfil/meu_perfil.dart';
import 'package:editora_izyncor_app/interior_usuario/store/base_store.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class home_principal extends StatefulWidget {
  const home_principal({super.key});

  @override
  State<home_principal> createState() => _home_principalState();
}

class _home_principalState extends State<home_principal> {
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
    const principal(),
    const visualizar_chat(),
    const postagem_tela01(),
    const store(),
    const perfil(),
  ];

  @override
  initState() {
    super.initState();
    recuperarDadosUsuario();
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    body: _paginas[paginasIndex],  // Use the selected page based on paginasIndex
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
            width: 20,
            child: Image.asset(
              paginasIndex == 0 ? 'assets/home_02.png' : 'assets/home_01.png',
            ),
          ),
        ),
        BottomNavigationBarItem(
          label: 'oi',
          icon: SizedBox(
            width: 20,
            child: Image.asset(
              paginasIndex == 1 ? 'assets/user_02.png' : 'assets/user_01.png',
            ),
          ),
        ),
        BottomNavigationBarItem(
          label: 'oi',
          icon: GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const postagem_tela01()));
            },
            child: SizedBox(
              width: 23,
              child: Image.asset('assets/add_02.png'),
            ),
          ),
        ),
        BottomNavigationBarItem(
          label: 'oi',
          icon: SizedBox(
            width: 20,
            child: Image.asset(
              paginasIndex == 3 ? 'assets/shop_02.png' : 'assets/shop_01.png',
            ),
          ),
        ),
        BottomNavigationBarItem(
          label: 'oi',
          icon: Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Container(
              width: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(width: 2, color: paginasIndex == 4 ? Color.fromARGB(255, 185, 131, 144) : Colors.white)
              ),
              child: ClipOval(
                child: CachedNetworkImage(
                  imageUrl: urlImagem,
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}}