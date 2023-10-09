import 'package:editora_izyncor_app/interior_usuario/chat/visualizar_chat.dart';
import 'package:editora_izyncor_app/interior_usuario/homepage/feed/processo_postagem/postagem_tela01.dart';
import 'package:editora_izyncor_app/interior_usuario/interior_principal.dart';
import 'package:editora_izyncor_app/interior_usuario/perfil/meu_perfil.dart';
import 'package:editora_izyncor_app/interior_usuario/store/base_store.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class home_principal extends StatefulWidget {
  const home_principal({super.key});

  @override
  State<home_principal> createState() => _home_principalState();
}

class _home_principalState extends State<home_principal> {
  int paginasIndex = 0;

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
  Widget build(BuildContext context) {
    return Scaffold(
      body: _paginas[paginasIndex],
      bottomNavigationBar: GNav(
        backgroundColor: Colors.white,
        color: Colors.black,
        activeColor: Colors.black,
        gap: 10,
        onTabChange: (index) => navegarPaginas(index),
        tabs: [
          paginasIndex == 0
              ? const GButton(icon: Icons.home)
              : const GButton(icon: Icons.home_outlined),
          paginasIndex == 1
              ? const GButton(icon: Icons.contacts)
              : const GButton(icon: Icons.contacts_outlined),
          const GButton(icon: Icons.add_circle_rounded),
          paginasIndex == 3
              ? const GButton(icon: Icons.shopping_bag_rounded)
              : const GButton(icon: Icons.shopping_bag_outlined),
          paginasIndex == 4
              ? const GButton(icon: Icons.person)
              : const GButton(icon: Icons.person_outline),
        ],
      ),
    );
  }
}
