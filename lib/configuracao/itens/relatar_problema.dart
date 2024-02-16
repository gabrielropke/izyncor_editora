import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class relatar_problema extends StatefulWidget {
  const relatar_problema({super.key});

  @override
  State<relatar_problema> createState() => _relatar_problemaState();
}

class _relatar_problemaState extends State<relatar_problema> {
  FirebaseAuth auth = FirebaseAuth.instance;
  TextEditingController controllerlegendaBug = TextEditingController();
  late String username;
  File? imagem;
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
          username = userData['username'];
        });
      }
    }
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

  cortarImagem(File file) async {
    return await ImageCropper()
        .cropImage(sourcePath: file.path, aspectRatioPresets: [
      CropAspectRatioPreset.original,
    ]);
  }

  // void enviarNotificacao() {
  //   CollectionReference usuariosCollection =
  //       FirebaseFirestore.instance.collection('usuarios');

  //   DocumentReference usuarioRef = usuariosCollection.doc(autorId);

  //   usuarioRef.collection('notificacoes').add({
  //     'username': username,
  //     'idUsuario': idUsuarioLogado,
  //     'mensagem': 'curtiu sua publicação.',
  //     'hora': DateTime.now().toString(),
  //     'postagem': imagemUrl,
  //     'idPostagem': idPostagem,
  //     'perfil': perfilLogado,
  //     'status': 'novo',
  //   });
  // }

  void showAlertSucesso() {
    QuickAlert.show(
        context: context,
        title: 'Perfeito!!',
        text: 'Você está fazendo um ótimo trabalho.',
        confirmBtnText: 'Ok',
        onConfirmBtnTap: () {
          enviarRelato();
          Navigator.pop(context);
          Navigator.pop(context);
        },
        type: QuickAlertType.success);
  }

  void showAlertCampos() {
    QuickAlert.show(
        context: context,
        title: 'Hmm..',
        text: 'Verifique os campos antes de enviar...',
        confirmBtnText: 'Ok',
        type: QuickAlertType.error);
  }

  validarCampos() {
    if (controllerlegendaBug.text.isEmpty) {
      showAlertCampos();
      return;
    }
    return showAlertSucesso();
  }

  // Future<void> enviarbug() async {
  //   String bug = controllerlegendaBug.text;

  //   // Gere um ID único para a postagem
  //   final String relatoId =
  //       FirebaseFirestore.instance.collection('relatos_bugs').doc().id;

  //   // Para postagens sem imagem
  //   await FirebaseFirestore.instance
  //       .collection('relatos_bugs')
  //       .doc(relatoId)
  //       .set({
  //     'autorId': idUsuarioLogado,
  //     'username': username,
  //     'legendaBug': bug,
  //     'hora': DateTime.now().toString(),
  //     'relatoId': relatoId,
  //     'anexo': ''
  //   });
  // }

  Future<void> enviarRelato() async {
    // Gere um ID único para a denuncia
    final String relatoId =
        FirebaseFirestore.instance.collection('relatos_bugs').doc().id;

    if (imagem == null) {
      await FirebaseFirestore.instance
          .collection('relatos_bugs')
          .doc(relatoId)
          .set({
        'relatoId': relatoId,
        'autorId': idUsuarioLogado,
        'username': username,
        'legendaBug': controllerlegendaBug.text,
        'hora': DateTime.now().toString(),
        'anexo': ''
      });
    } else {
      try {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('imagens_denuncias')
            .child(relatoId);
        final uploadTask = storageRef.putFile(imagem!);
        final TaskSnapshot downloadUrl = await uploadTask;

        final String imageUrl = await downloadUrl.ref.getDownloadURL();

        await FirebaseFirestore.instance
            .collection('relatos_bugs')
            .doc(relatoId)
            .set({
          'autorId': idUsuarioLogado,
          'username': username,
          'legendaBug': controllerlegendaBug.text,
          'hora': DateTime.now().toString(),
          'relatoId': relatoId,
          'anexo': imageUrl
        });
      } catch (error) {
        // ignore: avoid_print
        print('deu errado');
      }
    }

    await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(idUsuarioLogado)
        .update({
      'relatos': FieldValue.increment(1),
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    recuperarDadosUsuario();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 238, 234, 228),
      body: Stack(
        children: [
          SizedBox(child: Image.asset("assets/topo_login.png")),
          Center(
            child: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ClipRRect(
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              border:
                                  Border.all(width: 2, color: Colors.black)),
                          child: const Icon(
                            Icons.warning_amber_rounded,
                            size: 42,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        'Encontrou algum bug?',
                        style: TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 24),
                      ),
                      const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Text(
                          'Ajude-nos a melhorar e reporte o erro encontrado!',
                          style: TextStyle(color: Colors.black54, fontSize: 18),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 25),
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: SizedBox(
                            width: 310,
                            child: TextField(
                              controller: controllerlegendaBug,
                              keyboardType: TextInputType.text,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                              ),
                              maxLines: null,
                              maxLength: null,
                              decoration: InputDecoration(
                                suffixIcon: IconButton(
                                    onPressed: () {
                                      selecionarImagem();
                                    },
                                    icon: const Icon(
                                      Icons.attach_file_rounded,
                                      size: 24,
                                      color: Color.fromARGB(255, 124, 122, 119),
                                    )),
                                prefixIcon: const Icon(
                                  Icons.error_outline,
                                  size: 20,
                                  color: Color.fromARGB(255, 203, 197, 190),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(13)),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(13),
                                    borderSide: const BorderSide(
                                        color: Colors.black26)),
                                contentPadding:
                                    const EdgeInsets.fromLTRB(32, 15, 32, 16),
                                hintText: "Descrição do bug",
                                hintStyle: const TextStyle(
                                    color: Color.fromARGB(255, 189, 185, 185),
                                    fontWeight: FontWeight.w400),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: imagem == null
                              ? null
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: SizedBox(
                                    width: 300,
                                    child: Image.file(
                                      imagem!,
                                      fit: BoxFit.cover,
                                    ),
                                  ))),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: 310,
                        height: 50,
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFBB2649),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(13))),
                            onPressed: () {
                              validarCampos();
                            },
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(left: 110),
                                  child: Text(
                                    "Enviar",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 17,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_sharp,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ],
                            )),
                      ),
                    ]),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(
                    Icons.arrow_back_ios,
                    color: Colors.black,
                  )),
            ),
          ),
        ],
      ),
    );
  }
}
