import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:editora_izyncor_app/interior_usuario/tabbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart'; // Importe o pacote cloud_firestore

class editar_postagem extends StatefulWidget {
  final String idPostagem;
  final String legenda;
  final String imagemPostagem;
  final String titulo;
  const editar_postagem(
      {super.key,
      required this.idPostagem,
      required this.legenda,
      required this.imagemPostagem,
      required this.titulo});

  @override
  State<editar_postagem> createState() => _editar_postagemState();
}

class _editar_postagemState extends State<editar_postagem> {
  FirebaseAuth auth = FirebaseAuth.instance;

  TextEditingController controllerLegenda = TextEditingController();
  TextEditingController controllerTitulo = TextEditingController();

  String? idUsuarioLogado;
  String nome = '';
  String sobrenome = '';
  String urlImagem = '';

  late String idPostagem;
  late String legenda;
  late String imagemPostagem;
  late String titulo;

  bool legendaVazia = true;

  File? imagem;

  Future<void> atualizarPostagem() async {
    legenda = controllerLegenda.text;
    titulo = controllerTitulo.text;

    if (imagemPostagem == 'vazio') {
      final postagemRef =
          FirebaseFirestore.instance.collection('feed').doc(idPostagem);
      await postagemRef.update({
        'legenda': legenda,
        'titulo': titulo,
        'editado': 'sim'
      });

      // ignore: use_build_context_synchronously
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: ((context) => const home_principal(indexPagina: 2,)),
        ),
      );
    } else {
      try {
        FirebaseStorage.instance
            .ref()
            .child('imagens_postagens')
            .child(DateTime.now().millisecondsSinceEpoch.toString());

        await FirebaseFirestore.instance
            .collection('feed')
            .doc(idPostagem)
            .update({
          'legenda': legenda,
          'editado': 'sim'
        });

        // ignore: use_build_context_synchronously
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: ((context) => const home_principal(indexPagina: 2,)),
          ),
        );
      } catch (error) {
        showAlertErro();
      }
    }
  }

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
    return await ImageCropper()
        .cropImage(sourcePath: file.path, aspectRatioPresets: [
      CropAspectRatioPreset.square,
    ]);
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
    controllerLegenda.text = widget.legenda;
    controllerTitulo.text = widget.titulo;
    imagemPostagem = widget.imagemPostagem;
    idPostagem = widget.idPostagem;
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
                      const SizedBox(height: 3),
                      const Text('Editar postagem')
                    ],
                  )
                ],
              ),
              const SizedBox(height: 30),
              Visibility(
                visible: imagemPostagem == 'vazio',
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
                  hintText: "Compartilhe seus pensamentos...",
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
              Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: imagemPostagem == 'vazio'
                      ? null
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: CachedNetworkImage(
                            imageUrl: imagemPostagem,
                          ))),
              const SizedBox(height: 30),
              GestureDetector(
                      onTap: () {atualizarPostagem();},
                      child: Container(
                          width: double.infinity,
                          height: 60,
                          decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 63, 122, 209),
                              borderRadius: BorderRadius.circular(16)),
                          child: const Center(
                              child: Text(
                            'Salvar',
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 20,
                                color: Colors.white),
                          ))),
                    )
            ],
          ),
        ),
      ),
    );
  }
}
