import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:editora_izyncor_app/interior_usuario/chat/chat_mensagem/widget_chat/imagens_chat.dart';
import 'package:editora_izyncor_app/interior_usuario/chat/chat_mensagem/widget_chat/itens/icone_documentos.dart';
import 'package:editora_izyncor_app/interior_usuario/chat/chat_mensagem/widget_chat/itens/mensagem_apagada.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:readmore/readmore.dart';
import 'package:url_launcher/url_launcher.dart';

class mensagens_widget extends StatefulWidget {
  final String idUsuarioLogado;
  final String idUsuarioDestino;
  final String nomeDestino;
  const mensagens_widget(
      {super.key,
      required this.idUsuarioLogado,
      required this.idUsuarioDestino,
      required this.nomeDestino});

  @override
  State<mensagens_widget> createState() => _mensagens_widgetState();
}

class _mensagens_widgetState extends State<mensagens_widget> {
  FirebaseFirestore notificacoes = FirebaseFirestore.instance;
  ScrollController _scrollController = ScrollController();
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  bool scrollMaximo = true;
  bool hasScrolledToMax = false;
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

  void selecionarMensagem(
      BuildContext context, String idMensagem, String mensagem) {
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
                leading: SizedBox(
                    width: 25, child: Image.asset('assets/lixeira.png')),
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

  void _scrollListener() {
    // Check if the scroll position is at maxScrollExtent
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      // If at maxScrollExtent, set scrollMaximo to true after a short delay
      Future.delayed(Duration(milliseconds: 200), () {
        setState(() {
          scrollMaximo = true;
          print(scrollMaximo);
        });
      });
    } else if (scrollMaximo) {
      // If not at maxScrollExtent and scrollMaximo is true, set it to false
      Future.delayed(Duration(milliseconds: 1000), () {
        setState(() {
          scrollMaximo = false;
          print(scrollMaximo);
        });
      });
      ;
    }
  }

