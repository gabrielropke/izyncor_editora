import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:readmore/readmore.dart';

class mensagens_widget extends StatefulWidget {
  final String idUsuarioLogado;
  final String idUsuarioDestino;
  final String imagemPerfilDestino;
  final String nomeDestino;
  const mensagens_widget(
      {super.key,
      required this.idUsuarioLogado,
      required this.idUsuarioDestino,
      required this.imagemPerfilDestino,
      required this.nomeDestino});

  @override
  State<mensagens_widget> createState() => _mensagens_widgetState();
}

class _mensagens_widgetState extends State<mensagens_widget> {
  FirebaseFirestore notificacoes = FirebaseFirestore.instance;
  late String idUsuarioLogado;
  late String idUsuarioDestino;
  late double larguraContainer;
  late String imagemPerfilDestino;
  late String nomeDestino;

  void atualizarMensagem(String idMensagem) async {
    await FirebaseFirestore.instance
        .collection('chat')
        .doc(idUsuarioLogado)
        .collection(idUsuarioDestino)
        .doc(idMensagem)
        .update({
      'mensagem': 'Mensagem apagada',
    });
    print('apagado para min');
    await FirebaseFirestore.instance
        .collection('chat')
        .doc(idUsuarioDestino)
        .collection(idUsuarioLogado)
        .doc(idMensagem)
        .update({
      'mensagem': 'Mensagem apagada',
    });
    print('apagado para $nomeDestino');
  }

  void apagarMensagem(String idMensagem) async {
    await FirebaseFirestore.instance
        .collection('chat')
        .doc(idUsuarioLogado)
        .collection(idUsuarioDestino)
        .doc(idMensagem)
        .delete();
  }

