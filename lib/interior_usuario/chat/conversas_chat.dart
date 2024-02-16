import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:editora_izyncor_app/interior_usuario/chat/chat_mensagem/mensagens.dart';
import 'package:editora_izyncor_app/widgets/drawer/drawer_widget.dart';
import 'package:editora_izyncor_app/widgets/topo_appbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class conversas_chat extends StatefulWidget {
  const conversas_chat({Key? key}) : super(key: key);

  @override
  State<conversas_chat> createState() => _conversas_chatState();
}

class _conversas_chatState extends State<conversas_chat> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  FirebaseStorage storage = FirebaseStorage.instance;
  FirebaseAuth auth = FirebaseAuth.instance;
  String? _idUsuarioLogado;
  String? idUsuarioLogado;
  String urlImagem = '';
  String nomeDestino = '';
  String sobrenomeDestino = '';
  String urlImagemDestino = '';

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final _controller = StreamController<QuerySnapshot>.broadcast();
  String pesquisa = ""; // Variável para armazenar o texto de pesquisa

  // RECUPERAR DADOS UM USUARIO
  _carregaarDadosIniciais() async {
    var usuario = _firebaseAuth.currentUser;
    _idUsuarioLogado = usuario!.uid;
    _adicionarListenerConversa();
  }

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
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    recuperarDadosUsuario();
    setState(() {
      _carregaarDadosIniciais();
    });
  }

  Stream<QuerySnapshot>? _adicionarListenerConversa() {
    final stream = _firebaseFirestore
        .collection("conversas")
        .doc(_idUsuarioLogado)
        .collection("ultima_conversa")
        .orderBy("hora", descending: true) // Ordenar por hora decrescente
        .snapshots();

    stream.listen((dados) {
      _controller.add(dados);
    });
    return null;
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
            ),
          ],
        ),
      ),
      drawer: const drawer_widget(),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/back2.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          StreamBuilder<QuerySnapshot>(
            stream: _controller.stream,
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.waiting:
                  return SizedBox(
                    height: MediaQuery.of(context).size.height,
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        CircularProgressIndicator(),
                        Padding(
                          padding: EdgeInsets.only(top: 50),
                          child: Center(
                            child: Text(
                              "carregando conversas....",
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.black26,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                case ConnectionState.active:
                case ConnectionState.done:
                  if (snapshot.hasError) {
                    return const Text("Erro ao carregar dados");
                  } else {
                    QuerySnapshot querySnapshot = snapshot.data!;
                    if (querySnapshot.docs.isEmpty) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.chat_outlined,
                                color: Colors.black12, size: 90),
                            Text(
                              'Você ainda não tem mensagens.',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.black26,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    // Filtrar as conversas com base no nome pesquisado
                    List<DocumentSnapshot> conversas =
                        querySnapshot.docs.where((conversa) {
                      String nomeCompleto = conversa["autorMensagem"];
                      return nomeCompleto
                          .toLowerCase()
                          .contains(pesquisa.toLowerCase());
                    }).toList();

                    if (conversas.isEmpty) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.chat_outlined,
                                color: Colors.black12, size: 90),
                            Text(
                              'Nenhuma conversa encontrada.',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.black26,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: conversas.length,
                      itemBuilder: (context, indice) {
                        DocumentSnapshot item = conversas[indice];
                        String tipo = item["tipo"];
                        String mensagem = item["mensagem"];
                        String idUsuarioConversa = item['idDestinatario'];
                        String autorMensagem = item['autorMensagem'];
                        String nomeLogado = item["nomeConversa"];
                        String sobrenomeLogado = item["sobrenomeConversa"];
                        String imagemUrlLogado = item["imagemUrlDestino"];
                        String nomeDestino = item["nomeConversa"];
                        String sobrenomeDestino = item["sobrenomeConversa"];
                        String imagemUrlDestino =
                            item["imagemUrlDestino"];

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MensagemPage(
                                  idUsuarioDestino:
                                      autorMensagem == idUsuarioLogado
                                          ? idUsuarioConversa
                                          : autorMensagem,
                                ),
                              ),
                            );
                          },
                          onLongPress: () {
                            void _opcoesMensagem(BuildContext context) {
                              showModalBottomSheet(
                                context: context,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(20.0),
                                  ),
                                ),
                                builder: (BuildContext context) {
                                  return Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Center(
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(top: 10),
                                          child: Container(
                                            width: 40,
                                            height: 4,
                                            decoration: BoxDecoration(
                                              color: Colors.black38,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                        ),
                                      ),
                                      ListTile(
                                        leading: const Icon(
                                          Icons.delete_outline,
                                          color: Colors.black,
                                        ),
                                        title: const Text('Apagar conversa'),
                                        onTap: () {
                                          void apagarConversa() async {
                                            await _firebaseFirestore
                                                .collection("conversas")
                                                .doc(_idUsuarioLogado)
                                                .collection('ultima_conversa')
                                                .doc(idUsuarioConversa)
                                                .delete();
                                            setState(() {});
                                          }

                                          void apagarMensagens() async {
                                            final ultimaConversaCollection =
                                                _firebaseFirestore
                                                    .collection("mensagens")
                                                    .doc(_idUsuarioLogado)
                                                    .collection(
                                                        idUsuarioConversa);

                                            final documentos =
                                                await ultimaConversaCollection
                                                    .get();

                                            for (final documento
                                                in documentos.docs) {
                                              await documento.reference
                                                  .delete();
                                            }

                                            setState(() {});
                                          }

                                          apagarConversa();
                                          apagarMensagens();
                                          Navigator.pop(context);
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            }

                            _opcoesMensagem(context);
                          },
                          child: Column(
                            children: [
                              ListTile(
                                contentPadding:
                                    const EdgeInsets.fromLTRB(16, 8, 16, 8),
                                leading: Container(
                                  width: 48,
                                  height: 48,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                  ),
                                  child: ClipOval(
                                    child: CachedNetworkImage(
                                      imageUrl: autorMensagem == idUsuarioLogado
                                          ? imagemUrlLogado
                                          : imagemUrlDestino,
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
                                title: Text(
                                  autorMensagem == idUsuarioLogado 
                                  ? '$nomeLogado $sobrenomeLogado'
                                  : '$nomeDestino $sobrenomeDestino',
                                  style: const TextStyle(
                                    color: Color.fromARGB(255, 0, 0, 0),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                subtitle: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          autorMensagem == _idUsuarioLogado
                                              ? 'Você: '
                                              : '',
                                          style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 14),
                                        ),
                                        tipo == 'texto'
                                            ? Text(mensagem,
                                                style: TextStyle(
                                                    color: Colors.grey[600],
                                                    fontSize: 14))
                                            : tipo == 'imagem'
                                                ? const Icon(Icons.image,
                                                    color: Colors.black26)
                                                : tipo == 'anexo'
                                                    ? const Icon(
                                                        Icons
                                                            .attach_file_outlined,
                                                        color: Colors.black38)
                                                    : const Text('...')
                                      ],
                                    ),
                                    Text(
                                      item["hora"] != null
                                          ? DateFormat('HH:mm').format(
                                              DateTime.parse(item["hora"]))
                                          : '',
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 3),
                              Container(
                                width: double.infinity,
                                height: 1,
                                color: Colors.black12,
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }
              }
            },
          ),
        ],
      ),
    );
  }
}
