import 'dart:async';
import 'package:editora_izyncor_app/interior_usuario/perfil/salvos/salvos_imagens.dart';
import 'package:editora_izyncor_app/interior_usuario/perfil/salvos/salvos_textos.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ScrollSalvos extends StatefulWidget {
  const ScrollSalvos({Key? key}) : super(key: key);

  @override
  State<ScrollSalvos> createState() => _ScrollSalvosState();
}

class _ScrollSalvosState extends State<ScrollSalvos> {
  FirebaseAuth auth = FirebaseAuth.instance;
  String? idUsuarioLogado;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Future<void> recuperarDadosUsuario() async {
    User? usuarioLogado = auth.currentUser;
    if (usuarioLogado != null) {
      idUsuarioLogado = usuarioLogado.uid;
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
        backgroundColor: Colors.white,
        key: _scaffoldKey,
        appBar: AppBar(centerTitle: true, title: const Text('Salvos')),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 10, left: 40, right: 40),
              child: Container(
                height: 35,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 244, 244, 243),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: TabBar(
                  indicator: BoxDecoration(
                    border: Border.all(
                      color: const Color.fromARGB(255, 244, 244, 243),
                      width: 3,
                    ),
                    color: Color.fromARGB(255, 244, 244, 243),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  labelColor: Color.fromARGB(255, 0, 0, 0),
                  unselectedLabelColor: Color.fromARGB(255, 211, 207, 207),
                  tabs: const [
                    Tab(
                      child: Text(
                        'Imagens',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                    Tab(
                      child: Text(
                        'Textos',
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
            Expanded(
              child: TabBarView(children: [
                SalvosImagensPage(),
                SalvosTextosPage(),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
