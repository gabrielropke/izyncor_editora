import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:editora_izyncor_app/recepcao/recepcao.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:intl/intl.dart';
// ignore: unused_import
import 'package:http/http.dart' as http;

// ignore: camel_case_types
class mais_dados_google extends StatefulWidget {
  const mais_dados_google({super.key});

  @override
  State<mais_dados_google> createState() => _mais_dados_googleState();
}

// ignore: camel_case_types
class _mais_dados_googleState extends State<mais_dados_google> {
  //Controladores
  FirebaseAuth auth = FirebaseAuth.instance;
  TextEditingController controllerUsername = TextEditingController();
  StreamController<String> streamNOME = StreamController<String>();
  DateTime? _selectedDate;
  String? idUsuarioLogado;
  String nome = '';

  FirebaseStorage storage = FirebaseStorage.instance;
  XFile? imagem;
  bool subindoImagem = false;
  String urlImagemRecuperada = "";

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
          urlImagemRecuperada = userData['urlImagem'];
        });
      }
    }
  }

  Future recuperarImagem(String origemImagem) async {
    final ImagePicker picker = ImagePicker();
    XFile? imagemSelecionada;

    if (origemImagem == "camera") {
      imagemSelecionada = await picker.pickImage(source: ImageSource.camera);
    } else if (origemImagem == "galeria") {
      imagemSelecionada = await picker.pickImage(source: ImageSource.gallery);
    }

    if (imagemSelecionada != null) {
      File imagemCortada = await cortarImagem(File(imagemSelecionada.path));
      setState(() {
        imagem = XFile(imagemCortada.path);
        _uploadImagem();
        subindoImagem = true;
      });
    }
  }

  Future _uploadImagem() async {
    File file = File(imagem!.path);
    Reference pastaRaiz = storage.ref();
    Reference arquivo =
        pastaRaiz.child("perfil").child("${idUsuarioLogado!}.jpg");

    UploadTask task = arquivo.putFile(file);

    task.snapshotEvents.listen((TaskSnapshot storageEvent) {
      if (storageEvent.state == TaskState.running) {
        setState(() {
          subindoImagem = true;
        });
      } else if (storageEvent.state == TaskState.success) {
        setState(() {
          subindoImagem = false;
        });
      }
    });

    task.then((TaskSnapshot taskSnapshot) => _recuperarURLimagem(taskSnapshot));
  }

  Future _recuperarURLimagem(TaskSnapshot taskSnapshot) async {
    String url = await taskSnapshot.ref.getDownloadURL();

    atualizarURLimagemFirestore(url);

    setState(() {
      urlImagemRecuperada = url;
    });
  }

  atualizarURLimagemFirestore(String url) {
    FirebaseFirestore db = FirebaseFirestore.instance;

    Map<String, dynamic> dadosAtualizar = {"urlImagem": url};

    db.collection("usuarios").doc(idUsuarioLogado).update(dadosAtualizar);
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

  void showAlertNascimento() {
    QuickAlert.show(
        context: context,
        title: 'AVISO',
        text: 'Você precisa ter pelo menos 13 anos de idade.',
        confirmBtnText: 'Ok',
        type: QuickAlertType.error);
  }

  void showAlert() {
    QuickAlert.show(
        context: context,
        title: 'AVISO',
        text: 'Preencha os dados',
        confirmBtnText: 'Ok',
        type: QuickAlertType.error);
  }

  void showAlertErro() {
    QuickAlert.show(
        context: context,
        title: 'AVISO',
        text: 'Erro ao cadastrar usuário, confira os dados e tente novamente.',
        confirmBtnText: 'Ok',
        type: QuickAlertType.error);
  }

  void showAlertErroUsername() {
    QuickAlert.show(
        context: context,
        title: 'Negado',
        text: 'Usuário já está em uso!',
        confirmBtnText: 'Ok',
        type: QuickAlertType.error);
  }

  void showAlertSucessoUsername() {
    QuickAlert.show(
        context: context,
        title: 'Boa!',
        text: 'Usuário está disponível para uso.',
        confirmBtnText: 'Ok',
        type: QuickAlertType.success);
  }

  // ignore: unused_field
  String _mensagemErro = "";

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1900),
        lastDate: DateTime(2100));
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  _validarCampos() async {
    // Recupera dados dos campos
    DateTime? nascimento = _selectedDate;
    String username = controllerUsername.text;

    // Verifica se o campo username está vazio
    if (username.isEmpty) {
      setState(() {
        showAlertErroUsername();
      });
      return; // Impede que o cadastro prossiga
    }

    // Verifica se o usuário já existe no banco de dados
    bool userExists = await checkUserPermission(username);

    if (userExists) {
      setState(() {
        showAlertErroUsername();
      });
      return; // Impede que o cadastro prossiga
    }

    if (nascimento == null || nascimento.year > 2010) {
      setState(() {
        showAlertNascimento();
      });
      return;
    }

    // Se chegou até aqui, todos os campos estão validados
    setState(() {
      _mensagemErro = "";
    });

    atualizarUserFirestore();
    atualizarNascimentoFirestore();
    // ignore: use_build_context_synchronously
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const recepcao()));
  }

  atualizarUserFirestore() {
    String username = controllerUsername.text;

    FirebaseFirestore db = FirebaseFirestore.instance;

    Map<String, dynamic> dadosAtualizar = {"username": username};

    db.collection("usuarios").doc(idUsuarioLogado).update(dadosAtualizar);
  }

  atualizarNascimentoFirestore() {
    DateTime? nascimento = _selectedDate;

    FirebaseFirestore db = FirebaseFirestore.instance;

    Map<String, dynamic> dadosAtualizar = {"nascimento": nascimento};

    db.collection("usuarios").doc(idUsuarioLogado).update(dadosAtualizar);
  }

  Future<bool> checkUserPermission(String username) async {
    final usersCollection = FirebaseFirestore.instance.collection('usuarios');
    final querySnapshot =
        await usersCollection.where('username', isEqualTo: username).get();

    return querySnapshot.docs.isNotEmpty;
  }

  @override
  initState() {
    super.initState();
    recuperarDadosUsuario();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 238, 234, 228),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            SizedBox(child: Image.asset("assets/background_cadastro.png")),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(children: [
                Padding(
                  padding: const EdgeInsets.only(top: 70),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: SizedBox(
                        width: 300,
                        child: Image.asset("assets/logo_izyncor02.png")),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 25),
                      Align(
                          alignment: Alignment.center,
                          child: Text(
                            'Olá, $nome',
                            style: const TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 189, 147, 157)),
                          )),
                      const SizedBox(height: 10),
                      const Text(
                        'Precisamos de algumas informações para prosseguir, tudo bem?',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                          color: Color.fromARGB(255, 182, 150, 158),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      children: [
                        Align(
                          alignment: Alignment.topRight,
                          child: SizedBox(
                            width: 100,
                            height: 100,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(64),
                              child: GestureDetector(
                                onTap: () {
                                  recuperarImagem("galeria");
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    // ignore: unnecessary_null_comparison
                                    image: urlImagemRecuperada != null
                                        ? DecorationImage(
                                            image: NetworkImage(
                                                urlImagemRecuperada),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                                  ),
                                  // ignore: unnecessary_null_comparison
                                  child: urlImagemRecuperada == null
                                      ? const Icon(Icons.person,
                                          size: 60, color: Colors.white)
                                      : null,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: ClipRRect(
                            child: GestureDetector(
                              onTap: () {
                                recuperarImagem("galeria");
                              },
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFFBB2649),
                                    border: Border.all(
                                        width: 2, color: Colors.white)),
                                child: const Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                        subindoImagem ? Container() : Container(),
                      ],
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 30),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: TextField(
                      controller: controllerUsername,
                      keyboardType: TextInputType.name,
                      maxLength: 20,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.alternate_email_rounded,
                          size: 20,
                          color: Color.fromARGB(255, 203, 197, 190),
                        ),
                        suffixIcon: IconButton(
                          icon: const Icon(
                            Icons.search_rounded,
                            color: Color.fromARGB(255, 190, 23, 79),
                          ), // Ícone do botão
                          onPressed: () async {
                            String username = controllerUsername.text;

                            // Verifique se o campo está vazio
                            if (username.isEmpty) {
                              setState(() {
                                showAlert(); // Exiba uma mensagem de campo vazio
                              });
                              return; // Impede que a função prossiga
                            }

                            // Verifique se o username contém caracteres especiais usando uma expressão regular
                            RegExp regex = RegExp(r'^[a-zA-Z0-9_]+$');
                            if (!regex.hasMatch(username)) {
                              setState(() {
                                showAlertErroUsername(); // Exiba uma mensagem de caracteres especiais
                              });
                              return; // Impede que a função prossiga
                            }

                            // Agora, você pode continuar com a verificação de existência do usuário
                            bool userExists =
                                await checkUserPermission(username);
                            if (userExists) {
                              // O usuário já existe, você pode exibir uma mensagem ou fazer algo aqui
                              setState(() {
                                showAlertErroUsername(); // Ou exibir uma mensagem de erro
                              });
                            } else {
                              // O usuário não existe, você pode exibir uma mensagem ou fazer algo aqui
                              setState(() {
                                showAlertSucessoUsername(); // Ou exibir uma mensagem de sucesso
                              });
                            }
                          },
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(13)),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(13),
                            borderSide: const BorderSide(color: Colors.white)),
                        contentPadding:
                            const EdgeInsets.fromLTRB(32, 15, 32, 16),
                        hintText: "Nome de usuário",
                        hintStyle: const TextStyle(
                            color: Color.fromARGB(255, 189, 185, 185),
                            fontWeight: FontWeight.w400),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 260,
                        height: 55,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 255, 255, 255),
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 20, left: 10),
                          child: Text(
                            _selectedDate == null
                                ? 'Data de Nascimento'
                                : DateFormat('dd/MM/yyyy')
                                    .format(_selectedDate!),
                            style: TextStyle(
                              color: _selectedDate == null
                                  ? const Color.fromARGB(255, 189, 185, 185)
                                  : Colors.black,
                              fontWeight: FontWeight.w400,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: 80,
                        height: 60,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 255, 255, 255),
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: IconButton(
                          onPressed: () {
                            _selectDate(context);
                          },
                          icon: const Icon(
                            Icons.calendar_month_rounded,
                            size: 30,
                            color: Color.fromARGB(255, 203, 197, 190),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 30),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFBB2649),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(13))),
                          onPressed: () {
                            _validarCampos();
                          },
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(left: 103),
                                child: Text(
                                  "Vamos lá!",
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
                  ),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
