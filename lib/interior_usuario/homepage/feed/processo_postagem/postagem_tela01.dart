import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:editora_izyncor_app/interior_usuario/homepage/feed/processo_postagem/assuntos_post.dart';
import 'package:editora_izyncor_app/interior_usuario/tabbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart'; // Importe o pacote cloud_firestore

class postagem_tela01 extends StatefulWidget {
  const postagem_tela01({super.key});

  @override
  State<postagem_tela01> createState() => _postagem_tela01State();
}

class _postagem_tela01State extends State<postagem_tela01> {
  FirebaseAuth auth = FirebaseAuth.instance;

  TextEditingController controllerLegenda = TextEditingController();
  TextEditingController controllerTitulo = TextEditingController();

  String? idUsuarioLogado;
  String nome = '';
  String sobrenome = '';
  String urlImagem = '';

  bool legendaVazia = true;

  File? imagem;

  void showAlertErro() {
    QuickAlert.show(
        context: context,
        title: 'Erro',
        text:
            'Não foi possível finalizar sua postagem, aguarde alguns minutos e tente novamente.',
        confirmBtnText: 'Ok',
        type: QuickAlertType.error);
  }

  void showAlertSucesso() {
    QuickAlert.show(
        context: context,
        title: 'Feito',
        text: 'Postagem finalizada!',
        confirmBtnText: 'Ok',
        type: QuickAlertType.success);
  }

  Future<void> selecionarImagem() async {
    final imagePicker = ImagePicker();
    final pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final croppedFile = await cortarImagem(File(pickedFile.path));
      setState(() {
        imagem = croppedFile;
      });
    }
  }

  Future<void> selecionarImagemCamera() async {
    final imagePicker = ImagePicker();
    final pickedFile = await imagePicker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      final croppedFile = await cortarImagem(File(pickedFile.path));
      setState(() {
        imagem = croppedFile;
      });
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

  // Método para recuperar os dados do Firestore com base no UID do usuário logado
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
          urlImagem = userData['urlImagem'];
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    recuperarDadosUsuario();
    controllerLegenda.addListener(() {
      setState(() {
        legendaVazia = controllerLegenda.text.isEmpty;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        foregroundColor: Colors.black,
        elevation: 0,
        leadingWidth: 26,
        backgroundColor: Colors.transparent,
        title: const Text('Nova postagem'),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: ((context) => const home_principal(
                          indexPagina: 1,
                        )),
                  ),
                );
              },
              icon: const Icon(Icons.close))
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: ClipOval(
                      child: CachedNetworkImage(
                        fit: BoxFit.cover,
                        imageUrl: urlImagem,
                        placeholder: (context, url) =>
                            const CircularProgressIndicator(
                          color: Colors.white,
                        ),
                        errorWidget: (context, url, error) => const Icon(
                          Icons.error,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$nome $sobrenome',
                        style: const TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 20),
                      ),
                      // const SizedBox(height: 0),
                      const Text('Publicar em Izyncor')
                    ],
                  )
                ],
              ),
              const SizedBox(height: 30),
              Visibility(
                visible: imagem == null,
                child: TextField(
                  controller: controllerTitulo,
                  maxLines: null,
                  maxLength: 25,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.black12)),
                    contentPadding: const EdgeInsets.fromLTRB(32, 15, 32, 16),
                    hintText: "Defina um título",
                    hintStyle: const TextStyle(
                        color: Colors.black45,
                        fontSize: 18,
                        fontWeight: FontWeight.w400),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: controllerLegenda,
                maxLines: null,
                maxLength: 3000,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.black12)),
                  contentPadding: const EdgeInsets.fromLTRB(32, 15, 32, 16),
                  hintText: "Compartilhe seus pensamentos... com moderação!",
                  hintStyle: const TextStyle(
                      color: Colors.black45,
                      fontSize: 18,
                      fontWeight: FontWeight.w400),
                ),
              ),
              Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: imagem == null
                      ? null
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.file(
                            imagem!,
                            fit: BoxFit.cover,
                          ))),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: const BoxDecoration(
                          color: Color.fromARGB(255, 233, 233, 233),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.image_rounded,
                            color: Colors.black38,
                            size: 30,
                          ),
                          onPressed: () {
                            selecionarImagem();
                          },
                        ),
                      ),
                      const SizedBox(width: 20),
                      Container(
                        width: 60,
                        height: 60,
                        decoration: const BoxDecoration(
                          color: Color.fromARGB(255, 233, 233, 233),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.photo_camera_rounded,
                            color: Colors.black38,
                            size: 30,
                          ),
                          onPressed: () {
                            selecionarImagemCamera();
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 20),
                  if (legendaVazia && imagem == null)
                    Container(
                        width: 180,
                        height: 60,
                        decoration: BoxDecoration(
                            color: Colors.black12,
                            borderRadius: BorderRadius.circular(32)),
                        child: const Center(
                            child: Text(
                          'Publicar',
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 20,
                              color: Colors.black38),
                        ))),
                  if (!legendaVazia || imagem != null)
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: ((context) => assuntos_postagem(
                                  titulo: controllerTitulo.text.isEmpty ? '' : controllerTitulo.text,
                                  legenda: controllerLegenda.text.isEmpty ? '' : controllerLegenda.text,
                                  imagem: imagem == null ? null : imagem!,
                                )),
                          ),
                        );
                      },
                      child: Container(
                        width: 180,
                        height: 60,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 63, 122, 209),
                          borderRadius: BorderRadius.circular(32),
                        ),
                        child: const Center(
                          child: Text(
                            'Publicar',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
