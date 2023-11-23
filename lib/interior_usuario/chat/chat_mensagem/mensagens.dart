import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:editora_izyncor_app/interior_usuario/chat/chat_mensagem/widget_chat/appbar_chat.dart';
import 'package:editora_izyncor_app/interior_usuario/chat/chat_mensagem/widget_chat/mensagens_widget.dart';
import 'package:editora_izyncor_app/interior_usuario/chat/chat_mensagem/widget_chat/textfield_chat.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class mensagens extends StatefulWidget {
  final String idUsuarioDestino;
  final String nomeDestino;
  final String imagemPerfilDestino;
  final String sobrenomeDestino;
  final String usernameDestino;
  const mensagens(
      {super.key,
      required this.idUsuarioDestino,
      required this.nomeDestino,
      required this.imagemPerfilDestino,
      required this.sobrenomeDestino,
      required this.usernameDestino});

  @override
  State<mensagens> createState() => _mensagensState();
}

class _mensagensState extends State<mensagens> {
  FirebaseAuth auth = FirebaseAuth.instance;

  TextEditingController controllerMensagem = TextEditingController();

  late String idUsuarioDestino;
  late String nomeDestino;
  late String imagemPerfilDestino;
  late String sobrenomeDestino;
  late String usernameDestino;
  String nome = '';
  String sobrenome = '';
  String cadastro = '';
  String biografia = '';
  String username = '';
  String urlPerfil = '';
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
    // TODO: implement initState
    super.initState();
    recuperarDadosUsuario();
    idUsuarioDestino = widget.idUsuarioDestino;
    nomeDestino = widget.nomeDestino;
    sobrenomeDestino = widget.sobrenomeDestino;
    imagemPerfilDestino = widget.imagemPerfilDestino;
    usernameDestino = widget.usernameDestino;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 251, 244),
      appBar: appbar_chat(
        idUsuarioDestino: idUsuarioDestino,
        nomeDestino: nomeDestino,
        imagemPerfilDestino: imagemPerfilDestino,
        sobrenomeDestino: sobrenomeDestino,
        idUsuarioLogado: idUsuarioLogado!,
        usernameDestino: usernameDestino,
      ),
      body: Stack(
        children: [
          mensagens_widget(
            idUsuarioLogado: idUsuarioLogado!,
            idUsuarioDestino: idUsuarioDestino,
            imagemPerfilDestino: imagemPerfilDestino,
            nomeDestino: nomeDestino,
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              height: 70,
              color: Color.fromARGB(31, 209, 209, 209),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: textfield_chat(
                  controller: controllerMensagem,
                  idUsuarioLogado: idUsuarioLogado!,
                  idUsuarioDestino: idUsuarioDestino,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