  void downloadArquivo(String urlDownload) async {
    // Você pode usar a biblioteca url_launcher para abrir o link no navegador
    if (await canLaunch(urlDownload)) {
      await launch(urlDownload);
    } else {
      // Lidar com o erro, se necessário
      print('Erro ao abrir o link de download');
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
        imagemPerfilDestino = userData['urlImagem'];
      });
    }
  }

  @override
  void initState() {
    super.initState();
    idUsuarioLogado = widget.idUsuarioLogado;
    idUsuarioDestino = widget.idUsuarioDestino;
    nomeDestino = widget.nomeDestino;
    _scrollController.addListener(_scrollListener);
    recuperarDadosDestino();

    FirebaseFirestore.instance
        .collection('chat')
        .doc(idUsuarioDestino)
        .collection(idUsuarioLogado)
        .where('lida', isEqualTo: 'novo')
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        doc.reference.update({'lida': 'visto'});
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
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

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!hasScrolledToMax) {
              _scrollController
                  .jumpTo(_scrollController.position.maxScrollExtent);
              hasScrolledToMax = true;
            }
          });

          return Stack(
            children: [
              ListView.builder(
                controller: _scrollController,
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  var mensagem = messages[index].get('mensagem');
                  var remetente = messages[index].get('idRemetente');
                  var idMensagem = messages[index].get('idMensagem');
                  var hora = messages[index].get('hora');
                  var leitura = messages[index].get('lida');
                  var tipo = messages[index].get('tipo');
                  var tamanho = messages[index].get('tamanho');
                  var urlAnexo = messages[index].get('urlImagem');

                  if (mensagem.length <= 1) {
                    larguraContainer = mensagem.length * 30.0;
                  } else if (mensagem.length <= 2) {
                    larguraContainer = mensagem.length * 25.0;
                  } else if (mensagem.length <= 3) {
                    larguraContainer = mensagem.length * 20.0;
                  } else if (mensagem.length <= 4) {
                    larguraContainer = mensagem.length * 20.0;
                  } else if (mensagem.length <= 5) {
                    larguraContainer = mensagem.length * 14.0;
                  } else if (mensagem.length <= 10) {
                    larguraContainer = mensagem.length * 12.0;
                  } else if (mensagem.length <= 12) {
                    larguraContainer = mensagem.length * 13.0;
                  } else if (mensagem.length <= 15) {
                    larguraContainer = mensagem.length * 9.0;
                  } else if (mensagem.length <= 16) {
                    larguraContainer = mensagem.length * 11.0;
                  } else if (mensagem.length <= 17) {
                    larguraContainer = mensagem.length * 10.0;
                  } else if (mensagem.length <= 18) {
                    larguraContainer = mensagem.length * 10.0;
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
                        ? const EdgeInsets.only(right: 12.0, top: 5)
                        : const EdgeInsets.only(left: 12.0, top: 10),
                    child: Column(
                      crossAxisAlignment: remetente == idUsuarioLogado
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: remetente == idUsuarioLogado
                              ? MainAxisAlignment.end
                              : MainAxisAlignment.start,
                          children: [
                            if (remetente != idUsuarioLogado && tipo == 'texto')
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
                            if (remetente != idUsuarioLogado && tipo == 'texto')
                              const SizedBox(width: 10),
                            if (tipo != 'documento')
                              Opacity(
                                opacity: tipo == 'imagem' &&
                                        mensagem != 'Mensagem apagada'
                                    ? 1.0
                                    : 0.6,
                                child: GestureDetector(
                                    onLongPress: () {
                                      selecionarMensagem(
                                          context, idMensagem, mensagem);
                                    },
                                    child: tipo == 'texto'
                                        ? Container(
                                            width: larguraContainer,
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                                color: remetente ==
                                                        idUsuarioLogado
                                                    ? mensagem ==
                                                            'Mensagem apagada'
                                                        ? Colors.white54
                                                        : const Color.fromARGB(
                                                            255, 146, 18, 57)
                                                    : mensagem ==
                                                            'Mensagem apagada'
                                                        ? Colors.white54
                                                        : Colors.white,
                                                borderRadius: BorderRadius.only(
                                                    topLeft: remetente == idUsuarioLogado
                                                        ? const Radius.circular(
                                                            32)
                                                        : const Radius.circular(
                                                            32),
                                                    bottomLeft: remetente ==
                                                            idUsuarioLogado
                                                        ? const Radius.circular(
                                                            32)
                                                        : const Radius.circular(
                                                            8),
                                                    bottomRight:
                                                        const Radius.circular(
                                                            32),
                                                    topRight: remetente == idUsuarioLogado
                                                        ? const Radius.circular(8)
                                                        : const Radius.circular(32))),
                                            child: Align(
                                              alignment: Alignment.center,
                                              child: Wrap(
                                                children: [
                                                  ReadMoreText(
                                                    mensagem,
                                                    trimLines: 16,
                                                    colorClickableText:
                                                        Colors.blue,
                                                    trimMode: TrimMode.Line,
                                                    trimCollapsedText:
                                                        'ver mais',
                                                    trimExpandedText:
                                                        ' ver menos',
                                                    moreStyle: TextStyle(
                                                      color: remetente ==
                                                              idUsuarioDestino
                                                          ? Colors.black
                                                          : Colors.white54,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 14,
                                                    ),
                                                    lessStyle: TextStyle(
                                                      color: remetente ==
                                                              idUsuarioDestino
                                                          ? Colors.black
                                                          : Colors.white54,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 14,
                                                    ),
                                                    style: TextStyle(
                                                        color: remetente ==
                                                                idUsuarioDestino
                                                            ? mensagem ==
                                                                    'Mensagem apagada'
                                                                ? Colors.black54
                                                                : Colors.black
                                                            : mensagem ==
                                                                    'Mensagem apagada'
                                                                ? Colors.black54
                                                                : Colors.white,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontSize: 16,
                                                        fontStyle: mensagem ==
                                                                'Mensagem apagada'
                                                            ? FontStyle.italic
                                                            : FontStyle.normal),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
                                        : mensagem != 'Mensagem apagada'
                                            ? imagens_chat(
                                                remetente: remetente,
                                                idUsuarioLogado:
                                                    idUsuarioLogado,
                                                idUsuarioDestino:
                                                    idUsuarioDestino,
                                                mensagem: mensagem)
                                            : Container(
                                                width: larguraContainer,
                                                padding:
                                                    const EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                    color: remetente ==
                                                            idUsuarioLogado
                                                        ? mensagem ==
                                                                'Mensagem apagada'
                                                            ? Colors.white54
                                                            : const Color.fromARGB(
                                                                255, 146, 18, 57)
                                                        : mensagem ==
                                                                'Mensagem apagada'
                                                            ? Colors.white54
                                                            : Colors.white,
                                                    borderRadius: BorderRadius.only(
                                                        topLeft: remetente == idUsuarioLogado
                                                            ? const Radius.circular(
                                                                32)
                                                            : const Radius.circular(
                                                                32),
                                                        bottomLeft: remetente ==
                                                                idUsuarioLogado
                                                            ? const Radius.circular(
                                                                32)
                                                            : const Radius.circular(
                                                                8),
                                                        bottomRight: const Radius.circular(
                                                            32),
                                                        topRight: remetente ==
                                                                idUsuarioLogado
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
                                                        colorClickableText:
                                                            Colors.blue,
                                                        trimMode: TrimMode.Line,
                                                        trimCollapsedText:
                                                            'ver mais',
                                                        trimExpandedText:
                                                            ' ver menos',
                                                        moreStyle: TextStyle(
                                                          color: remetente ==
                                                                  idUsuarioDestino
                                                              ? Colors.black
                                                              : Colors.white54,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 14,
                                                        ),
                                                        lessStyle: TextStyle(
                                                          color: remetente ==
                                                                  idUsuarioDestino
                                                              ? Colors.black
                                                              : Colors.white54,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 14,
                                                        ),
                                                        style: TextStyle(
                                                            color: remetente ==
                                                                    idUsuarioDestino
                                                                ? mensagem ==
                                                                        'Mensagem apagada'
                                                                    ? Colors
                                                                        .black54
                                                                    : Colors
                                                                        .black
                                                                : mensagem ==
                                                                        'Mensagem apagada'
                                                                    ? Colors
                                                                        .black54
                                                                    : Colors
                                                                        .white,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            fontSize: 16,
                                                            fontStyle: mensagem ==
                                                                    'Mensagem apagada'
                                                                ? FontStyle
                                                                    .italic
                                                                : FontStyle
                                                                    .normal),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              )),
                              ),
                            if (tipo == 'documento' &&
                                mensagem != 'Mensagem apagada')
                              GestureDetector(
                                onLongPress: () {
                                  selecionarMensagem(
                                      context, idMensagem, mensagem);
                                },
                                child: Stack(
                                  children: [
                                    Opacity(
                                      opacity: 0.6,
                                      child: Container(
                                        width: 290,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          color: remetente == idUsuarioLogado
                                              ? mensagem == 'Mensagem apagada'
                                                  ? Colors.white54
                                                  : const Color.fromARGB(
                                                      255, 146, 18, 57)
                                              : mensagem == 'Mensagem apagada'
                                                  ? Colors.white54
                                                  : Colors.white,
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(16),
                                            bottomLeft: Radius.circular(16),
                                            bottomRight: Radius.circular(16),
                                            topRight: Radius.circular(16),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 5, left: 5),
                                      child: Opacity(
                                        opacity: 1,
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 40,
                                              height: 50,
                                              decoration: BoxDecoration(
                                                color: remetente ==
                                                        idUsuarioLogado
                                                    ? mensagem ==
                                                            'Mensagem apagada'
                                                        ? Colors.white54
                                                        : const Color.fromARGB(
                                                            255, 204, 133, 154)
                                                    : mensagem ==
                                                            'Mensagem apagada'
                                                        ? Colors.white54
                                                        : Colors.white,
                                                borderRadius:
                                                    const BorderRadius.only(
                                                  topLeft: Radius.circular(12),
                                                  bottomLeft:
                                                      Radius.circular(12),
                                                  bottomRight:
                                                      Radius.circular(0),
                                                  topRight: Radius.circular(0),
                                                ),
                                              ),
                                              child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(6.0),
                                                  child: icone_documentos(
                                                    mensagem: mensagem,
                                                  )),
                                            ),
                                            Container(
                                              width: 190,
                                              height: 50,
                                              decoration: BoxDecoration(
                                                  color: remetente ==
                                                          idUsuarioLogado
                                                      ? mensagem ==
                                                              'Mensagem apagada'
                                                          ? Colors.white54
                                                          : const Color
                                                              .fromARGB(255,
                                                              204, 133, 154)
                                                      : mensagem ==
                                                              'Mensagem apagada'
                                                          ? Colors.white54
                                                          : Colors.white,
                                                  borderRadius:
                                                      const BorderRadius.only(
                                                    topLeft: Radius.circular(0),
                                                    bottomLeft:
                                                        Radius.circular(0),
                                                    bottomRight:
                                                        Radius.circular(0),
                                                    topRight:
                                                        Radius.circular(0),
                                                  )),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    '${mensagem.length >= 24 ? mensagem.substring(0, 23) + "..." : mensagem}',
                                                    style: TextStyle(
                                                      color: remetente ==
                                                              idUsuarioDestino
                                                          ? mensagem ==
                                                                  'Mensagem apagada'
                                                              ? Colors.black54
                                                              : Colors.black
                                                          : mensagem ==
                                                                  'Mensagem apagada'
                                                              ? Colors.black54
                                                              : Colors.white,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontSize: 14,
                                                      fontStyle: mensagem ==
                                                              'Mensagem apagada'
                                                          ? FontStyle.italic
                                                          : FontStyle.italic,
                                                    ),
                                                  ),
                                                  Text(
                                                    tamanho,
                                                    style: TextStyle(
                                                        color: remetente ==
                                                                idUsuarioLogado
                                                            ? Colors.white
                                                            : Colors.black54,
                                                        fontSize: 12),
                                                  )
                                                ],
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                downloadArquivo(urlAnexo);
                                              },
                                              child: Container(
                                                width: 50,
                                                height: 50,
                                                decoration: BoxDecoration(
                                                  color: remetente ==
                                                          idUsuarioLogado
                                                      ? mensagem ==
                                                              'Mensagem apagada'
                                                          ? Colors.white54
                                                          : const Color
                                                              .fromARGB(255,
                                                              204, 133, 154)
                                                      : mensagem ==
                                                              'Mensagem apagada'
                                                          ? Colors.white54
                                                          : Colors.white,
                                                  borderRadius:
                                                      const BorderRadius.only(
                                                    topLeft: Radius.circular(0),
                                                    bottomLeft:
                                                        Radius.circular(0),
                                                    bottomRight:
                                                        Radius.circular(12),
                                                    topRight:
                                                        Radius.circular(12),
                                                  ),
                                                ),
                                                child: Icon(
                                                  Icons.cloud_download,
                                                  color: remetente ==
                                                          idUsuarioLogado
                                                      ? Colors.white
                                                      : Colors.black54,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            if (tipo == 'documento' &&
                                mensagem == 'Mensagem apagada')
                              GestureDetector(
                                onLongPress: () {
                                  selecionarMensagem(
                                      context, idMensagem, mensagem);
                                },
                                child: mensagem_apagada(
                                    idUsuarioLogado: idUsuarioLogado,
                                    remetente: remetente),
                              )
                          ],
                        ),
                        if (mensagem != 'Mensagem apagada')
                          Row(
                            mainAxisAlignment: remetente == idUsuarioLogado
                                ? MainAxisAlignment.end
                                : MainAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 5),
                                child: Text(
                                    DateFormat('HH:mm')
                                        .format(DateTime.parse(hora)),
                                    style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black54)),
                              ),
                              if (remetente == idUsuarioLogado)
                                const SizedBox(width: 5),
                              if (remetente == idUsuarioLogado)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Opacity(
                                      opacity: 0.6,
                                      child: Icon(
                                          leitura == 'visto'
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                          color: leitura == 'visto'
                                              ? const Color.fromARGB(
                                                  255, 204, 133, 154)
                                              : Colors.black38)),
                                ),
                            ],
                          ),
                        SizedBox(
                            height: mensagem != 'Mensagem apagada' ? 5 : 5),
                      ],
                    ),
                  );
                },
              ),
              if (scrollMaximo == false)
                Positioned(
                  bottom: 10,
                  right: 20,
                  child: GestureDetector(
                    onTap: () {
                      _scrollController.animateTo(
                        _scrollController.position.maxScrollExtent,
                        duration: const Duration(
                            milliseconds: 1000), // Define a duração da animação
                        curve: Curves
                            .easeInOutCirc, // Define a curva de animação (pode ser ajustada conforme desejado)
                      );
                    },
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: const BoxDecoration(
                          color: Colors.white, shape: BoxShape.circle),
                      child: const Center(
                          child: Icon(Icons.keyboard_arrow_down_rounded,
                              color: Color.fromARGB(255, 146, 18, 57))),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