  void selecionarMensagem(BuildContext context, String idMensagem, String mensagem) {
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
              title: const Text('Apagar para min'),
              onTap: () {
                Navigator.pop(context);
                apagarMensagem(idMensagem);
              },
            ),
            if (mensagem != 'Mensagem apagada')
            ListTile(
              leading:
                  SizedBox(width: 25, child: Image.asset('assets/lixeira.png')),
              title: const Text('Apagar para todos'),
              onTap: () {
                Navigator.pop(context);
                atualizarMensagem(idMensagem);
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    idUsuarioLogado = widget.idUsuarioLogado;
    idUsuarioDestino = widget.idUsuarioDestino;
    imagemPerfilDestino = widget.imagemPerfilDestino;
    nomeDestino = widget.nomeDestino;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 236, 236, 236),
      body: StreamBuilder(
        stream: notificacoes
            .collection('chat')
            .doc(idUsuarioLogado)
            .collection(idUsuarioDestino)
            .orderBy('hora', descending: false)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var messages = snapshot.data!.docs;

          if (messages.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(18.0),
              child: Center(
                child: Text(
                  'Inicie uma conversa com $nomeDestino...',
                  style: const TextStyle(
                      fontSize: 26,
                      color: Colors.black26,
                      fontWeight: FontWeight.w300),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return Stack(
            children: [
              ListView.builder(
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  var mensagem = messages[index].get('mensagem');
                  var remetente = messages[index].get('idRemetente');
                  var idMensagem = messages[index].get('idMensagem');

                  if (mensagem.length <= 2) {
                    larguraContainer = mensagem.length * 15.0;
                  } else if (mensagem.length <= 4) {
                    larguraContainer = mensagem.length * 13.0;
                  } else if (mensagem.length <= 5) {
                    larguraContainer = mensagem.length * 14.0;
                  } else if (mensagem.length <= 10) {
                    larguraContainer = mensagem.length * 11.0;
                  } else if (mensagem.length <= 12) {
                    larguraContainer = mensagem.length * 11.0;
                  } else if (mensagem.length <= 15) {
                    larguraContainer = mensagem.length * 9.0;
                  } else if (mensagem.length <= 16) {
                    larguraContainer = mensagem.length * 10.0;
                  } else if (mensagem.length <= 18) {
                    larguraContainer = mensagem.length * 9.0;
                  } else if (mensagem.length <= 20) {
                    larguraContainer = mensagem.length * 11.0;
                  } else if (mensagem.length <= 25) {
                    larguraContainer = mensagem.length * 9.0;
                  } else if (mensagem.length <= 30) {
                    larguraContainer = mensagem.length * 8.0;
                  } else if (mensagem.length <= 33) {
                    larguraContainer = mensagem.length * 8.0;
                  } else if (mensagem.length <= 35) {
                    larguraContainer = mensagem.length * 11.0;
                  } else {
                    larguraContainer = mensagem.length * 8.0;
                  }

                  larguraContainer = larguraContainer.clamp(0.0, 300.0);

                  return Padding(
                    padding: remetente == idUsuarioLogado
                        ? EdgeInsets.only(right: 12.0, top: 5)
                        : EdgeInsets.only(left: 12.0, top: 10),
                    child: Row(
                      mainAxisAlignment: remetente == idUsuarioLogado
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
                      children: [
                        if (remetente != idUsuarioLogado)
                          Container(
                            width: 35,
                            height: 35,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                            ),
                            child: ClipOval(
                              child: CachedNetworkImage(
                                fit: BoxFit.cover,
                                imageUrl: imagemPerfilDestino,
                                placeholder: (context, url) =>
                                    const CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error),
                              ),
                            ),
                          ),
                        const SizedBox(width: 10),
                        Opacity(
                          opacity: 0.6,
                          child: GestureDetector(
                            onLongPress: () {
                              selecionarMensagem(context, idMensagem, mensagem);
                            },
                            child: Container(
                              width: larguraContainer,
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                  color: remetente == idUsuarioLogado
                                      ? mensagem == 'Mensagem apagada'
                                          ? Colors.white54
                                          : const Color.fromARGB(
                                              255, 146, 18, 57)
                                      : mensagem == 'Mensagem apagada'
                                          ? Colors.white54
                                          : Colors.white,
                                  borderRadius: BorderRadius.only(
                                      topLeft: remetente == idUsuarioLogado
                                          ? const Radius.circular(32)
                                          : const Radius.circular(32),
                                      bottomLeft: remetente == idUsuarioLogado
                                          ? const Radius.circular(32)
                                          : const Radius.circular(8),
                                      bottomRight: const Radius.circular(32),
                                      topRight: remetente == idUsuarioLogado
                                          ? const Radius.circular(8)
                                          : const Radius.circular(32))),
                              child: Align(
                                alignment: Alignment.center,
                                // remetente == idUsuarioLogado
                                //     ? Alignment.centerRight
                                //     : Alignment.centerLeft,
                                child: Wrap(
                                  children: [
                                    ReadMoreText(
                                      mensagem,
                                      trimLines: 16,
                                      colorClickableText: Colors.blue,
                                      trimMode: TrimMode.Line,
                                      trimCollapsedText: 'ver mais',
                                      trimExpandedText: ' ver menos',
                                      moreStyle: TextStyle(
                                        color: remetente == idUsuarioDestino
                                            ? Colors.black
                                            : Colors.white54,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                      lessStyle: TextStyle(
                                        color: remetente == idUsuarioDestino
                                            ? Colors.black
                                            : Colors.white54,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                      style: TextStyle(
                                          color: remetente == idUsuarioDestino
                                              ? mensagem == 'Mensagem apagada'
                                                  ? Colors.black54
                                                  : Colors.black
                                              : mensagem == 'Mensagem apagada'
                                                  ? Colors.black54
                                                  : Colors.white,
                                          fontWeight: FontWeight.w400,
                                          fontSize: 16,
                                          fontStyle:
                                              mensagem == 'Mensagem apagada'
                                                  ? FontStyle.italic
                                                  : FontStyle.normal),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
