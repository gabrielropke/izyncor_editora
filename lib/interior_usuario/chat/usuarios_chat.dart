import 'package:editora_izyncor_app/interior_usuario/perfil_visita/perfil_visita.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../model/usuario.dart';

class usuarios_chat extends StatefulWidget {
  const usuarios_chat({Key? key});

  @override
  State<usuarios_chat> createState() => _usuarios_chatState();
}

class _usuarios_chatState extends State<usuarios_chat> {
  String pesquisa = '';
  String? _emailUsuarioLogado;

  final List<String> cadastros = [
    'Leitor(a)',
    'Autor(a)',
    'Influenciador(a)',
    'Profissional',
    'Empresarial'
  ];

  Future<List<Usuario>> _recuperarContatos() async {
    FirebaseFirestore db = FirebaseFirestore.instance;

    QuerySnapshot querySnapshot = await db.collection("usuarios").get();

    List<Usuario> listaUsuarios = [];

    for (DocumentSnapshot item in querySnapshot.docs) {
      Map dadosmap = {};
      var dados = item.data();
      dadosmap = dados as Map;
      print(_emailUsuarioLogado);
      if (dadosmap["email"] == _emailUsuarioLogado) continue;

      Usuario usuario = Usuario();
      usuario.idUsuario = item.id;
      usuario.email = dados["email"];
      usuario.nome = dados["nome"];
      usuario.username = dados["username"];
      usuario.sobrenome = dados["sobrenome"];
      usuario.urlImagem = dados["urlImagem"];
      usuario.cadastro = dados["Cadastro"];
      usuario.biografia = dados['biografia'];

      // Verifique se o nome de usuário ou o nome começa com a pesquisa
      if (usuario.username.toLowerCase().startsWith(pesquisa.toLowerCase()) ||
          ("${usuario.nome} ${usuario.sobrenome}")
              .toLowerCase()
              .startsWith(pesquisa.toLowerCase())) {
        listaUsuarios.add(usuario);
      }
    }

    listaUsuarios
        .sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()));
    return listaUsuarios;
  }

  _recuperarDadosUsuario() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    var usuarioLogado = auth.currentUser;
    _emailUsuarioLogado = usuarioLogado?.email;
  }

  @override
  void initState() {
    _recuperarDadosUsuario();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Card(
          color: Colors.white,
          child: TextField(
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Pesquisar usuários...',
            ),
            onChanged: (val) {
              setState(() {
                pesquisa = val;
              });
            },
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: pesquisa.isEmpty
            ? const Align(
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.public, color: Colors.black12, size: 90),
                    Text(
                      'Pesquise por usuários',
                      style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.black26,
                          fontSize: 18),
                    )
                  ],
                ),
              )
            : FutureBuilder<List<Usuario>>(
                future: _recuperarContatos(),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.none:
                    case ConnectionState.waiting:
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    case ConnectionState.active:
                    case ConnectionState.done:
                      if (snapshot.hasData) {
                        List<Usuario>? listaUsuarios = snapshot.data;
                        return ListView.builder(
                          itemCount: listaUsuarios?.length,
                          itemBuilder: (context, index) {
                            Usuario usuario = listaUsuarios![index];
                            return Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: ListTile(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => perfil_visita(
                                          uidPerfil: usuario.idUsuario,
                                          nome: usuario.nome,
                                          imagemPerfil: usuario.urlImagem,
                                          sobrenome: usuario.sobrenome,
                                          cadastro: usuario.cadastro),
                                    ),
                                  );
                                },
                                title: Text(
                                  "${usuario.nome} ${usuario.sobrenome}",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.black54,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                leading: CircleAvatar(
                                  radius: 25,
                                  backgroundColor: Colors.grey,
                                  backgroundImage:
                                      NetworkImage(usuario.urlImagem),
                                ),
                              ),
                            );
                          },
                        );
                      } else {
                        return const Center(
                          child: Text("Não há contatos"),
                        );
                      }
                  }
                },
              ),
      ),
    );
  }
}
