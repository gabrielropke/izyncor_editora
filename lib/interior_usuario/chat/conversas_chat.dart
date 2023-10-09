import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:editora_izyncor_app/interior_usuario/chat/mensagens_chat.dart';
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

  String? _idUsuarioLogado;

  final _controller = StreamController<QuerySnapshot>.broadcast();

  // RECUPERAR DADOS UM USUARIO
  _carregaarDadosIniciais() async {
    var usuario = await _firebaseAuth.currentUser;
    _idUsuarioLogado = usuario!.uid;
    _adicionarListenerConversa();
  }

  @override
  void initState() {
    super.initState();
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
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("assets/back2.jpg"), fit: BoxFit.cover),
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
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
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
                          Icon(Icons.chat_outlined, color: Colors.black12, size: 90),
                          Text(
                            'Você ainda não tem mensagens.',
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.black26,
                                fontSize: 18),
                          )
                        ],
                      ));
                    }
                    return ListView.builder(
                        itemCount: querySnapshot.docs.length,
                        itemBuilder: (context, indice) {
                          List<DocumentSnapshot> conversas =
                              querySnapshot.docs.toList();
                          DocumentSnapshot item = conversas[indice];

                          String urlImagem = item["caminhoFoto"];
                          String tipo = item["tipoMensagem"];
                          String mensagem = item["mensagem"];
                          String nome = item["nome"];
                          String sobrenome = item['sobrenome'];
                          String idUsuarioConversa = item['idDestinatario'];
                          String autorMensagem = item['autorMensagem'];

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Mensagens(
                                        uidPerfil: idUsuarioConversa,
                                        nome: nome,
                                        imagemPerfil: urlImagem,
                                        sobrenome: sobrenome)),
                              );
                            },
                            onLongPress: () {
                              // ignore: no_leading_underscores_for_local_identifiers
                              void _opcoesMensagem(BuildContext context) {
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
                                        children: [
                                          Center(
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 10),
                                              child: Container(
                                                width: 40,
                                                height: 4,
                                                decoration: BoxDecoration(
                                                    color: Colors.black38,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12)),
                                              ),
                                            ),
                                          ),
                                          ListTile(
                                            leading: const Icon(
                                              Icons.delete_outline,
                                              color: Colors.black,
                                            ),
                                            title:
                                                const Text('Apagar conversa'),
                                            onTap: () {
                                              void apagarConversa() async {
                                                await _firebaseFirestore
                                                    .collection("conversas")
                                                    .doc(_idUsuarioLogado)
                                                    .collection(
                                                        'ultima_conversa')
                                                    .doc(
                                                        idUsuarioConversa) // Substitua 'idDoDocumentoParaExcluir' pelo ID correto
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

                                                // Obtém todos os documentos da coleção 'ultima_conversa'
                                                final documentos =
                                                    await ultimaConversaCollection
                                                        .get();

                                                // Exclui todos os documentos em um lote
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
                                    });
                              }

                              _opcoesMensagem(context);
                            },
                            child: Column(
                              children: [
                                ListTile(
                                  contentPadding:
                                      const EdgeInsets.fromLTRB(16, 8, 16, 8),
                                  leading: CircleAvatar(
                                    maxRadius: 30,
                                    backgroundColor: Colors.grey,
                                    // ignore: unnecessary_null_comparison
                                    backgroundImage: urlImagem != null
                                        ? NetworkImage(urlImagem)
                                        : null,
                                  ),
                                  title: Text(
                                    '$nome $sobrenome',
                                    style: const TextStyle(
                                        color: Color.fromARGB(255, 0, 0, 0),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
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
                                                  fontSize: 14)),
                                          Text(
                                              tipo == "texto"
                                                  ? mensagem
                                                  : "Imagem...",
                                              style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 16)),
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
                              ],
                            ),
                          );
                        });
                  }
              }
            },
          ),
        ],
      ),
    );
  }
}
