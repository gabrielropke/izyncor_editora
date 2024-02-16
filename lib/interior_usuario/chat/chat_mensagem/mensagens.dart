import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:editora_izyncor_app/interior_usuario/chat/chat_mensagem/widget_chat/appbar_chat.dart';
import 'package:editora_izyncor_app/interior_usuario/chat/chat_mensagem/widget_chat/mensagens_widget.dart';
import 'package:editora_izyncor_app/interior_usuario/chat/chat_mensagem/widget_chat/textfield_chat.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MensagemPage extends StatefulWidget {
  final String idUsuarioDestino;
  const MensagemPage({
    super.key,
    required this.idUsuarioDestino,
  });

  @override
  State<MensagemPage> createState() => _MensagemPageState();
}

class _MensagemPageState extends State<MensagemPage> {
  FirebaseAuth auth = FirebaseAuth.instance;

  TextEditingController controllerMensagem = TextEditingController();

  late String idUsuarioDestino;
  String nome = '';
  String sobrenome = '';
  String cadastro = '';
  String biografia = '';
  String username = '';
  String urlPerfil = '';
  String? idUsuarioLogado;
  String nomeDestino = '';
  String sobrenomeDestino = '';
  String usernameDestino = '';
  String urlImagemDestino = '';

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
          biografia = userData['biografia'];
          username = userData['username'];
          urlPerfil = userData['urlImagem'];
        });
      }
    }
  }

  Future<void> recuperarDadosDestino() async {
    DocumentSnapshot<Map<String, dynamic>> userData = await FirebaseFirestore
        .instance
        .collection('usuarios')
        .doc(idUsuarioDestino)
        .get();
    if (userData.exists) {
      setState(() {
        nomeDestino = userData['nome'];
        sobrenomeDestino = userData['sobrenome'];
        usernameDestino = userData['username'];
        urlImagemDestino = userData['urlImagem'];
      });
    }
  }

  Future<void> enviarMensagem() async {
    String mensagem = controllerMensagem.text;

    final String postId =
        FirebaseFirestore.instance.collection('feed').doc().id;

    if (idUsuarioLogado == null) {
      await FirebaseFirestore.instance.collection('feed').doc(postId).set({
        'hora': Timestamp.now().toString(),
        'idUsuarioLogado': idUsuarioLogado,
        'idUsuarioDestino': 'idUsuarioDestino',
        'lida': 'novo',
        'mensagem': mensagem,
        'tipo': 'texto',
        'urlImagem': 'vazia'
      });
    }
  }

  @override
void initState() {
  super.initState();
  idUsuarioDestino = widget.idUsuarioDestino;
  recuperarDadosUsuario();
  recuperarDadosDestino();
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 236, 236, 236),
      appBar: appbar_chat(
        idUsuarioDestino: idUsuarioDestino,
        nomeDestino: nomeDestino,
        imagemPerfilDestino: urlImagemDestino,
        sobrenomeDestino: sobrenomeDestino,
        idUsuarioLogado: idUsuarioLogado!,
        usernameDestino: usernameDestino,
      ),
      body: Column(
        children: [
          Expanded(
            child: mensagens_widget(
              idUsuarioLogado: idUsuarioLogado!,
              idUsuarioDestino: idUsuarioDestino,
              nomeDestino: nomeDestino,
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                height: 70,
                color: const Color.fromARGB(255, 236, 236, 236),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: textfield_chat(
                    controller: controllerMensagem,
                    idUsuarioLogado: idUsuarioLogado!,
                    idUsuarioDestino: idUsuarioDestino,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
