import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:editora_izyncor_app/interior_usuario/perfil_visita/perfil_visita.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import 'dart:io';

import '../../model/conversa.dart';
import '../../model/mensagem.dart';

class Mensagens extends StatefulWidget {
  final String uidPerfil;
  final String nome;
  final String imagemPerfil;
  final String sobrenome;
  const Mensagens(
      {super.key,
      required this.uidPerfil,
      required this.nome,
      required this.imagemPerfil,
      required this.sobrenome});

  @override
  State<Mensagens> createState() => _MensagensState();
}

class _MensagensState extends State<Mensagens> {
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  FirebaseStorage storage = FirebaseStorage.instance;

  TextEditingController _controllerMensagem = TextEditingController();
  final _controller = StreamController<QuerySnapshot>.broadcast();
  ScrollController _scrollController = ScrollController();

  String? _idUsuarioLogado;
  String? _idUsuarioDestinatario;

  late String uidPerfil;
  late String nome;
  late String imagemPerfil;
  late String sobrenome;
  late String biografia;
  String? username;
  String? nomeLogado;
  String? sobrenomeLogado;
  String? imagemUrlLogado;
  String? cadastro;
  String? cadastroPerfil;

  bool _lida = false;
  bool _enviandoAudio = false;

  void opcoesMensagem(BuildContext context) {
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
                leading: SizedBox(
                    width: 25, child: Image.asset('assets/lixeira.png')),
                title: const Text('Apagar conversa'),
                onTap: () {
                  void apagarConversa() async {
                    await _firebaseFirestore
                        .collection("conversas")
                        .doc(_idUsuarioLogado)
                        .collection('ultima_conversa')
                        .doc(
                            uidPerfil) // Substitua 'idDoDocumentoParaExcluir' pelo ID correto
                        .delete();
                    setState(() {});
                  }

                  void apagarMensagens() async {
                    final ultimaConversaCollection = _firebaseFirestore
                        .collection("mensagens")
                        .doc(_idUsuarioLogado)
                        .collection(uidPerfil);

                    // Obtém todos os documentos da coleção 'ultima_conversa'
                    final documentos = await ultimaConversaCollection.get();

                    // Exclui todos os documentos em um lote
                    for (final documento in documentos.docs) {
                      await documento.reference.delete();
                    }

                    setState(() {});
                  }

                  apagarConversa();
                  apagarMensagens();
                  Navigator.pop(context);
                },
              ),
              if (Platform.isIOS)
                const SizedBox(
                  width: double.infinity,
                  height: 40,
                )
            ],
          );
        });
  }

  void _toggleContainerVisibility() {
    setState(() {
      _enviandoAudio = !_enviandoAudio;
    });
  }

  _enviarMensagem() {
    String textoMensagem = _controllerMensagem.text;
    if (textoMensagem.isNotEmpty) {
      Mensagem mensagem = Mensagem();
      mensagem.idUsuario = _idUsuarioLogado!;
      mensagem.mensagem = textoMensagem;
      mensagem.urlImagem = "";
      mensagem.data = Timestamp.now().toString();
      mensagem.tipo = "texto";
      mensagem.hora = DateTime.now().toString();
      mensagem.lida = _lida;

      //sala mensagem duas vezes ... uma para quem envia e outra para quem recebeu
      _salvarMensagem(_idUsuarioLogado!, _idUsuarioDestinatario!, mensagem);
      _salvarMensagem(_idUsuarioDestinatario!, _idUsuarioLogado!, mensagem);
      _salvarMensagemBackup(
          _idUsuarioLogado!, _idUsuarioDestinatario!, mensagem);
      _salvarMensagemBackup(
          _idUsuarioDestinatario!, _idUsuarioLogado!, mensagem);
      //Salvar conversa
      _salvarConversa(mensagem);
      enviarNotificacao();
    }
  }

  _atualizarLida(bool lida) {
    setState(() {
      _lida = lida;
    });
  }

  _salvarConversa(Mensagem msg) {
    //remetente

    Conversa cRemente = Conversa();
    cRemente.idRemetente = _idUsuarioLogado!;
    cRemente.idDestinatario = _idUsuarioDestinatario!;
    cRemente.autorMensagem = _idUsuarioLogado!;
    cRemente.mensagem = msg.mensagem;
    cRemente.nome = nome;
    cRemente.sobrenome = sobrenome;
    cRemente.caminhoFoto = imagemPerfil;
    cRemente.tipoMensagem = msg.tipo;
    cRemente.hora = DateTime.now().toString();
    cRemente.salvar();

    //destinatario

    Conversa cDestinatario = Conversa();
    cDestinatario.idRemetente = _idUsuarioDestinatario!;
    cDestinatario.idDestinatario = _idUsuarioLogado!;
    cDestinatario.autorMensagem = _idUsuarioLogado!;
    cDestinatario.mensagem = msg.mensagem;
    cDestinatario.nome = nomeLogado!;
    cDestinatario.sobrenome = sobrenomeLogado!;
    cDestinatario.caminhoFoto = imagemUrlLogado!;
    cDestinatario.tipoMensagem = msg.tipo;
    cDestinatario.hora = DateTime.now().toString();
    cDestinatario.salvar();
  }

  _recuperarDadosUsuario() async {
    User usuarioLogado = auth.currentUser!;
    _idUsuarioLogado = usuarioLogado.uid;
    _idUsuarioDestinatario = widget.uidPerfil;

    _adicionarListenerConversa();

    FirebaseFirestore db = FirebaseFirestore.instance;
    DocumentSnapshot snapshot =
        await db.collection("usuarios").doc(_idUsuarioLogado).get();

    Map<String, dynamic> dados = snapshot.data() as Map<String, dynamic>;
    nomeLogado = dados["nome"];
    cadastro = dados["Cadastro"];
    sobrenomeLogado = dados["sobrenome"];
    imagemUrlLogado = dados["urlImagem"];
    username = dados['username'];
  }

  void enviarNotificacao() {
    CollectionReference usuariosCollection =
        FirebaseFirestore.instance.collection('usuarios');

    DocumentReference usuarioRef =
        usuariosCollection.doc(_idUsuarioDestinatario);

    usuarioRef.collection('notificacoes').add({
      'username': username,
      'idUsuario': _idUsuarioLogado,
      'mensagem': 'enviou uma mensagem para você.',
      'hora': DateTime.now().toString(),
      'postagem': 'vazio',
      'idPostagem': '',
      'perfil': imagemUrlLogado,
    });
    print('oi');
  }

  _salvarMensagem(
      String idRemetente, String idDestinatario, Mensagem msg) async {
    msg.lida = false;
    await _firebaseFirestore
        .collection("mensagens")
        .doc(idRemetente)
        .collection(idDestinatario)
        .add(msg.toMap());

    // limpa texto
    _controllerMensagem.clear();
  }

  _salvarMensagemBackup(
      String idRemetente, String idDestinatario, Mensagem msg) async {
    msg.lida = false;
    await _firebaseFirestore
        .collection("backup_mensagens")
        .doc(idRemetente)
        .collection(idDestinatario)
        .add(msg.toMap());
  }

  Future<void> _enviarFoto() async {
    final ImagePicker _picker = ImagePicker();
    XFile? imagemSelecionada;
    imagemSelecionada = await _picker.pickImage(source: ImageSource.gallery);

    if (imagemSelecionada != null) {
      File file = File(imagemSelecionada.path);

      // Realizar o corte da imagem
      File? imagemCortada = await cortarImagem(file);

      if (imagemCortada != null) {
        String nomeImagem = DateTime.now().millisecondsSinceEpoch.toString();

        Reference pastaRaiz = await storage.ref();
        Reference arquivo = pastaRaiz
            .child("mensagens")
            .child(_idUsuarioLogado!)
            .child(nomeImagem + ".jpg");

        UploadTask task = arquivo.putFile(imagemCortada);

        task.snapshotEvents.listen((TaskSnapshot storageEvent) {
          if (storageEvent.state == TaskState.running) {
            setState(() {});
          } else if (storageEvent.state == TaskState.success) {
            setState(() {});
          }
        });

        task.then(
            (TaskSnapshot taskSnapshot) => _recuperarURLimagem(taskSnapshot));
      }
    }
  }

  Future<void> _enviarFotoCamera() async {
    final ImagePicker _picker = ImagePicker();
    XFile? imagemSelecionada;
    imagemSelecionada = await _picker.pickImage(source: ImageSource.camera);

    if (imagemSelecionada != null) {
      // Realizar o corte da imagem
      File? imagemCortada = await cortarImagem(File(imagemSelecionada.path));

      if (imagemCortada != null) {
        String nomeImagem = DateTime.now().millisecondsSinceEpoch.toString();

        Reference pastaRaiz = await storage.ref();
        Reference arquivo = pastaRaiz
            .child("mensagens")
            .child(_idUsuarioLogado!)
            .child(nomeImagem + ".jpg");

        UploadTask task = arquivo.putFile(imagemCortada);

        task.snapshotEvents.listen((TaskSnapshot storageEvent) {
          if (storageEvent.state == TaskState.running) {
            setState(() {});
          } else if (storageEvent.state == TaskState.success) {
            setState(() {});
          }
        });

        task.then(
            (TaskSnapshot taskSnapshot) => _recuperarURLimagem(taskSnapshot));
      }
    }
  }

  Future _recuperarURLimagem(TaskSnapshot taskSnapshot) async {
    String url = await taskSnapshot.ref.getDownloadURL();

    Mensagem mensagem = Mensagem();
    mensagem.idUsuario = _idUsuarioLogado!;
    mensagem.mensagem = "";
    mensagem.urlImagem = url;
    mensagem.data = Timestamp.now().toString();
    mensagem.tipo = "imagem";
    mensagem.hora = DateTime.now().toString();

    _salvarMensagem(_idUsuarioLogado!, _idUsuarioDestinatario!, mensagem);
    _salvarMensagem(_idUsuarioDestinatario!, _idUsuarioLogado!, mensagem);
    _salvarMensagemBackup(_idUsuarioLogado!, _idUsuarioDestinatario!, mensagem);
    _salvarMensagemBackup(_idUsuarioDestinatario!, _idUsuarioLogado!, mensagem);
  }

  Future<void> _marcarMensagensComoLidas() async {
    final collection = _firebaseFirestore
        .collection("mensagens")
        .doc(_idUsuarioLogado)
        .collection(_idUsuarioDestinatario!);

    final batch = _firebaseFirestore.batch();

    final querySnapshot = await collection.get();
    for (final docSnapshot in querySnapshot.docs) {
      batch.update(docSnapshot.reference, {"lida": true});
    }

    await batch.commit();
    _atualizarLida(true);
  }

  Stream<QuerySnapshot>? _adicionarListenerConversa() {
    _marcarMensagensComoLidas();
    final stream = _firebaseFirestore
        .collection("mensagens")
        .doc(_idUsuarioLogado)
        .collection(_idUsuarioDestinatario!)
        .orderBy("data", descending: false)
        .snapshots();

    stream.listen((dados) {
      _controller.add(dados);
      Timer(Duration(seconds: 1), () {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      });
    });

    return null;
  }

  void _opcoes(BuildContext context) {
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
                leading: Opacity(
                  opacity:
                      0.5, // Defina o valor desejado de opacidade entre 0.0 e 1.0
                  child: SizedBox(
                    width: 25,
                    child: Image.asset('assets/galeria.png'),
                  ),
                ),
                title: const Text('Galeria'),
                onTap: () {
                  Navigator.pop(context);
                  _enviarFoto();
                },
              ),
              ListTile(
                leading: Opacity(
                  opacity:
                      0.5, // Defina o valor desejado de opacidade entre 0.0 e 1.0
                  child: SizedBox(
                    width: 26,
                    child: Image.asset('assets/camera2.png'),
                  ),
                ),
                title: const Text('Câmera'),
                onTap: () {
                  Navigator.pop(context);
                  _enviarFotoCamera();
                },
              ),
              if (Platform.isIOS)
                const SizedBox(
                  width: double.infinity,
                  height: 40,
                )
            ],
          );
        });
  }

  void _opcoesMensagem(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.delete_sweep),
                title: const Text('Apagar mensagem'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }

  void _exibirImagemFullScreen(String urlImagem) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return Scaffold(
        backgroundColor: Colors.black.withOpacity(0.5),
        body: Center(
          child: GestureDetector(
            onDoubleTap: () {
              Navigator.pop(context);
            },
            child: InteractiveViewer(
              child: Hero(
                tag: urlImagem,
                child: Image.network(
                  urlImagem,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
      );
    }));
  }

  _apagarMensagemUsuarioLogado(String idMensagem) async {
    await _firebaseFirestore
        .collection("mensagens")
        .doc(_idUsuarioLogado!)
        .collection(_idUsuarioDestinatario!)
        .doc(idMensagem)
        .delete();

    setState(() {});
  }

  cortarImagem(File file) async {
    return await ImageCropper()
        .cropImage(sourcePath: file.path, aspectRatioPresets: [
      CropAspectRatioPreset.original,
    ]);
  }

  @override
  void initState() {
    super.initState();

    _controllerMensagem.addListener(() {
      setState(() {}); // Isso irá reconstruir a interface quando o texto mudar.
    });

    _recuperarDadosUsuario();
    uidPerfil = widget.uidPerfil;
    nome = widget.nome;
    imagemPerfil = widget.imagemPerfil;
    sobrenome = widget.sobrenome;
  }

  @override
  Widget build(BuildContext context) {
    // criando a caixa de digitacao POR UM VAR
    var caixaMensagem = Row(
      children: <Widget>[
        Visibility(
          visible: _enviandoAudio == false,
          child: Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 10),
              child: TextField(
                textAlign: TextAlign.left,
                controller: _controllerMensagem,
                keyboardType: TextInputType.text,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color.fromARGB(255, 0, 0, 0),
                ),
                decoration: InputDecoration(
                  prefixIcon: IconButton(
                    color: const Color.fromARGB(255, 46, 43, 43),
                    onPressed: () {
                      _opcoes(context);
                    },
                    icon: Opacity(
                      opacity:
                          0.4, // Defina o valor desejado de opacidade entre 0.0 e 1.0
                      child: SizedBox(
                        width: 22,
                        child: Image.asset('assets/galeria.png'),
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
                    borderRadius: BorderRadius.all(Radius.circular(32)),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Color.fromARGB(255, 146, 18, 57)),
                    borderRadius: BorderRadius.all(Radius.circular(32)),
                  ),
                ),
              ),
            ),
          ),
        ),
        Visibility(
          visible: _enviandoAudio == false,
          child: Container(
              width: 55,
              height: 55,
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 69, 111, 224),
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.all(Radius.circular(32.0)),
                border: Border.all(color: Colors.white, width: 0),
              ),
              child: IconButton(
                color: const Color.fromARGB(255, 255, 255, 255),
                onPressed: _enviarMensagem,
                icon: const Icon(Icons.send, size: 24),
              )),
        ),
      ],
    );

    var stream = StreamBuilder(
      stream: _controller.stream,
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return const Center(
              child: Column(
                children: <Widget>[
                  Text("Carregando mensagens"),
                  CircularProgressIndicator()
                ],
              ),
            );
          case ConnectionState.active:
          case ConnectionState.done:
            QuerySnapshot querySnapshot =
                snapshot.data as QuerySnapshot<Object?>;

            if (snapshot.hasError) {
              return const Expanded(
                child: Text("Erro ao carregar os dados!"),
              );
            } else {
              return Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: querySnapshot.docs.length,
                  itemBuilder: (context, indice) {
                    // Recupera mensagem
                    List<DocumentSnapshot> mensagens =
                        querySnapshot.docs.toList();
                    DocumentSnapshot item = mensagens[indice];

                    double larguraContainer =
                        MediaQuery.of(context).size.width * 0.7;

                    // Define cores e alinhamentos
                    Alignment alinhamento = Alignment.centerRight;
                    Color cor = Colors.white;
                    Color corTexto = Color.fromARGB(255, 255, 255, 255);

                    if (_idUsuarioLogado == item["idUsuario"]) {
                      alinhamento = Alignment.centerRight;
                      corTexto = Color.fromARGB(
                          255, 0, 0, 0); // Cor do texto para o usuário logado
                    } else {
                      alinhamento = Alignment.centerLeft;
                      cor = Color.fromARGB(255, 91, 140, 212);
                    }

                    return Column(
                      children: [
                        Align(
                          alignment: alinhamento,
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: GestureDetector(
                              onLongPress: () {
                                if (item['idUsuario'] == _idUsuarioLogado) {
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
                                              leading: SizedBox(
                                                  width: 25,
                                                  child: Image.asset(
                                                      'assets/lixeira.png')),
                                              title: const Text(
                                                  'Apagar mensagem (para min)'),
                                              onTap: () {
                                                Navigator.pop(context);
                                                _apagarMensagemUsuarioLogado(
                                                    item.id);
                                              },
                                            ),
                                            if (Platform.isIOS)
                                              const SizedBox(
                                                width: double.infinity,
                                                height: 40,
                                              )
                                          ],
                                        );
                                      });
                                }
                              },
                              child: Container(
                                width: larguraContainer,
                                padding: item["tipo"] == "texto"
                                    ? const EdgeInsets.all(13)
                                    : const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  color: cor,
                                  borderRadius: BorderRadius.only(
                                    bottomRight: const Radius.circular(10),
                                    bottomLeft: const Radius.circular(10),
                                    topRight: Radius.circular(
                                        _idUsuarioLogado != item["idUsuario"]
                                            ? 10
                                            : 0),
                                    topLeft: Radius.circular(
                                        _idUsuarioLogado == item["idUsuario"]
                                            ? 10
                                            : 0),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Column(
                                      children: [
                                        item["tipo"] == "texto"
                                            ? Column(
                                                children: [
                                                  Stack(
                                                    children: [
                                                      Align(
                                                        alignment: Alignment
                                                            .bottomLeft,
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  left: 10),
                                                          child: Text(
                                                            item["mensagem"],
                                                            style: TextStyle(
                                                              fontSize: 16,
                                                              color: corTexto,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Positioned(
                                                        bottom: 0,
                                                        right: 0,
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  top: 3,
                                                                  right: 4),
                                                          child: Text(
                                                            item["hora"] != null
                                                                ? DateFormat(
                                                                        'HH:mm')
                                                                    .format(DateTime
                                                                        .parse(item[
                                                                            "hora"]))
                                                                : '',
                                                            style: item['idUsuario'] ==
                                                                    _idUsuarioLogado
                                                                ? const TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                    color: Colors
                                                                        .black,
                                                                  )
                                                                : const TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                ],
                                              )
                                            : Stack(
                                                children: [
                                                  GestureDetector(
                                                    onTap: () {
                                                      _exibirImagemFullScreen(
                                                          item["urlImagem"]);
                                                    },
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.only(
                                                        bottomRight:
                                                            Radius.circular(10),
                                                        bottomLeft:
                                                            Radius.circular(10),
                                                        topLeft: Radius.circular(
                                                            _idUsuarioLogado !=
                                                                    item[
                                                                        "idUsuario"]
                                                                ? 0
                                                                : 8),
                                                        topRight: Radius.circular(
                                                            _idUsuarioLogado ==
                                                                    item[
                                                                        "idUsuario"]
                                                                ? 0
                                                                : 8),
                                                      ),
                                                      child: Stack(
                                                        alignment:
                                                            Alignment.center,
                                                        children: [
                                                          AspectRatio(
                                                            aspectRatio:
                                                                1.0, // Isso faz com que a imagem seja quadrada
                                                            child: Hero(
                                                              tag: item[
                                                                  "urlImagem"],
                                                              child:
                                                                  Image.network(
                                                                item[
                                                                    "urlImagem"],
                                                                fit: BoxFit
                                                                    .cover, // Preenche o espaço quadrado
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  Positioned(
                                                    bottom: 8,
                                                    right: 8,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 3, right: 4),
                                                      child: Text(
                                                        item["hora"] != null
                                                            ? DateFormat(
                                                                    'HH:mm')
                                                                .format(DateTime
                                                                    .parse(item[
                                                                        "hora"]))
                                                            : '',
                                                        style: const TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
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
      },
    );

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 243, 243, 243),
      appBar: AppBar(
          elevation: 0,
          leadingWidth: 25,
          backgroundColor: Color.fromARGB(255, 255, 255, 255),
          foregroundColor: Colors.black,
          actions: [
            IconButton(
                onPressed: () {
                  opcoesMensagem(context);
                },
                icon: const Icon(Icons.more_vert))
          ],
          title: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => perfil_visita(
                      uidPerfil: uidPerfil,
                      nome: nome,
                      imagemPerfil: imagemPerfil,
                      sobrenome: sobrenome,
                      cadastro: cadastro!),
                ),
              );
            },
            child: Row(
              children: <Widget>[
                Container(
                  width: 45,
                  height: 45,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child: CachedNetworkImage(
                      fit: BoxFit.cover,
                      imageUrl: widget.imagemPerfil,
                      placeholder: (context, url) =>
                          const CircularProgressIndicator(
                        color: Colors.white,
                      ),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    "$nome $sobrenome",
                    style: const TextStyle(
                        fontWeight: FontWeight.w500, fontSize: 16),
                  ),
                ),
              ],
            ),
          )),
      body: Stack(
        children: [
          Opacity(
            opacity:
                0.05, // Define a opacidade desejada (neste exemplo, 50% de opacidade)
            child: Image.asset('assets/chat_back.jpg'),
          ),
          SizedBox(
            width: MediaQuery.of(context)
                .size
                .width, //para a imagem preencher tudo na tela
            child: SafeArea(
                child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: <Widget>[
                  stream,
                  caixaMensagem
                  //CaixaMensagem()
                ],
              ),
            )),
          ),
        ],
      ),
    );
  }
}
