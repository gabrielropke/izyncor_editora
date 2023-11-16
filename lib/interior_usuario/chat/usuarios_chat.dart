import 'package:cached_network_image/cached_network_image.dart';
import 'package:editora_izyncor_app/interior_usuario/chat/mensagens_chat.dart';
import 'package:editora_izyncor_app/interior_usuario/perfil_visita/perfil_visita.dart';
import 'package:editora_izyncor_app/widgets/drawer/drawer_widget.dart';
import 'package:editora_izyncor_app/widgets/topo_appbar.dart';
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
  FirebaseAuth auth = FirebaseAuth.instance;
  String pesquisa = '';
  String? _emailUsuarioLogado;
  String? idUsuarioLogado;
  String urlImagem = '';

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
      usuario.cadastro = dados["Cadastro"]; // Atualize o campo cadastro

      // Verifique se o nome de usuário, nome ou tipo de cadastro corresponde à pesquisa
      if (usuario.username.toLowerCase().startsWith(pesquisa.toLowerCase()) ||
          ("${usuario.nome} ${usuario.sobrenome}")
              .toLowerCase()
              .startsWith(pesquisa.toLowerCase()) ||
          usuario.cadastro.toLowerCase().startsWith(pesquisa.toLowerCase())) {
        listaUsuarios.add(usuario);
      }
    }

    listaUsuarios
        .sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()));
    return listaUsuarios;
  }

  _recuperarDadosUsuario() async {
    
    var usuarioLogado = auth.currentUser;
    _emailUsuarioLogado = usuarioLogado?.email;
  }

  Future<void> recuperarDadosUsuario2() async {
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

  @override
  void initState() {
    _recuperarDadosUsuario();
    recuperarDadosUsuario2();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      key: _scaffoldKey,
      appBar: AppBar(
        toolbarHeight: 90,
        automaticallyImplyLeading: false,
        foregroundColor: Colors.black,
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: false,
        title: Column(
          children: [
            topo_appbar(scaffoldKey: _scaffoldKey),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 30,
              child: TextField(
                decoration: InputDecoration(
                  border: const OutlineInputBorder(borderSide: BorderSide.none),
                  prefixIcon: Image.asset('assets/pesquisa.png', scale: 3),
                  fillColor: const Color.fromARGB(255, 243, 242, 242),
                  filled: true,
                ),
                onChanged: (val) {
                  setState(() {
                    pesquisa = val;
                  });
                },
              ),
            )
          ],
        ),
      ),
      drawer: const drawer_widget(),
      body: pesquisa.isEmpty
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
                            child: Column(
                              children: [
                                ListTile(
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
                                  title: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "${usuario.nome} ${usuario.sobrenome}",
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              color: Colors.black54,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            usuario.cadastro,
                                            style: const TextStyle(
                                              color: Colors.black54,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          )
                                        ],
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      Mensagens(
                                                          uidPerfil:
                                                              usuario.idUsuario,
                                                          nome: usuario.nome,
                                                          imagemPerfil:
                                                              usuario.urlImagem,
                                                          sobrenome: usuario
                                                              .sobrenome)));
                                        },
                                        child: ClipRRect(
                                          child: SizedBox(
                                            width: 23,
                                            child:
                                                Image.asset('assets/send3.png'),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                  leading: Container(
                                    width: 48,
                                    height: 48,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                    ),
                                    child: ClipOval(
                                      child: CachedNetworkImage(
                                        imageUrl: usuario.urlImagem,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) =>
                                            const CircularProgressIndicator(
                                          color: Colors.white,
                                        ),
                                        errorWidget: (context, url, error) =>
                                            const Icon(Icons.error),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Container(
                                  width: double.infinity,
                                  height: 1,
                                  color: Colors.black12,
                                )
                              ],
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
    );
  }
}
