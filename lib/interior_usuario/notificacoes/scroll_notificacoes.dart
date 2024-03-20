import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:editora_izyncor_app/interior_usuario/notificacoes/tipos/noti_mensagem.dart';
import 'package:editora_izyncor_app/interior_usuario/notificacoes/tipos/noti_postagem.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class ScrollNotificacoes extends StatefulWidget {
  const ScrollNotificacoes({Key? key}) : super(key: key);

  @override
  State<ScrollNotificacoes> createState() => _ScrollNotificacoesState();
}

class _ScrollNotificacoesState extends State<ScrollNotificacoes> {
  FirebaseAuth auth = FirebaseAuth.instance;
  String? idUsuarioLogado;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Future<void> recuperarDadosUsuario() async {
    User? usuarioLogado = auth.currentUser;
    if (usuarioLogado != null) {
      idUsuarioLogado = usuarioLogado.uid;
    }
  }

  void selecionarGeral(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(
              20.0), // Defina o raio para bordas arredondadas superiores
        ),
      ),
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: Colors.black38,
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            ListTile(
              leading:
                  SizedBox(width: 25, child: Image.asset('assets/lixeira.png')),
              title: const Text('Excluir'),
              onTap: () {
                Navigator.pop(context);
                showAlertAtencao();
              },
            ),
            if (Platform.isIOS)
              const SizedBox(
                width: double.infinity,
                height: 40,
              )
          ],
        );
      },
    );
  }

  void showAlertAtencao() {
    QuickAlert.show(
        context: context,
        title: 'Atenção',
        text: 'Deseja realmente excluir todas as notificações?',
        confirmBtnText: 'Sim',
        onConfirmBtnTap: () {
          excluirPostGeral();
          Navigator.pop(context);
        },
        type: QuickAlertType.error);
  }

  void excluirPostGeral() {
    if (idUsuarioLogado != null) {
      CollectionReference notificacoesCollection =
          FirebaseFirestore.instance.collection('usuarios');

      CollectionReference notificacoesRef = notificacoesCollection
          .doc(idUsuarioLogado)
          .collection('notificacoes');

      notificacoesRef.get().then((querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          doc.reference.delete();
        });
      });
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
        appBar: AppBar(
          backgroundColor: Colors.white,
          centerTitle: true, title: const Text('Notificações'), actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () {
                selecionarGeral(context);
              },
              child: const Icon(Icons.more_horiz),
            ),
          ),
        ],),
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
                    color: const Color.fromARGB(255, 244, 244, 243),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  labelColor: Color.fromARGB(255, 0, 0, 0),
                  unselectedLabelColor: Color.fromARGB(255, 211, 207, 207),
                  tabs: const [
                    Tab(
                      child: Text(
                        'Geral',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                    Tab(
                      child: Text(
                        'Mensagens',
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
                NotiPostagem(),
                NotiMensagem(),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
