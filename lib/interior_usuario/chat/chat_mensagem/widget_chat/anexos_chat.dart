import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class anexos_chat extends StatefulWidget {
  final String idUsuarioLogado;
  final String idUsuarioDestino;
  final String username;
  final String urlPerfil;
  const anexos_chat(
      {super.key,
      required this.idUsuarioLogado,
      required this.idUsuarioDestino,
      required this.username,
      required this.urlPerfil});

  @override
  State<anexos_chat> createState() => _anexos_chatState();
}

class _anexos_chatState extends State<anexos_chat> {
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseStorage storage = FirebaseStorage.instance;

  late String idUsuarioLogado;
  late String idUsuarioDestino;
  late String username;
  late String urlPerfil;
  PlatformFile? pickedFile;
  UploadTask? uploadTask;

  void caixaOpcoes(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
        top: Radius.circular(20.0),
      )),
      backgroundColor: Color.fromARGB(255, 239, 239, 248),
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
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    enviarFoto();
                  },
                  child: const icone_container(
                      icone: 'assets/galeria.png',
                      corIcone: Colors.blue,
                      textoItem: 'Galeria'),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    enviarFotoCamera();
                  },
                  child: const icone_container(
                      icone: 'assets/camera2.png',
                      corIcone: Colors.orange,
                      textoItem: 'Câmera'),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    enviarArquivo();
                  },
                  child: const icone_container(
                      icone: 'assets/anexo2.png',
                      corIcone: Colors.pink,
                      textoItem: 'Arquivos'),
                ),
              ],
            ),
            const SizedBox(height: 40),
            if (Platform.isIOS)
              const SizedBox(
                width: double.infinity,
                height: 20,
              )
          ],
        );
      },
    );
  }

  Future enviarArquivo() async {
    final result = await FilePicker.platform.pickFiles();

    if (result == null) return;

    setState(() {
      pickedFile = result.files.first;
    });
    uploadFile();
    salvarConversaAnexo();
  }

  Future uploadFile() async {
    // Gere um ID específico para os documentos
    String idMensagem = FirebaseFirestore.instance.collection('chat').doc().id;

    final path = 'arquivos/${pickedFile!.name}';
    final file = File(pickedFile!.path!);

    // Obter tamanho do arquivo em bytes
    int fileSizeInBytes = file.lengthSync();

    // Converter bytes para kilobytes ou megabytes
    double fileSizeInKB = fileSizeInBytes / 1024; // 1 KB = 1024 bytes
    double fileSizeInMB = fileSizeInKB / 1024; // 1 MB = 1024 KB

    String tamanhoArquivo;

    if (fileSizeInMB < 1) {
      tamanhoArquivo = '${fileSizeInKB.toStringAsFixed(2)} KB';
    } else {
      tamanhoArquivo = '${fileSizeInMB.toStringAsFixed(2)} MB';
    }

    print('Tamanho do arquivo: $tamanhoArquivo');

    final ref = FirebaseStorage.instance.ref().child(path);
    uploadTask = ref.putFile(file);

    final snapshot = await uploadTask!.whenComplete(() {});

    final urlDownload = await snapshot.ref.getDownloadURL();
    print(urlDownload);

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
      'mensagem': pickedFile!.name,
      'tipo': 'documento',
      'urlImagem': urlDownload,
      'tamanho': tamanhoArquivo,
    });

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
      'mensagem': pickedFile!.name,
      'tipo': 'documento',
      'urlImagem': urlDownload,
      'tamanho': tamanhoArquivo,
    });

    print('Arquivo enviado com sucesso para o Firestore!');
    enviarNotificacao();
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
  }

  Future<void> enviarFoto() async {
    final ImagePicker _picker = ImagePicker();
    XFile? imagemSelecionada;
    imagemSelecionada = await _picker.pickImage(source: ImageSource.gallery);

    if (imagemSelecionada != null) {
      File file = File(imagemSelecionada.path);

      // Realizar o corte da imagem
      File? imagemCortada = await cortarImagem(file);

      if (imagemCortada != null) {
        salvarConversa();
      }

      if (imagemCortada != null) {
        String nomeImagem = DateTime.now().millisecondsSinceEpoch.toString();

        // Enviar a imagem cortada para o Firebase Storage
        Reference pastaRaiz = storage.ref();
        Reference arquivo = pastaRaiz
            .child('chat')
            .child(idUsuarioLogado)
            .child("$nomeImagem.jpg");

        UploadTask task = arquivo.putFile(imagemCortada);

        await task.whenComplete(() async {
          String urlDownload = await arquivo.getDownloadURL();

          // Usar o nome da imagem como o nome do documento
          await FirebaseFirestore.instance
              .collection('chat')
              .doc(idUsuarioLogado)
              .collection(idUsuarioDestino)
              .doc(nomeImagem) // Usar o nome da imagem como o nome do documento
              .set({
            'hora': DateTime.now().toString(),
            'idMensagem':
                nomeImagem, // Usar o nome da imagem como o ID da mensagem
            'idRemetente': idUsuarioLogado,
            'idDestinatario': idUsuarioDestino,
            'lida': 'novo',
            'mensagem': urlDownload,
            'tipo': 'imagem',
            'urlImagem': 'vazia',
            'tamanho': 'vazia',
          });

          await FirebaseFirestore.instance
              .collection('chat')
              .doc(idUsuarioDestino)
              .collection(idUsuarioLogado)
              .doc(nomeImagem) // Usar o nome da imagem como o nome do documento
              .set({
            'hora': DateTime.now().toString(),
            'idMensagem':
                nomeImagem, // Usar o nome da imagem como o ID da mensagem
            'idRemetente': idUsuarioLogado,
            'idDestinatario': idUsuarioDestino,
            'lida': 'novo',
            'mensagem': urlDownload,
            'tipo': 'imagem',
            'urlImagem': 'vazia',
            'tamanho': 'vazia',
          });

          // Atualizar o estado ou realizar qualquer outra ação necessária
          setState(() {});
        });
      }
    }
  }

  Future<void> enviarFotoCamera() async {
    final ImagePicker _picker = ImagePicker();
    XFile? imagemSelecionada;
    imagemSelecionada = await _picker.pickImage(source: ImageSource.camera);

    if (imagemSelecionada != null) {
      File file = File(imagemSelecionada.path);

      // Realizar o corte da imagem
      File? imagemCortada = await cortarImagem(file);

      if (imagemCortada != null) {
        salvarConversa();
      }

      if (imagemCortada != null) {
        String nomeImagem = DateTime.now().millisecondsSinceEpoch.toString();

        // Enviar a imagem cortada para o Firebase Storage
        Reference pastaRaiz = storage.ref();
        Reference arquivo = pastaRaiz
            .child('chat')
            .child(idUsuarioLogado)
            .child("$nomeImagem.jpg");

        UploadTask task = arquivo.putFile(imagemCortada);

        await task.whenComplete(() async {
          String urlDownload = await arquivo.getDownloadURL();

          // Usar o nome da imagem como o nome do documento
          await FirebaseFirestore.instance
              .collection('chat')
              .doc(idUsuarioLogado)
              .collection(idUsuarioDestino)
              .doc(nomeImagem) // Usar o nome da imagem como o nome do documento
              .set({
            'hora': DateTime.now().toString(),
            'idMensagem':
                nomeImagem, // Usar o nome da imagem como o ID da mensagem
            'idRemetente': idUsuarioLogado,
            'idDestinatario': idUsuarioDestino,
            'lida': 'novo',
            'mensagem': urlDownload,
            'tipo': 'imagem',
            'urlImagem': 'vazia',
            'tamanho': 'vazia',
          });

          await FirebaseFirestore.instance
              .collection('chat')
              .doc(idUsuarioDestino)
              .collection(idUsuarioLogado)
              .doc(nomeImagem) // Usar o nome da imagem como o nome do documento
              .set({
            'hora': DateTime.now().toString(),
            'idMensagem':
                nomeImagem, // Usar o nome da imagem como o ID da mensagem
            'idRemetente': idUsuarioLogado,
            'idDestinatario': idUsuarioDestino,
            'lida': 'novo',
            'mensagem': urlDownload,
            'tipo': 'imagem',
            'urlImagem': 'vazia',
            'tamanho': 'vazia',
          });

          // Atualizar o estado ou realizar qualquer outra ação necessária
          setState(() {});
        });
      }
    }
  }

  cortarImagem(File file) async {
    if (Platform.isAndroid) {
      return await ImageCropper()
        .cropImage(sourcePath: file.path, aspectRatioPresets: [
      CropAspectRatioPreset.square,
    ]);
    }
    if (Platform.isIOS) {
      return await ImageCropper().cropImage(
        sourcePath: file.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1));
    }
    
  }

  Future<void> salvarConversa() async {
    await FirebaseFirestore.instance
        .collection('conversas')
        .doc(idUsuarioLogado)
        .collection('ultima_conversa')
        .doc(idUsuarioDestino)
        .set({
      "idRemetente": idUsuarioLogado,
      "idDestinatario": idUsuarioDestino,
      "autorMensagem": idUsuarioLogado,
      "mensagem": '🌃',
      "tipo": 'imagem',
      "hora": DateTime.now().toString(),
    }, SetOptions(merge: true));

    print('Conversa salva 01');

    await FirebaseFirestore.instance
        .collection('conversas')
        .doc(idUsuarioDestino)
        .collection('ultima_conversa')
        .doc(idUsuarioLogado)
        .set({
      "idRemetente": idUsuarioLogado,
      "idDestinatario": idUsuarioDestino,
      "autorMensagem": idUsuarioLogado,
      "mensagem": '🌃',
      "tipo": 'imagem',
      "hora": DateTime.now().toString(),
    }, SetOptions(merge: true));

    print('Conversa salva 02');
  }

  Future<void> salvarConversaAnexo() async {
    await FirebaseFirestore.instance
        .collection('conversas')
        .doc(idUsuarioLogado)
        .collection('ultima_conversa')
        .doc(idUsuarioDestino)
        .set({
      "idRemetente": idUsuarioLogado,
      "idDestinatario": idUsuarioDestino,
      "autorMensagem": idUsuarioLogado,
      "mensagem": 'anexo',
      "tipo": 'anexo',
      "hora": DateTime.now().toString(),
    }, SetOptions(merge: true));

    print('Conversa salva 01');

    await FirebaseFirestore.instance
        .collection('conversas')
        .doc(idUsuarioDestino)
        .collection('ultima_conversa')
        .doc(idUsuarioLogado)
        .set({
      "idRemetente": idUsuarioLogado,
      "idDestinatario": idUsuarioDestino,
      "autorMensagem": idUsuarioLogado,
      "mensagem": 'anexo',
      "tipo": 'anexo',
      "hora": DateTime.now().toString(),
    }, SetOptions(merge: true));

    print('Conversa salva 02');
  }

  @override
  void initState() {
    super.initState();
    idUsuarioLogado = widget.idUsuarioLogado;
    idUsuarioDestino = widget.idUsuarioDestino;
    username = widget.username;
    urlPerfil = widget.urlPerfil;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        caixaOpcoes(context);
      },
      child: Opacity(
        opacity: 0.6,
        child: Image.asset(
          'assets/anexo.png',
          scale: 3,
        ),
      ),
    );
  }
}

class icone_container extends StatelessWidget {
  const icone_container(
      {super.key,
      required this.icone,
      required this.corIcone,
      required this.textoItem});

  final String textoItem;
  final String icone;
  final Color corIcone;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 60,
          height: 60,
          decoration:
              const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          child: SizedBox(
            child: Image.asset(
              icone,
              scale: 2,
              color: corIcone,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          textoItem,
          style: const TextStyle(
              fontWeight: FontWeight.w400, color: Colors.black54),
        )
      ],
    );
  }
}
