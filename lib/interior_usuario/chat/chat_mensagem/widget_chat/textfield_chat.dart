import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:editora_izyncor_app/interior_usuario/chat/chat_mensagem/widget_chat/anexos_chat.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class textfield_chat extends StatefulWidget {
  const textfield_chat(
      {super.key,
      required this.controller,
      this.prefixIcon,
      this.suffixIcon,
      this.maxLength,
      this.maxLines,
      required this.idUsuarioLogado,
      required this.idUsuarioDestino});

  final TextEditingController controller;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int? maxLength;
  final int? maxLines;
  final String idUsuarioLogado;
  final String idUsuarioDestino;

  @override
  State<textfield_chat> createState() => _textfield_chatState();
}

class _textfield_chatState extends State<textfield_chat> {
  FirebaseAuth auth = FirebaseAuth.instance;
  late TextEditingController controller;
  late Widget? prefixIcon;
  late Widget? suffixIcon;
  late int? maxLength;
  late int? maxLines;
  late String idUsuarioLogado;
  late String idUsuarioDestino;
  String username = '';
  String urlPerfil = '';

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
          urlPerfil = userData['urlImagem'];
          username = userData['username'];
        });
      }
    }
  }

  Future<void> enviarMensagem() async {
    String mensagem = controller.text;

    // Cria um ID de mensagem único
    String idMensagem = FirebaseFirestore.instance.collection('chat').doc().id;

    // ignore: unnecessary_null_comparison
    if (idUsuarioLogado != null) {
      await FirebaseFirestore.instance
          .collection('chat')
          .doc(idUsuarioLogado)
          .collection(idUsuarioDestino)
          .doc(idMensagem)
          .set({
        'hora': DateTime.now().toString(),
        'idMensagem': idMensagem,
        'idRemetente': idUsuarioLogado,
        'idDestinatario': idUsuarioDestino,
        'lida': 'novo',
        'mensagem': mensagem,
        'tipo': 'texto',
        'urlImagem': 'vazia',
      });

      print('Mensagem enviada');
      enviarNotificacao();
      controller.clear();
    }

    await FirebaseFirestore.instance
        .collection('chat')
        .doc(idUsuarioDestino)
        .collection(idUsuarioLogado)
        .doc(idMensagem)
        .set({
      'hora': DateTime.now().toString(),
      'idMensagem': idMensagem,
      'idRemetente': idUsuarioLogado,
      'idDestinatario': idUsuarioDestino,
      'lida': 'novo',
      'mensagem': mensagem,
      'tipo': 'texto',
      'urlImagem': 'vazia',
    });

    print('Mensagem recebida pelo destinatário');
    controller.clear();
  }

  void enviarNotificacao() {
    CollectionReference usuariosCollection =
        FirebaseFirestore.instance.collection('usuarios');

    DocumentReference usuarioRef = usuariosCollection.doc(idUsuarioDestino);

    usuarioRef.collection('notificacoes').add({
      'username': username,
      'idUsuario': idUsuarioLogado,
      'mensagem': 'enviou uma mensagem para você.',
      'hora': DateTime.now().toString(),
      'postagem': 'vazio',
      'idPostagem': 'mensagem',
      'perfil': urlPerfil,
      'status': 'novo',
    });
    print('oi');
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    recuperarDadosUsuario();
    controller = widget.controller;
    prefixIcon = widget.prefixIcon;
    suffixIcon = widget.suffixIcon;
    maxLength = widget.maxLength;
    maxLines = widget.maxLines;
    idUsuarioLogado = widget.idUsuarioLogado;
    idUsuarioDestino = widget.idUsuarioDestino;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 0),
            child: TextField(
              textAlign: TextAlign.left,
              controller: controller,
              keyboardType: TextInputType.text,
              style: const TextStyle(
                fontSize: 16,
                color: Color.fromARGB(255, 0, 0, 0),
              ),
              decoration: InputDecoration(
                prefixIcon: anexos_chat(),
                suffixIcon: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: IconButton(
                    color: const Color.fromARGB(255, 46, 43, 43),
                    onPressed: () {
                      enviarMensagem();
                    },
                    icon: Opacity(
                      opacity: 0.6,
                      child: SizedBox(
                        width: 80,
                        child: Image.asset('assets/enviar_3.png',
                            color: const Color.fromARGB(255, 212, 18, 99)),
                      ),
                    ),
                  ),
                ),
                contentPadding: EdgeInsets.fromLTRB(10.0, 25.0, 35.0, 10.0),
                hintText: "Digite uma mensagem...",
                hintStyle: const TextStyle(
                  color: Color.fromARGB(255, 124, 124, 124),
                ),
                filled: true,
                fillColor: const Color.fromARGB(255, 255, 255, 255),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide:
                      BorderSide(color: Color.fromARGB(255, 146, 18, 57)),
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
