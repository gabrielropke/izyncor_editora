import 'dart:async';
import 'package:editora_izyncor_app/interior_usuario/homepage/feed/feed.dart';
import 'package:editora_izyncor_app/interior_usuario/homepage/novidades/novidades.dart';
import 'package:editora_izyncor_app/widgets/drawer/drawer_widget.dart';
import 'package:editora_izyncor_app/widgets/topo_appbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class principal extends StatefulWidget {
  const principal({Key? key}) : super(key: key);

  @override
  State<principal> createState() => _principalState();
}

class _principalState extends State<principal> {
  FirebaseAuth auth = FirebaseAuth.instance;
  String? idUsuarioLogado;
  String? nome;
  String urlImagem = '';

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
          nome = userData['nome'];
        });
      }
    }
  }

  @override
  initState() {
    super.initState();
    recuperarDadosUsuario();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: false,
            title: topo_appbar(
              scaffoldKey: _scaffoldKey,
            )),
        drawer: const drawer_widget(),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 10, left: 40, right: 40),
              child: Container(
                height: 35,
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 244, 244, 243),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: TabBar(
                  indicator: BoxDecoration(
                    border: Border.all(
                      color: const Color.fromARGB(255, 244, 244, 243),
                      width: 3,
                    ),
                    color: Color.fromARGB(255, 255, 255, 255),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  labelColor: Color.fromARGB(255, 0, 0, 0),
                  unselectedLabelColor: Color.fromARGB(255, 211, 207, 207),
                  tabs: const [
                    Tab(
                      child: Text(
                        'Feed',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                    Tab(
                      child: Text(
                        'Novidades',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            const Expanded(
              child: TabBarView(children: [
                feed(),
                novidades(),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
